#!/usr/bin/env bash
# AT-T* task lifecycle: show | brief | confirm | start | complete | done
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"
# shellcheck source=_aw-verify-lib.sh
source "${SCRIPT_DIR}/_aw-verify-lib.sh"
# shellcheck source=_aw-bug-lib.sh
source "${SCRIPT_DIR}/_aw-bug-lib.sh"

ROOT="$(aw_repo_root)"
POLICY="$(aw_policy_dir)"
CMD="${1:-}"
shift || true
TASK_ID="${1:-}"
[[ -n "$TASK_ID" ]] && shift || true

usage() {
  cat <<EOF
Usage:
  aw task              Show next task (same as aw next)
  aw task show [id]    Show one AT-T* row
  aw task brief <id>   Print pre-coding requirement discussion brief
  aw task confirm <id> "已确认：范围=...；验收=...；非目标=..."  Mark requirement discussion confirmed
  aw task start <id>   Mark 进行中 (requires requirement confirmation)
  aw task blocked <id> Mark 阻塞
  aw task checkpoint <id> [--git yes|no --reason "..."] [--handoff --compact --file-index]  Resolve post-completion handoff/rollback/index gates
  aw task checkpoint-check <id>  Check completion checkpoint only when task is 已完成
  aw task done <id>    Deprecated alias; verifies by default before marking 已完成
  aw task complete <id> Run verify; if pass mark 已完成, if fail log bug

Paste block for Agent: aw paste task
EOF
  exit "${1:-0}"
}

append_bug_log() {
  local task_id="$1" status="$2" summary="$3" verify_cmd="$4"
  aw_bug_append "test" "$status" "$task_id" "$summary" "$verify_cmd"
}

audit_task() {
  local task_id="$1" action="$2" result="$3" evidence="${4:-docs/plans/}"
  if [[ -x "${SCRIPT_DIR}/aw-audit.sh" ]]; then
    "${SCRIPT_DIR}/aw-audit.sh" add --task "$task_id" --action "$action" --result "$result" --evidence "$evidence" >/dev/null || true
  fi
}

sync_auto_enabled() {
  [[ "${AW_SYNC_AUTO:-1}" != "0" ]] || return 1
  [[ -x "${SCRIPT_DIR}/aw-sync.sh" ]] || return 1
  aw_sync_configured
}

sync_role_for_pm() {
  local role
  role="$(awk -F'|' '/\*\*角色\*\*/ {gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit}' "${ROOT}/docs/sync/SYNC_CONFIG.md" 2>/dev/null || true)"
  case "$role" in
    frontend|fe|前台|前台前端) echo "frontend" ;;
    admin|admin-frontend|后台|后台管理|后台管理前端) echo "admin" ;;
    backend|be|后端) echo "backend" ;;
    *) echo "" ;;
  esac
}

sync_before_task_start() {
  local task_id="$1" role
  sync_auto_enabled || return 0
  echo "== auto sync before task start =="
  "${SCRIPT_DIR}/aw-sync.sh" pull || {
    echo "error: auto sync pull failed; fix sync center or set AW_SYNC_AUTO=0 for an explicit exception" >&2
    return 1
  }
  "${SCRIPT_DIR}/aw-sync.sh" gate --task "$task_id" || {
    echo "error: auto sync gate failed before starting ${task_id}" >&2
    return 1
  }
  role="$(sync_role_for_pm)"
  if [[ -n "$role" && -x "${SCRIPT_DIR}/aw-pm.sh" ]]; then
    "${SCRIPT_DIR}/aw-pm.sh" assignments --role "$role" >/dev/null 2>&1 || true
    echo "ok  PM assignments checked for role: ${role}"
  fi
}

sync_after_task_complete() {
  local task_id="$1"
  sync_auto_enabled || return 0
  echo "== auto sync after task complete =="
  AW_SYNC_EVENT_SKIP_LOCAL=1 "${SCRIPT_DIR}/aw-sync.sh" event \
    --type complete \
    --task "$task_id" \
    --to all \
    --summary "任务 ${task_id} 已完成并通过验证" \
    --evidence "docs/plans/; docs/handoff/; docs/quality/test-plans/; docs/sync/" || {
      echo "warn: auto sync complete event failed; run ./scripts/aw sync push --task ${task_id}" >&2
      return 0
    }
}

