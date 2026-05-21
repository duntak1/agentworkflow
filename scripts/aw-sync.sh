#!/usr/bin/env bash
# Cross-project synchronization for frontend/backend agents via a shared harness directory.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
CFG="${ROOT}/docs/sync/SYNC_CONFIG.md"
CMD="${1:-status}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw sync init <harness-dir> --project <name> --agent <name> [--role frontend|backend|fullstack|tester|reviewer]
  aw sync push [--task AT-T...] [--note "..."]
  aw sync pull [--from <project|all>]
  aw sync baseline
  aw sync board
  aw sync event --type complete|change|block|question|contract|bug|decision|handoff --task AT-T... --to <agent/project> --summary "..." [--impact "..."] [--acceptance "..."] [--risk "..."] [--evidence "..."]
  aw sync change <AT-T> "summary" --to <agent/project> --impact "..." --acceptance "..." [--risk "..."] [--scope "..."]
  aw sync inbox [--from <project|all>]
  aw sync status
  aw sync check

Push writes this project's workflow snapshot to the shared harness.
Pull imports other project snapshots into docs/sync/inbox/ for reading only.
It never overwrites local DSL, Plan, source code, or ledgers.
Baseline shows the shared DSL/Plan locations in the harness. They are edited by explicit engineer approval, not by push/pull.
Board regenerates a shared cross-project task board from pushed frontend/backend ATOMIC task snapshots.
Event records any cross-project event, writes appropriate local ledgers, pushes the snapshot, refreshes the board, and prints GitHub Harness commit guidance.
Change records a development-time requirement change, writes cross-agent handoff, pushes the snapshot, refreshes the board, and prints GitHub Harness commit guidance.
Inbox summarizes peer manifests/events pulled into docs/sync/inbox.
EOF
  exit "${1:-0}"
}

now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

sanitize_name() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/-/g; s/^-+//; s/-+$//'
}