sync_after_task_blocked() {
  local task_id="$1"
  sync_auto_enabled || return 0
  echo "== auto sync after task blocked =="
  AW_SYNC_EVENT_SKIP_LOCAL=1 "${SCRIPT_DIR}/aw-sync.sh" event \
    --type block \
    --task "$task_id" \
    --to all \
    --summary "任务 ${task_id} 已标记阻塞，请相关端检查依赖、接口或验收口径" \
    --risk "跨端依赖可能停滞" \
    --evidence "docs/handoff/PROJECT_HANDOFF.md; docs/sync/SYNC_EVENTS.md" || {
      echo "warn: auto sync block event failed; run ./scripts/aw sync push --task ${task_id}" >&2
      return 0
    }
}

code_map_auto_refresh() {
  [[ "${AW_CODE_MAP_AUTO:-1}" != "0" ]] || return 0
  [[ -x "${SCRIPT_DIR}/aw-code-map.sh" ]] || return 0
  "${SCRIPT_DIR}/aw-code-map.sh" build --quiet >/dev/null 2>&1 || {
    echo "warn: auto code-map refresh failed; run ./scripts/aw code-map build" >&2
    return 0
  }
}

code_map_auto_gate() {
  [[ "${AW_CODE_MAP_AUTO:-1}" != "0" ]] || return 0
  [[ -x "${SCRIPT_DIR}/aw-code-map.sh" ]] || return 0
  "${SCRIPT_DIR}/aw-code-map.sh" gate --task "$1" || {
    echo "error: code-map gate failed for ${1}; run ./scripts/aw code-map build" >&2
    return 1
  }
}

print_commit_prompt() {
  local task_id="$1"
  cat <<EOF

== Commit checkpoint ==
本次任务已完成。为了后期回滚，请询问工程师是否提交当前分支。
- 只生成提交建议：./scripts/aw commit --task ${task_id}
- 带版本记录生成提交建议：./scripts/aw commit --task ${task_id} --changelog "Changed: 完成 ${task_id} <summary>"
- 工程师确认后提交：./scripts/aw commit --task ${task_id} --changelog "Changed: 完成 ${task_id} <summary>" -m "feat(${task_id}): <summary>" --execute
- 更新上下文压缩快照：./scripts/aw compact "完成 ${task_id}" --write --snapshot
- 刷新项目代码文件索引：./scripts/aw file-index
- 记录完成检查点：./scripts/aw task checkpoint ${task_id} --git yes|no --reason "..." --handoff --compact --file-index
- 若暂不提交，请用 --git no --reason 记录原因、风险和下一步。
EOF
}

checkpoint_file() {
  echo "${ROOT}/docs/.aw-task-checkpoints.tsv"
}

checkpoint_mark() {
  local task_id="$1" git_choice="$2" reason="$3" handoff="$4" compact="$5" file_index="$6"
  local f tmp now
  f="$(checkpoint_file)"
  mkdir -p "$(dirname "$f")"
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  tmp="$(mktemp)"
  if [[ -f "$f" ]]; then
    grep -vE "^${task_id}[[:space:]]" "$f" > "$tmp" || true
  fi
  printf '%s\t%s\tgit=%s\treason=%s\thandoff=%s\tcompact=%s\tfile-index=%s\n' "$task_id" "$now" "$git_choice" "$reason" "$handoff" "$compact" "$file_index" >> "$tmp"
  mv "$tmp" "$f"
}

checkpoint_require_resolved() {
  local task_id="$1" f
  f="$(checkpoint_file)"
  if [[ ! -f "$f" ]] || ! grep -qE "^${task_id}[[:space:]]" "$f"; then
    echo "block: missing completion checkpoint for ${task_id}" >&2
    echo "  run: ./scripts/aw task checkpoint ${task_id} --git yes|no --reason \"...\" --handoff --compact --file-index" >&2
    return 1
  fi
  return 0
}

print_task_paste() {
  local id="$1" domain="$2" title="$3" status="$4" deps="$5" verify="$6"
  local dsl plan atomic
  dsl="$(aw_resolve_dsl_file 2>/dev/null || echo "—")"
  plan="$(aw_resolve_plan_file 2>/dev/null || echo "—")"
  atomic="$(aw_resolve_atomic_tasks_file 2>/dev/null || echo "—")"

  cat <<EOF
【agent-workflow · 单任务执行】只完成本条 AT-T，遵守手术式改动。

## 当前任务
- **ID:** ${id}
- **领域:** ${domain:-—}
- **标题:** ${title}
- **状态:** ${status}
- **依赖:** ${deps:-—}
- **验证:** ${verify:-见 PROJECT_CONFIG}

## 必读（@ 路径，勿读 ENGINEERING_INDEX.md）
- ${POLICY}/INVOCATION.md
- ${POLICY}/AICODING_WORKFLOW.md — 阶段 A→E
- ${ROOT}/${dsl}
- ${ROOT}/${atomic}
- ${ROOT}/docs/ENGINEERING_RULES.md
- ${ROOT}/docs/PROJECT_CONFIG.md
- ${ROOT}/docs/handoff/PROJECT_HANDOFF.md

## 阶段 A（先输出再写码）
1. 先复述工程师已确认的需求摘要；如果发现任何未确认点，立即停止编码并回到 \`aw task brief ${id}\`。
2. 列出假设与不确定点；有多解时让我选。
3. 用阶段 B 格式写清验收（可检查）与验证命令。

## 阶段 C–D
- 最短方案 → 再改代码；只服务本任务验收。

## 阶段 E
- 运行完成闭环：\`./scripts/aw task complete ${id}\`
- 它会自动验证；通过后标记已完成，失败写 \`docs/handoff/AI_BUG_LOG.md\` 并保持进行中
- 完成后：\`./scripts/aw commit -m "feat(${id}): …"\`
- 若有 TP：见 \`docs/quality/test-plans/\`（\`aw tp new\`）

## 闸门
- 勿改无关文件；DSL/Plan 真源见上路径。
- 如果本提示不是在 \`aw task confirm\`、\`aw context gate\`、\`aw task start\` 全部通过后生成，禁止写业务代码。
- 禁止无目标全仓扫描；写代码前必须先通过 \`./scripts/aw context gate --task ${id}\`。
- 只读取 \`docs/context/tasks/CTX-${id}.md\` 中“允许读取文件”列出的文件。
EOF

  local spec tp_rel
  while IFS= read -r spec; do
    if aw_is_tp_spec "$spec"; then
      tp_rel="$(aw_resolve_tp_path "$spec" 2>/dev/null || true)"
      if [[ -n "$tp_rel" && -f "${ROOT}/${tp_rel}" ]]; then
        echo ""
        echo "## 关联测试计划"
        "${SCRIPT_DIR}/aw-tp.sh" show "$tp_rel" | sed -n '1,45p'
      fi
    fi
  done < <(aw_verify_specs_from_cell "$verify")
}

print_task_brief() {
  local id="$1" domain="$2" title="$3" status="$4" deps="$5" verify="$6"
  local dsl plan atomic
  dsl="$(aw_resolve_dsl_file 2>/dev/null || echo "—")"
  plan="$(aw_resolve_plan_file 2>/dev/null || echo "—")"
  atomic="$(aw_resolve_atomic_tasks_file 2>/dev/null || echo "—")"

  cat <<EOF
【agent-workflow · 子任务需求沟通包】开始写代码前必须先和工程师确认。

## 当前候选任务
- **ID:** ${id}
- **领域:** ${domain:-—}
- **标题:** ${title}
- **当前状态:** ${status}
- **依赖:** ${deps:-—}
- **验证:** ${verify:-见 PROJECT_CONFIG}

## 需求真源
- DSL: ${ROOT}/${dsl}
- Plan / ATOMIC: ${ROOT}/${atomic}
- 工程规范: ${ROOT}/docs/ENGINEERING_RULES.md
- 项目配置: ${ROOT}/docs/PROJECT_CONFIG.md

## 开始前必须沟通清楚
1. 这个任务要解决的真实用户问题是什么？成功后用户能做什么？
2. 输入、输出、状态变化、错误提示、权限/角色、空态/loading/失败态分别是什么？
3. 是否涉及页面、接口、数据结构、事件联动、缓存、路由、权限、日志或埋点？
4. 这条任务的非目标是什么？哪些相邻功能本次不能顺手改？
5. 验收怎么判断通过？需要补哪些测试用例或手工验证步骤？
6. 有没有 DSL / Plan 没写清楚、互相矛盾、或需要工程师拍板的点？

## Agent 规则
- 不要猜需求；有疑问就列问题并等待工程师回答。
- 若 \`docs/PROJECT_CONFIG.md\` 未选择项目阶段，先让工程师选择：1=全新项目，2=已有 / 存量项目。已有项目必须先确认现状基线和本次增量边界。
- 若 \`docs/PROJECT_CONFIG.md\` 未选择项目类型，先让工程师选择代码托管平台：1=GitHub、2=本地 Git、3=GitLab、4=Bitbucket、5=Gitee、6=GitCode、7=Gitea、8=Forgejo、9=GitLab CE、10=Gerrit、11=阿里云云效 Codeup；非本地 Git 需记录远程仓库地址。
- 工程师确认前，不允许执行 \`aw task start ${id}\`，也不允许写业务代码。
- 工程师确认后执行：
  \`./scripts/aw task confirm ${id} "已确认：范围=<本次做什么>；验收=<怎么判断通过>；非目标=<本次不做什么>"\`
  \`./scripts/aw context plan --task ${id}\`
  审阅并确认 Context Plan 的允许读取文件后：
  \`./scripts/aw context gate --task ${id}\`
  \`./scripts/aw task start ${id}\`
  \`./scripts/aw paste task\`
EOF
}

case "$CMD" in
  ""|next)
    aw_gate_coding_ready || exit 1
    atomic="$(aw_resolve_atomic_tasks_file)" || { echo "error: no ATOMIC_TASKS file" >&2; exit 1; }
    row="$(aw_task_find_next "${ROOT}/${atomic}")" || {
      echo "No eligible AT-T* (待办/进行中 with deps satisfied)"
      exit 1
    }
    IFS=$'\t' read -r id domain title st dep ver <<< "$row"
    echo "== Next: ${id} =="
    echo "Domain: ${domain}"
    echo "Title:  ${title}"
    echo "Status: ${st}"
    echo "Deps:   ${dep:-—}"
    echo "Verify: ${ver:-—}"
    echo ""
    echo "Brief:  ./scripts/aw task brief ${id}"
    echo "Confirm after discussion: ./scripts/aw task confirm ${id} \"已确认：范围=...；验收=...；非目标=...\""
    echo "Start:  ./scripts/aw task start ${id}"
    ;;
  show)
    aw_gate_coding_ready || exit 1
    atomic="$(aw_resolve_atomic_tasks_file)" || exit 1
    if [[ -z "$TASK_ID" ]]; then
      row="$(aw_task_find_next "${ROOT}/${atomic}")" || exit 1
      IFS=$'\t' read -r TASK_ID _ _ _ _ _ <<< "$row"
    fi
    row="$(aw_task_get_row "${ROOT}/${atomic}" "$TASK_ID")" || {
      echo "error: task not found: $TASK_ID" >&2
      exit 1
    }
    IFS=$'\t' read -r id domain title st dep ver <<< "$row"
    echo "ID:     ${id}"
    echo "Domain: ${domain}"
    echo "Title:  ${title}"
    echo "Status: ${st}"
    echo "Deps:   ${dep}"
    echo "Verify: ${ver}"
    ;;
  brief)
    aw_gate_coding_ready || exit 1
    atomic="$(aw_resolve_atomic_tasks_file)" || exit 1
    if [[ -z "$TASK_ID" ]]; then
      row="$(aw_task_find_next "${ROOT}/${atomic}")" || exit 1
    else
      row="$(aw_task_get_row "${ROOT}/${atomic}" "$TASK_ID")" || {
        echo "error: task not found: $TASK_ID" >&2
        exit 1
      }
    fi
    IFS=$'\t' read -r id domain title st dep ver <<< "$row"
    print_task_brief "$id" "$domain" "$title" "$st" "$dep" "$ver"
    ;;
  confirm)
    [[ -n "$TASK_ID" ]] || { echo "error: aw task confirm <AT-T...> \"已确认：范围=...；验收=...；非目标=...\"" >&2; exit 1; }
    SUMMARY="${1:-}"
    [[ -n "$SUMMARY" ]] || { echo "error: confirmation summary required" >&2; exit 1; }
    if ! aw_task_confirmation_summary_valid "$SUMMARY"; then
      echo "error: confirmation summary is too weak" >&2
      echo "  must include: 已确认 + 范围/scope + 验收/acceptance + 非目标/non-goals" >&2
      echo "  example: ./scripts/aw task confirm ${TASK_ID} \"已确认：范围=用户列表筛选；验收=筛选后列表和分页正确；非目标=不改导出和权限模型\"" >&2
      exit 1
    fi
    aw_gate_coding_ready || exit 1
    atomic="$(aw_resolve_atomic_tasks_file)" || exit 1
    aw_task_get_row "${ROOT}/${atomic}" "$TASK_ID" >/dev/null || {
      echo "error: unknown task $TASK_ID" >&2
      exit 1
    }
    aw_task_mark_requirement_confirmed "$TASK_ID" "$SUMMARY"
    audit_task "$TASK_ID" "task requirement confirmed" "$SUMMARY" "$(aw_task_requirement_confirm_path)"
    echo "ok: ${TASK_ID} requirement confirmed"
    echo "next: ./scripts/aw context plan --task ${TASK_ID} → review allowed files → ./scripts/aw context gate --task ${TASK_ID} → ./scripts/aw task start ${TASK_ID}"
    ;;
  start)
    [[ -n "$TASK_ID" ]] || { echo "error: aw task start <AT-T...>" >&2; exit 1; }
    aw_gate_coding_ready || exit 1
    atomic="$(aw_resolve_atomic_tasks_file)" || exit 1
    aw_task_get_row "${ROOT}/${atomic}" "$TASK_ID" >/dev/null || {
      echo "error: unknown task $TASK_ID" >&2
      exit 1
    }
    aw_task_require_requirement_confirmed "$TASK_ID" || exit 1
    aw_require_github_url_before_coding || exit 1
    code_map_auto_refresh
    "${SCRIPT_DIR}/aw-context.sh" gate --task "$TASK_ID" || {
      echo "error: context plan required before coding for ${TASK_ID}" >&2
      echo "  run: ./scripts/aw context plan --task ${TASK_ID}" >&2
      echo "  review allowed files, then rerun: ./scripts/aw context gate --task ${TASK_ID}" >&2
      exit 1
    }
    code_map_auto_gate "$TASK_ID" || exit 1
    sync_before_task_start "$TASK_ID" || exit 1
    aw_task_set_status "${ROOT}/${atomic}" "$TASK_ID" "进行中"
    aw_task_set_current "$TASK_ID"
    audit_task "$TASK_ID" "task start" "Marked task as 进行中 after requirement confirmation and context gate." "$atomic"
    echo "ok: ${TASK_ID} → 进行中"
    echo "next: ./scripts/aw paste task"
    ;;
  blocked)
    [[ -n "$TASK_ID" ]] || { echo "error: aw task blocked <AT-T...>" >&2; exit 1; }
    aw_gate_coding_ready || exit 1
    atomic="$(aw_resolve_atomic_tasks_file)" || exit 1
    aw_task_get_row "${ROOT}/${atomic}" "$TASK_ID" >/dev/null || {
      echo "error: unknown task $TASK_ID" >&2
      exit 1
    }
    aw_task_set_status "${ROOT}/${atomic}" "$TASK_ID" "阻塞"
    aw_task_set_current "$TASK_ID"
    audit_task "$TASK_ID" "task blocked" "Marked task as 阻塞." "$atomic"
    sync_after_task_blocked "$TASK_ID"
    echo "ok: ${TASK_ID} → 阻塞"
    echo "next: update docs/handoff/PROJECT_HANDOFF.md with blocker"
    ;;
  complete)
    [[ -n "$TASK_ID" ]] || { echo "error: aw task complete <AT-T...>" >&2; exit 1; }
    RUN_E2E=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --run-e2e) RUN_E2E=true ;;
        *) echo "Unknown: $1" >&2; exit 1 ;;
      esac
      shift
    done
    aw_gate_coding_ready || exit 1
    atomic="$(aw_resolve_atomic_tasks_file)" || exit 1
    row="$(aw_task_get_row "${ROOT}/${atomic}" "$TASK_ID")" || {
      echo "error: unknown task $TASK_ID" >&2
      exit 1
    }
    aw_task_require_requirement_confirmed "$TASK_ID" || exit 1
    aw_task_require_started "$TASK_ID" "$atomic" || exit 1
    code_map_auto_refresh
    "${SCRIPT_DIR}/aw-context.sh" affected --task "$TASK_ID" || true
    verify_args=(--task "$TASK_ID")
    $RUN_E2E && verify_args+=(--run-e2e)
    verify_cmd="./scripts/aw verify --task ${TASK_ID}"
    $RUN_E2E && verify_cmd="${verify_cmd} --run-e2e"
    if "${SCRIPT_DIR}/aw-verify.sh" "${verify_args[@]}"; then
      aw_task_set_status "${ROOT}/${atomic}" "$TASK_ID" "已完成"
      aw_task_set_current ""
      code_map_auto_refresh
      audit_task "$TASK_ID" "task complete" "Verification passed; marked task as 已完成." "$atomic"
      sync_after_task_complete "$TASK_ID"
      echo "ok: ${TASK_ID} verify passed → 已完成"
      echo "next: ./scripts/aw compact \"完成 ${TASK_ID}\" --write --snapshot · ./scripts/aw file-index · ./scripts/aw task checkpoint ${TASK_ID} --git yes|no --reason \"...\" --handoff --compact --file-index"
      print_commit_prompt "$TASK_ID"
    else
      aw_task_set_status "${ROOT}/${atomic}" "$TASK_ID" "进行中"
      aw_task_set_current "$TASK_ID"
      append_bug_log "$TASK_ID" "open" "verify failed; task kept 进行中" "$verify_cmd"
      audit_task "$TASK_ID" "task complete failed" "Verification failed; kept task as 进行中 and logged bug." "docs/handoff/AI_BUG_LOG.md"
      echo "logged: docs/handoff/AI_BUG_LOG.md"
      echo "fail: ${TASK_ID} verify failed; task remains 进行中" >&2
      echo "next: fix current task scope, or ./scripts/aw task blocked ${TASK_ID}" >&2
      exit 1
    fi
    ;;
  done)
    [[ -n "$TASK_ID" ]] || { echo "error: aw task done <AT-T...>" >&2; exit 1; }
    RUN_VERIFY=true
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --verify) RUN_VERIFY=true ;;
        --no-verify) echo "error: aw task done no longer allows --no-verify; use aw task complete for verified completion" >&2; exit 1 ;;
        *) echo "Unknown: $1" >&2; exit 1 ;;
      esac
      shift
    done
    atomic="$(aw_resolve_atomic_tasks_file)" || exit 1
    row="$(aw_task_get_row "${ROOT}/${atomic}" "$TASK_ID")" || {
      echo "error: unknown task $TASK_ID" >&2
      exit 1
    }
    aw_task_require_requirement_confirmed "$TASK_ID" || exit 1
    aw_task_require_started "$TASK_ID" "$atomic" || exit 1
    if $RUN_VERIFY; then
      "${SCRIPT_DIR}/aw-verify.sh" --task "$TASK_ID" || exit 1
    fi
    aw_task_set_status "${ROOT}/${atomic}" "$TASK_ID" "已完成"
    aw_task_set_current ""
    audit_task "$TASK_ID" "task done" "Marked task as 已完成${RUN_VERIFY:+ after verify}." "$atomic"
    echo "ok: ${TASK_ID} → 已完成"
    echo "next: ./scripts/aw compact \"完成 ${TASK_ID}\" --write --snapshot · ./scripts/aw file-index · ./scripts/aw task checkpoint ${TASK_ID} --git yes|no --reason \"...\" --handoff --compact --file-index"
    print_commit_prompt "$TASK_ID"
    ;;
  checkpoint)
    [[ -n "$TASK_ID" ]] || { echo "error: aw task checkpoint <AT-T...>" >&2; exit 1; }
    GIT_CHOICE=""
    REASON=""
    HANDOFF=false
    COMPACT=false
    FILE_INDEX=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --git) GIT_CHOICE="${2:-}"; shift 2 ;;
        --reason) REASON="${2:-}"; shift 2 ;;
        --handoff) HANDOFF=true; shift ;;
        --compact) COMPACT=true; shift ;;
        --file-index) FILE_INDEX=true; shift ;;
        *) echo "Unknown: $1" >&2; exit 1 ;;
      esac
    done
    case "$GIT_CHOICE" in yes|no) ;; *) echo "error: --git yes|no is required" >&2; exit 1 ;; esac
    [[ -n "$REASON" ]] || { echo "error: --reason is required for rollback traceability" >&2; exit 1; }
    atomic="$(aw_resolve_atomic_tasks_file)" || exit 1
    st="$(aw_task_status "$TASK_ID" "$atomic" 2>/dev/null || true)"
    [[ "$st" == "已完成" ]] || { echo "error: ${TASK_ID} must be 已完成 before checkpoint (status=${st:-unknown})" >&2; exit 1; }
    $HANDOFF || { echo "error: --handoff required after completion" >&2; exit 1; }
    $COMPACT || { echo "error: --compact required after completion" >&2; exit 1; }
    $FILE_INDEX || { echo "error: --file-index required after completion" >&2; exit 1; }
    [[ -f "${ROOT}/docs/handoff/PROJECT_HANDOFF.md" ]] || { echo "error: missing docs/handoff/PROJECT_HANDOFF.md" >&2; exit 1; }
    [[ -f "${ROOT}/docs/handoff/LAST_AUTO_SNAPSHOT.md" ]] || { echo "error: missing docs/handoff/LAST_AUTO_SNAPSHOT.md; run aw compact --write --snapshot" >&2; exit 1; }
    [[ -f "${ROOT}/docs/handoff/PASTE_IN_NEW_CHAT.txt" ]] || { echo "error: missing docs/handoff/PASTE_IN_NEW_CHAT.txt; run aw compact --write --snapshot" >&2; exit 1; }
    [[ -f "${ROOT}/docs/FILE_INDEX.md" ]] || { echo "error: missing docs/FILE_INDEX.md; run aw file-index" >&2; exit 1; }
    checkpoint_mark "$TASK_ID" "$GIT_CHOICE" "$REASON" "$HANDOFF" "$COMPACT" "$FILE_INDEX"
    audit_task "$TASK_ID" "task completion checkpoint" "git=${GIT_CHOICE}; reason=${REASON}; handoff=${HANDOFF}; compact=${COMPACT}; file-index=${FILE_INDEX}" "$(checkpoint_file)"
    echo "ok: ${TASK_ID} completion checkpoint recorded"
    ;;
  checkpoint-check)
    [[ -n "$TASK_ID" ]] || { echo "error: aw task checkpoint-check <AT-T...>" >&2; exit 1; }
    atomic="$(aw_resolve_atomic_tasks_file)" || exit 1
    st="$(aw_task_status "$TASK_ID" "$atomic" 2>/dev/null || true)"
    if [[ "$st" != "已完成" ]]; then
      echo "ok: ${TASK_ID} checkpoint not required while status=${st:-unknown}"
      exit 0
    fi
    checkpoint_require_resolved "$TASK_ID"
    echo "ok: ${TASK_ID} completion checkpoint resolved"
    ;;
  paste)
    aw_gate_coding_ready || exit 1
    atomic="$(aw_resolve_atomic_tasks_file)" || exit 1
    cid="$(aw_task_current_id 2>/dev/null || true)"
    if [[ -z "$cid" ]]; then
      echo "error: no current task is started; coding prompt is blocked" >&2
      echo "  required flow:" >&2
      echo "    ./scripts/aw next" >&2
      echo "    ./scripts/aw task brief <AT-T>" >&2
      echo "    discuss with engineer until requirements are clear" >&2
      echo "    ./scripts/aw task confirm <AT-T> \"已确认：范围=...；验收=...；非目标=...\"" >&2
      echo "    ./scripts/aw context plan --task <AT-T>" >&2
      echo "    ./scripts/aw context gate --task <AT-T>" >&2
      echo "    ./scripts/aw task start <AT-T>" >&2
      echo "    ./scripts/aw paste task" >&2
      exit 1
    fi
    row="$(aw_task_get_row "${ROOT}/${atomic}" "$cid")" || {
      echo "error: current task not found: ${cid}" >&2
      exit 1
    }
    aw_task_require_requirement_confirmed "$cid" || exit 1
    "${SCRIPT_DIR}/aw-context.sh" gate --task "$cid" >/dev/null || {
      echo "error: context gate not passed for ${cid}; coding prompt is blocked" >&2
      echo "  run: ./scripts/aw context plan --task ${cid}" >&2
      echo "  review allowed files, then: ./scripts/aw context gate --task ${cid}" >&2
      exit 1
    }
    st="$(echo "$row" | awk -F'\t' '{print $4}')"
    if [[ "$st" != "进行中" ]]; then
      echo "error: current task ${cid} is not started (status: ${st}); coding prompt is blocked" >&2
      echo "  run: ./scripts/aw task start ${cid}" >&2
      exit 1
    fi
    IFS=$'\t' read -r id domain title st dep ver <<< "$row"
    print_task_paste "$id" "$domain" "$title" "$st" "$dep" "$ver"
    ;;
  -h|--help) usage 0 ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