trim_cell() {
  echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

rel_to_abs() {
  local p="$1"
  case "$p" in
    /*) echo "$p" ;;
    *) echo "${ROOT}/${p}" ;;
  esac
}

cfg_value() {
  local key="$1"
  [[ -f "$CFG" ]] || return 1
  awk -F'|' -v key="$key" '
    index($0, "**" key "**") > 0 {
      value=$3
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      print value
      exit
    }
  ' "$CFG"
}

sync_harness() {
  local h
  h="$(cfg_value "同步中心" 2>/dev/null || true)"
  [[ -n "$h" && "$h" != *"____"* ]] || return 1
  rel_to_abs "$h"
}

sync_project() {
  local p
  p="$(cfg_value "项目名" 2>/dev/null || true)"
  [[ -n "$p" && "$p" != *"____"* ]] || return 1
  sanitize_name "$p"
}

sync_agent() {
  cfg_value "Agent" 2>/dev/null || true
}

sync_role() {
  cfg_value "角色" 2>/dev/null || true
}

ensure_configured() {
  if [[ ! -f "$CFG" ]]; then
    echo "error: sync not configured; run: ./scripts/aw sync init <harness-dir> --project <name> --agent <name>" >&2
    return 1
  fi
  local harness project
  harness="$(sync_harness)" || {
    echo "error: docs/sync/SYNC_CONFIG.md missing 同步中心" >&2
    return 1
  }
  project="$(sync_project)" || {
    echo "error: docs/sync/SYNC_CONFIG.md missing 项目名" >&2
    return 1
  }
  mkdir -p "$harness/projects" "$harness/global"
  [[ -n "$project" ]]
}

copy_if_exists() {
  local src="$1" dest="$2"
  [[ -e "$src" ]] || return 0
  mkdir -p "$(dirname "$dest")"
  if [[ -d "$src" ]]; then
    rm -rf "$dest"
    cp -R "$src" "$dest"
  else
    cp "$src" "$dest"
  fi
}

sync_events_file() {
  echo "${ROOT}/docs/sync/SYNC_EVENTS.md"
}

ensure_sync_events() {
  local f
  f="$(sync_events_file)"
  mkdir -p "$(dirname "$f")"
  if [[ ! -f "$f" ]]; then
    cat > "$f" <<'EOF'
# Sync Events

| Time | Type | From | To | Task | Summary | Impact | Acceptance | Risk | Evidence |
|------|------|------|----|------|---------|--------|------------|------|----------|
EOF
  fi
}

append_sync_event() {
  local type="$1" from="$2" to="$3" task="$4" summary="$5" impact="$6" acceptance="$7" risk="$8" evidence="$9"
  ensure_sync_events
  local f tmp now
  f="$(sync_events_file)"
  now="$(now_utc)"
  tmp="$(mktemp)"
  {
    awk 'NR<=4' "$f"
    printf '| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n' \
      "$now" "$type" "$from" "$to" "$task" "$summary" "$impact" "$acceptance" "$risk" "$evidence"
    awk 'NR>4' "$f" || true
  } > "$tmp"
  mv "$tmp" "$f"
}

write_manifest() {
  local out="$1" project="$2" agent="$3" role="$4" task="$5" note="$6"
  cat > "$out" <<EOF
# Sync Manifest

| 字段 | 内容 |
|------|------|
| **项目名** | ${project} |
| **Agent** | ${agent:-待确认} |
| **角色** | ${role:-待确认} |
| **关联任务** | ${task:-—} |
| **同步时间** | $(now_utc) |
| **项目路径** | ${ROOT} |

## 说明

${note:-—}

## 读取规则

- 本快照供其他项目 Agent 阅读，不是对方项目的可直接覆盖源。
- 其他项目执行 \`aw sync pull\` 后，应先阅读 inbox，再决定是否记录 REQ / Bug / Handoff / Contract 变更。
EOF
}

write_task_board() {
  local harness="$1" out project_dir project atomic line id domain title st dep ver nf any=false
  out="${harness}/global/plans/TASK_BOARD.md"
  mkdir -p "$(dirname "$out")"
  cat > "$out" <<EOF
# Shared Frontend / Backend Task Board

| 字段 | 内容 |
|------|------|
| **更新时间** | $(now_utc) |
| **来源** | \`projects/*/docs/plans/ATOMIC_TASKS_*.md\` |

## 使用规则

- 本看板让前端 Agent 和后端 Agent 同时知道双方计划、任务、依赖、状态和验证方式。
- 本看板是同步视图，不是任务真源；任务真源仍在各项目本地 \`docs/plans/ATOMIC_TASKS_*.md\`。
- 修改任务必须先改本项目 Plan / ATOMIC，再 \`aw sync push\` 刷新看板。
- 跨端依赖、阻塞和联调点必须同时写入 handoff / REQ / Bug / contracts，不能只改看板文字。

## 任务矩阵

| Project | ID | Domain | Title | Status | Deps | Verify | Source |
|---------|----|--------|-------|--------|------|--------|--------|
EOF
  for project_dir in "${harness}/projects/"*; do
    [[ -d "$project_dir" ]] || continue
    project="$(basename "$project_dir")"
    for atomic in "${project_dir}"/docs/plans/ATOMIC_TASKS_*.md; do
      [[ -f "$atomic" ]] || continue
      while IFS= read -r line; do
        [[ "$line" =~ ^\|[[:space:]]*AT-T ]] || continue
        nf="$(awk -F'|' '{print NF}' <<< "$line")"
        if [[ "$nf" -ge 8 ]]; then
          IFS='|' read -r _ id domain title st dep ver _ <<< "$line"
        else
          domain="—"
          IFS='|' read -r _ id title st dep ver _ <<< "$line"
        fi
        id="$(trim_cell "${id:-}")"
        domain="$(trim_cell "${domain:-—}")"
        title="$(trim_cell "${title:-}")"
        st="$(trim_cell "${st:-}")"
        dep="$(trim_cell "${dep:-—}")"
        ver="$(trim_cell "${ver:-—}")"
        [[ "$id" =~ ^AT-T ]] || continue
        printf '| %s | %s | %s | %s | %s | %s | %s | `%s` |\n' \
          "$project" "$id" "$domain" "$title" "$st" "$dep" "$ver" \
          "projects/${project}/docs/plans/$(basename "$atomic")" >> "$out"
        any=true
      done < "$atomic"
    done
  done
  if ! $any; then
    echo "| — | — | — | 暂无已 push 的 ATOMIC 任务 | — | — | — | — |" >> "$out"
  fi
  cat >> "$out" <<'EOF'

## 开始任务前检查

1. 先读本看板，确认对方任务状态和跨端依赖。
2. 如果自己的任务依赖对方未完成任务，先写 handoff 或标记 blocked，不要猜。
3. 如果发现本项目 ATOMIC 与本看板不一致，以本项目 ATOMIC 为真源，重新 `aw sync push` 刷新看板。
4. 如果发现共享 DSL / 协作 Plan 与本地 Plan 冲突，先走需求变更和计划变更确认流程。
EOF
}

init_sync() {
  local harness="" project="" agent="" role="agent"
  [[ $# -gt 0 ]] || usage 1
  harness="$1"
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --project) project="${2:-}"; shift 2 ;;
      --agent) agent="${2:-}"; shift 2 ;;
      --role) role="${2:-}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  [[ -n "$harness" && -n "$project" && -n "$agent" ]] || {
    echo "error: <harness-dir>, --project and --agent are required" >&2
    usage 1
  }
  local abs
  abs="$(rel_to_abs "$harness")"
  mkdir -p "${ROOT}/docs/sync/inbox" "${ROOT}/docs/sync/outbox" "$abs/projects" "$abs/global/contracts" "$abs/global/decisions" "$abs/global/dsl" "$abs/global/plans"
  [[ -f "$abs/global/dsl/README.md" ]] || cat > "$abs/global/dsl/README.md" <<'EOF'
# Shared DSL Baseline

这里存放前后端共同确认的共享 DSL 基线，用于消除两个项目各自拆 DSL 造成的歧义。

- 只放跨前后端共同事实：需求、页面/模块、交互、事件、接口边界、权限、错误码、验收、非目标。
- 前端/后端本地 `docs/dsl/` 可以保留执行派生 DSL，但不能与本目录的共享基线冲突。
- 更新本目录前必须工程师确认；更新后双方都需要 `git pull` 或读取同步中心，并把影响回写到本项目 REQ / DSL / Plan / ATOMIC。
EOF
  [[ -f "$abs/global/plans/README.md" ]] || cat > "$abs/global/plans/README.md" <<'EOF'
# Shared Collaboration Plan

这里存放前后端共同确认的协作 Plan 基线，用于描述跨端里程碑、依赖顺序、接口联调点、阻塞关系和验收门槛。

- 本目录不是前端或后端的本地执行计划替代品。
- 前端项目仍维护 `docs/plans/PLAN_*_FRONTEND.md` 和前端 ATOMIC。
- 后端项目仍维护 `docs/plans/PLAN_*_BACKEND.md` 和后端 ATOMIC。
- 如果共享 Plan 变化，双方必须同步更新各自本地 Plan / ATOMIC，并重新确认受影响任务。
- `TASK_BOARD.md` 是由各项目 push 后的 ATOMIC 快照汇总出的共享任务看板，用于让前后端 Agent 同时知道双方计划和任务状态。
EOF
  [[ -f "$abs/global/contracts/README.md" ]] || cat > "$abs/global/contracts/README.md" <<'EOF'
# Shared Contracts

这里存放跨前后端共同确认的接口契约、字段字典、枚举、错误码和权限矩阵。

本目录内容需要与共享 DSL 的边界文件、后端 SERVICE_CATALOG、前端 API client 保持一致。
EOF
  cat > "$CFG" <<EOF
# Sync Config

| 字段 | 内容 |
|------|------|
| **同步中心** | ${abs} |
| **项目名** | $(sanitize_name "$project") |
| **Agent** | ${agent} |
| **角色** | ${role} |
| **初始化时间** | $(now_utc) |

## 边界

- \`aw sync push\` 将本项目 workflow 快照写入同步中心。
- \`aw sync pull\` 只把其他项目快照拉到 \`docs/sync/inbox/\`，不会覆盖本项目 DSL、Plan、代码或流水。
- 共享 DSL / 协作 Plan 放在同步中心 \`global/dsl/\` 和 \`global/plans/\`，作为前后端共同基线；本项目 DSL / Plan 是执行派生，不得与共同基线冲突。
- 跨项目接口、字段、权限、错误码和发布依赖变更，应在本项目通过 \`aw req change\` / \`aw bug add\` / \`aw agents handoff\` 落账后再 push。
EOF
  cat > "${ROOT}/docs/sync/README.md" <<'EOF'
# Cross-project Sync

本目录保存跨前后端项目同步配置和只读 inbox。

- `SYNC_CONFIG.md`：同步中心、项目名、Agent 和角色。
- `inbox/`：从其他项目拉取的快照，只读参考，不是本项目真源。
- `outbox/`：本项目最近一次 push 的本地副本。

共享基线：

- 同步中心 `global/dsl/`：前后端共同确认的 DSL 基线。
- 同步中心 `global/plans/`：前后端共同确认的协作 Plan。
- 本项目 `docs/dsl/` 和 `docs/plans/` 是执行派生，不能与共享基线冲突。

使用：

```bash
./scripts/aw sync status
./scripts/aw sync baseline
./scripts/aw sync board
./scripts/aw sync push --task AT-T...
./scripts/aw sync pull
./scripts/aw sync check
```
EOF
  echo "created: docs/sync/SYNC_CONFIG.md"
  echo "harness: ${abs}"
  aw_refresh_engineering_index
}

push_sync() {
  local task="" note=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --task) task="${2:-}"; shift 2 ;;
      --note) note="${2:-}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  ensure_configured
  local harness project agent role dest local_out
  harness="$(sync_harness)"
  project="$(sync_project)"
  agent="$(sync_agent)"
  role="$(sync_role)"
  dest="${harness}/projects/${project}"
  local_out="${ROOT}/docs/sync/outbox/${project}"
  rm -rf "$dest" "$local_out"
  mkdir -p "$dest" "$local_out"
  write_manifest "${dest}/MANIFEST.md" "$project" "$agent" "$role" "$task" "$note"
  copy_if_exists "${ROOT}/docs/dsl" "${dest}/docs/dsl"
  copy_if_exists "${ROOT}/docs/plans" "${dest}/docs/plans"
  copy_if_exists "${ROOT}/docs/requirements" "${dest}/docs/requirements"
  copy_if_exists "${ROOT}/docs/handoff" "${dest}/docs/handoff"
  copy_if_exists "${ROOT}/docs/agents" "${dest}/docs/agents"
  copy_if_exists "${ROOT}/docs/sync/SYNC_EVENTS.md" "${dest}/docs/sync/SYNC_EVENTS.md"
  copy_if_exists "${ROOT}/docs/quality/test-plans" "${dest}/docs/quality/test-plans"
  copy_if_exists "${ROOT}/docs/security" "${dest}/docs/security"
  copy_if_exists "${ROOT}/docs/SERVICE_CATALOG.md" "${dest}/docs/SERVICE_CATALOG.md"
  copy_if_exists "${ROOT}/docs/PROJECT_CONFIG.md" "${dest}/docs/PROJECT_CONFIG.md"
  copy_if_exists "${ROOT}/docs/ENGINEERING_RULES.md" "${dest}/docs/ENGINEERING_RULES.md"
  copy_if_exists "${ROOT}/docs/FILE_INDEX.md" "${dest}/docs/FILE_INDEX.md"
  copy_if_exists "${ROOT}/reference/manifest.yaml" "${dest}/reference/manifest.yaml"
  cp -R "$dest/." "$local_out/"
  write_task_board "$harness"
  echo "pushed: ${project} → ${dest}"
  echo "local outbox: docs/sync/outbox/${project}"
  echo "task board: ${harness}/global/plans/TASK_BOARD.md"
  aw_refresh_engineering_index
}

pull_sync() {
  local from="all"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --from) from="${2:-all}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  ensure_configured
  local harness project inbox src name count=0
  harness="$(sync_harness)"
  project="$(sync_project)"
  inbox="${ROOT}/docs/sync/inbox"
  mkdir -p "$inbox"
  if [[ "$from" == "all" ]]; then
    for src in "${harness}/projects/"*; do
      [[ -d "$src" ]] || continue
      name="$(basename "$src")"
      [[ "$name" == "$project" ]] && continue
      rm -rf "${inbox}/${name}"
      cp -R "$src" "${inbox}/${name}"
      echo "pulled: ${name} → docs/sync/inbox/${name}"
      count=$((count + 1))
    done
  else
    name="$(sanitize_name "$from")"
    src="${harness}/projects/${name}"
    [[ -d "$src" ]] || { echo "error: no synced project: ${name}" >&2; return 1; }
    rm -rf "${inbox}/${name}"
    cp -R "$src" "${inbox}/${name}"
    echo "pulled: ${name} → docs/sync/inbox/${name}"
    count=1
  fi
  [[ "$count" -gt 0 ]] || echo "info: no peer snapshots found"
  aw_refresh_engineering_index
}

status_sync() {
  if [[ ! -f "$CFG" ]]; then
    echo "sync: not configured"
    echo "next: ./scripts/aw sync init ../project-harness --project frontend --agent frontend-agent"
    return 0
  fi
  local harness project
  harness="$(sync_harness 2>/dev/null || true)"
  project="$(sync_project 2>/dev/null || true)"
  echo "== sync status =="
  echo "project: ${project:-?}"
  echo "agent: $(sync_agent)"
  echo "role: $(sync_role)"
  echo "harness: ${harness:-?}"
  if [[ -n "$harness" && -d "${harness}/projects" ]]; then
    echo "projects:"
    find "${harness}/projects" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sed 's#^.*/#  - #' | sort || true
  else
    echo "projects: —"
  fi
  echo "inbox: docs/sync/inbox"
}

baseline_sync() {
  ensure_configured
  local harness
  harness="$(sync_harness)"
  mkdir -p "${harness}/global/dsl" "${harness}/global/plans" "${harness}/global/contracts" "${harness}/global/decisions"
  echo "== sync baseline =="
  echo "shared DSL: ${harness}/global/dsl"
  echo "shared Plan: ${harness}/global/plans"
  echo "shared contracts: ${harness}/global/contracts"
  echo "shared decisions: ${harness}/global/decisions"
  echo "shared task board: ${harness}/global/plans/TASK_BOARD.md"
  echo
  echo "Rule: shared DSL/Plan are the cross-project baseline. Local docs/dsl and docs/plans are execution derivatives."
  echo "Rule: update the shared baseline only after engineer approval, then update each project's REQ / DSL / Plan / ATOMIC as needed."
}

board_sync() {
  ensure_configured
  local harness board
  harness="$(sync_harness)"
  write_task_board "$harness"
  board="${harness}/global/plans/TASK_BOARD.md"
  echo "== sync board =="
  echo "path: ${board}"
  echo
  sed -n '1,80p' "$board"
}

print_harness_git_guidance() {
  local harness="$1" project="$2" task="$3" summary="$4" type="$5"
  cat <<EOF

== GitHub Harness checkpoint ==
If this project-harness is shared across computers, ask the engineer before running:

cd "${harness}"
git status
git add .
git commit -m "sync(${project}): ${type} ${task} ${summary}"
git push
EOF
}

event_sync() {
  local type="" task="" to="" summary="" impact="—" acceptance="—" risk="—" evidence="" scope="" done="" todo=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --type) type="${2:-}"; shift 2 ;;
      --task|--related) task="${2:-}"; shift 2 ;;
      --to) to="${2:-}"; shift 2 ;;
      --summary|--note) summary="${2:-}"; shift 2 ;;
      --impact) impact="${2:-}"; shift 2 ;;
      --acceptance) acceptance="${2:-}"; shift 2 ;;
      --risk) risk="${2:-}"; shift 2 ;;
      --evidence) evidence="${2:-}"; shift 2 ;;
      --scope) scope="${2:-}"; shift 2 ;;
      --done) done="${2:-}"; shift 2 ;;
      --todo) todo="${2:-}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  case "$type" in complete|change|block|question|contract|bug|decision|handoff) ;;
    *) echo "error: --type must be complete|change|block|question|contract|bug|decision|handoff" >&2; exit 1 ;;
  esac
  [[ -n "$task" && -n "$to" && -n "$summary" ]] || {
    echo "error: aw sync event requires --type --task --to --summary" >&2
    exit 1
  }
  ensure_configured
  local from project harness note
  from="$(sync_agent)"
  [[ -n "$from" ]] || from="$(sync_project)"
  project="$(sync_project)"
  harness="$(sync_harness)"
  [[ -n "$scope" ]] || scope="$task"
  [[ -n "$evidence" ]] || evidence="docs/sync/SYNC_EVENTS.md; docs/agents/AGENT_HANDOFFS.md; docs/requirements/INDEX.md; docs/handoff/AI_BUG_LOG.md; docs/SERVICE_CATALOG.md"

  echo "== sync event =="
  echo "type: ${type}"
  echo "task: ${task}"
  echo "to: ${to}"

  case "$type" in
    change)
      [[ "$impact" != "—" && "$acceptance" != "—" ]] || { echo "error: change events require --impact and --acceptance" >&2; exit 1; }
      "${SCRIPT_DIR}/aw-req.sh" change "$task" "$summary" --impact "$impact" --acceptance "$acceptance"
      [[ -n "$done" ]] || done="记录需求变更：${summary}"
      [[ -n "$todo" ]] || todo="请评估并在本项目重新落 REQ / DSL / Plan / ATOMIC：${summary}"
      ;;
    bug)
      "${SCRIPT_DIR}/aw-bug.sh" add "$summary" --source chat --scope "$task" --evidence "$evidence"
      [[ -n "$done" ]] || done="记录跨端 Bug：${summary}"
      [[ -n "$todo" ]] || todo="请评估并在本项目记录 / 修复 / 复测：${summary}"
      ;;
    block)
      "${SCRIPT_DIR}/aw-task.sh" blocked "$task" >/dev/null || true
      [[ -n "$done" ]] || done="任务阻塞：${summary}"
      [[ -n "$todo" ]] || todo="请处理阻塞项并同步结果：${summary}"
      ;;
    complete)
      [[ -n "$done" ]] || done="任务完成并同步：${summary}"
      [[ -n "$todo" ]] || todo="请检查是否解除依赖、是否可以开始联调或采纳变更。"
      ;;
    question)
      [[ -n "$done" ]] || done="提出跨端问题：${summary}"
      [[ -n "$todo" ]] || todo="请回复结论、风险和证据；不要只在聊天里口头答复。"
      ;;
    contract)
      [[ -n "$done" ]] || done="接口契约同步：${summary}"
      [[ -n "$todo" ]] || todo="请检查 SERVICE_CATALOG / contracts / API client 是否需要更新。"
      ;;
    decision)
      [[ -n "$done" ]] || done="跨端决策同步：${summary}"
      [[ -n "$todo" ]] || todo="请在本项目采纳决策并回写 DSL / Plan / ATOMIC（如受影响）。"
      ;;
    handoff)
      [[ -n "$done" ]] || done="交接同步：${summary}"
      [[ -n "$todo" ]] || todo="请读取证据并决定是否采纳。"
      ;;
  esac

  append_sync_event "$type" "$from" "$to" "$task" "$summary" "$impact" "$acceptance" "$risk" "$evidence"

  "${SCRIPT_DIR}/aw-agents.sh" handoff \
    --from "$from" \
    --to "$to" \
    --related "$task" \
    --scope "$scope" \
    --done "$done" \
    --todo "$todo" \
    --risk "$risk" \
    --evidence "$evidence"

  note="${type}: ${summary}"
  push_sync --task "$task" --note "$note"
  board_sync | sed -n '1,40p'
  print_harness_git_guidance "$harness" "$project" "$task" "$summary" "$type"
  cat <<EOF

Peer adoption:
1. cd <peer-project-harness> && git pull
2. cd <peer-project> && ./scripts/aw sync pull --from ${project}
3. ./scripts/aw sync inbox --from ${project}
4. ./scripts/aw sync board
5. If the event changes local scope, record adoption locally with REQ / Bug / Plan change, then re-run task brief / confirm.
EOF
}

change_sync() {
  local task_id="${1:-}" summary="${2:-}"
  [[ -n "$task_id" && -n "$summary" ]] || {
    echo "error: aw sync change <AT-T> \"summary\" --to <agent/project> --impact \"...\" --acceptance \"...\"" >&2
    usage 1
  }
  shift 2
  local to="" impact="" acceptance="" risk="—" scope="" done="" todo="" evidence=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --to) to="${2:-}"; shift 2 ;;
      --impact) impact="${2:-}"; shift 2 ;;
      --acceptance) acceptance="${2:-}"; shift 2 ;;
      --risk) risk="${2:-}"; shift 2 ;;
      --scope) scope="${2:-}"; shift 2 ;;
      --done) done="${2:-}"; shift 2 ;;
      --todo) todo="${2:-}"; shift 2 ;;
      --evidence) evidence="${2:-}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  [[ -n "$to" && -n "$impact" && -n "$acceptance" ]] || {
    echo "error: --to, --impact and --acceptance are required" >&2
    exit 1
  }

  ensure_configured
  local from harness project note
  from="$(sync_agent)"
  [[ -n "$from" ]] || from="$(sync_project)"
  project="$(sync_project)"
  harness="$(sync_harness)"
  [[ -n "$scope" ]] || scope="$task_id"
  [[ -n "$done" ]] || done="记录需求变更：${summary}"
  [[ -n "$todo" ]] || todo="请评估并在本项目重新落 REQ / DSL / Plan / ATOMIC：${summary}"
  [[ -n "$evidence" ]] || evidence="docs/requirements/INDEX.md; docs/dsl/; docs/plans/; docs/agents/AGENT_HANDOFFS.md"
  note="需求变更同步：${summary}"

  event_sync --type change --task "$task_id" --to "$to" --summary "$summary" --impact "$impact" --acceptance "$acceptance" --risk "$risk" --scope "$scope" --done "$done" --todo "$todo" --evidence "$evidence"
}

inbox_sync() {
  local from="all"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --from) from="${2:-all}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  ensure_configured
  local inbox="${ROOT}/docs/sync/inbox" target event_file project_dir name
  echo "== sync inbox =="
  if [[ ! -d "$inbox" ]]; then
    echo "info: no inbox yet; run aw sync pull --from <peer|all>"
    return 0
  fi
  if [[ "$from" == "all" ]]; then
    for project_dir in "$inbox"/*; do
      [[ -d "$project_dir" ]] || continue
      name="$(basename "$project_dir")"
      echo "## ${name}"
      [[ -f "${project_dir}/MANIFEST.md" ]] && sed -n '1,24p' "${project_dir}/MANIFEST.md"
      event_file="${project_dir}/docs/sync/SYNC_EVENTS.md"
      if [[ -f "$event_file" ]]; then
        echo ""
        echo "Recent events:"
        grep -E '^\| .* \|' "$event_file" | sed -n '1,8p'
      else
        echo "Recent events: —"
      fi
      echo ""
    done
  else
    target="${inbox}/$(sanitize_name "$from")"
    [[ -d "$target" ]] || { echo "error: no inbox project: $from" >&2; return 1; }
    [[ -f "${target}/MANIFEST.md" ]] && sed -n '1,40p' "${target}/MANIFEST.md"
    event_file="${target}/docs/sync/SYNC_EVENTS.md"
    if [[ -f "$event_file" ]]; then
      echo ""
      echo "Recent events:"
      grep -E '^\| .* \|' "$event_file" | sed -n '1,12p'
    else
      echo "Recent events: —"
    fi
  fi
}

check_sync() {
  local err=0
  echo "== sync check =="
  if [[ ! -f "$CFG" ]]; then
    echo "missing  docs/sync/SYNC_CONFIG.md (run: aw sync init)" >&2
    return 1
  fi
  echo "ok  docs/sync/SYNC_CONFIG.md"
  local harness project
  harness="$(sync_harness 2>/dev/null || true)"
  project="$(sync_project 2>/dev/null || true)"
  if [[ -n "$harness" && -d "$harness" ]]; then
    echo "ok  harness: $harness"
  else
    echo "missing  harness directory" >&2
    err=1
  fi
  if [[ -n "$project" ]]; then
    echo "ok  project: $project"
  else
    echo "missing  project name" >&2
    err=1
  fi
  if [[ -n "$harness" && -n "$project" && -f "${harness}/projects/${project}/MANIFEST.md" ]]; then
    echo "ok  pushed snapshot: ${harness}/projects/${project}/MANIFEST.md"
  else
    echo "warn  no pushed snapshot yet (run: aw sync push)" >&2
  fi
  if [[ -n "$harness" && -d "${harness}/global/dsl" && -d "${harness}/global/plans" ]]; then
    echo "ok  shared baseline: ${harness}/global/dsl and ${harness}/global/plans"
  else
    echo "warn  shared baseline directories missing (run: aw sync baseline)" >&2
  fi
  if [[ -n "$harness" && -f "${harness}/global/plans/TASK_BOARD.md" ]]; then
    echo "ok  shared task board: ${harness}/global/plans/TASK_BOARD.md"
  else
    echo "warn  shared task board missing (run: aw sync board or aw sync push)" >&2
  fi
  if [[ -d "${ROOT}/docs/sync/inbox" ]]; then
    echo "ok  inbox: docs/sync/inbox"
  else
    echo "missing  inbox directory" >&2
    err=1
  fi
  return "$err"
}

case "$CMD" in
  init) init_sync "$@" ;;
  push) push_sync "$@" ;;
  pull) pull_sync "$@" ;;
  baseline) baseline_sync "$@" ;;
  board) board_sync "$@" ;;
  event) event_sync "$@" ;;
  change) change_sync "$@" ;;
  inbox) inbox_sync "$@" ;;
  status) status_sync "$@" ;;
  check) check_sync "$@" ;;
  -h|--help|help) usage 0 ;;
  *) echo "Unknown sync command: $CMD" >&2; usage 1 ;;
esac
