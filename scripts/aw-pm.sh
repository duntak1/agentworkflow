#!/usr/bin/env bash
# PM Agent lifecycle orchestration for sync-center based product delivery.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
PM_TPL="${TEMPLATES}/pm"
CMD="${1:-start}"
shift || true

now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

sanitize_name() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/-/g; s/^-+//; s/-+$//'
}

usage() {
  cat <<'EOF'
Usage:
  aw pm start
  aw pm init [<harness-dir>] [--project <name>] [--agent <name>] [--role pm]
  aw pm intake-check [--write]
  aw pm plan [--write] [--from <global-dsl-dir>]
  aw pm dashboard [--write]
  aw pm assignments --role frontend|admin|backend|all
  aw pm gate [--strict]
  aw pm lifecycle [--write]
  aw pm design init
  aw pm design import --file <path> [--req <REQ-ID>] [--title "..."] [--summary "..."]
  aw pm design link --req <REQ-ID> --source <path> [--export <path>] [--screenshot <path>] [--summary "..."]
  aw pm design change --file <path> --summary "..." [--req <REQ-ID>] [--tasks "..."]
  aw pm change --title "..." [--type 口述新增|研发中变更|设计稿变更|...] [--impact "..."] [--acceptance "..."]
  aw pm dispatch [--write]
  aw pm check

PM commands manage the shared sync center global/ area. They do not write business code.
EOF
  exit "${1:-0}"
}

pm_start() {
  cat <<'EOF'
== PM Agent 向导 ==

你要做哪类工作？

1. 新项目立项                  → aw pm init <project-harness>
2. 已有项目接入                → aw project scan → aw pm init <project-harness>
3. 上传/整理参考资料           → 放入 global/references/ 后运行 aw pm intake-check --write
4. 同步 Pencil 设计稿           → aw pm design import --file <xxx.pen> --req <REQ-ID>
5. 生成或更新 DSL              → 先确认资料体检，再生成 global/dsl/*
6. DSL 已审核，生成三端研发计划 → aw pm plan --write
7. 派发任务给前台/后台/后端    → aw pm assignments --role frontend|admin|backend
8. 新增需求/需求变更           → aw pm change --title "..."
9. 查看项目进度看板            → aw pm dashboard --write
10. 查看阻塞和前后端对接问题   → global/dashboard/BLOCKERS.md + global/contracts/INTEGRATION_MATRIX.md
11. 测试 / UAT / 发布 / 复盘    → aw pm lifecycle --write && aw pm gate --strict

PM 不需要记底层同步命令；需要跨项目时，各端 Agent 再执行 aw sync pull / aw sync push。
EOF
}

cfg_harness_path() {
  local from_sync from_config
  if aw_sync_configured; then
    from_sync="$(awk -F'|' '/\*\*同步中心\*\*/ {gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit}' "${ROOT}/docs/sync/SYNC_CONFIG.md" 2>/dev/null || true)"
    [[ -n "$from_sync" ]] && echo "$from_sync" && return 0
  fi
  from_config="$(aw_project_config_field "同步中心路径" 2>/dev/null || true)"
  [[ -n "$from_config" && "$from_config" != *"____"* ]] && echo "$from_config" && return 0
  return 1
}

abs_path() {
  local p="$1"
  case "$p" in
    /*) echo "$p" ;;
    *) echo "${ROOT}/${p}" ;;
  esac
}

pm_harness() {
  local explicit="${1:-}"
  if [[ -n "$explicit" ]]; then
    abs_path "$explicit"
    return 0
  fi
  cfg_harness_path || {
    echo "error: PM sync center not configured. Run: ./scripts/aw pm init <project-harness-path>" >&2
    return 1
  }
}

copy_pm_template() {
  local src="$1" dest="$2"
  if [[ -f "$dest" ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ -f "$src" ]]; then
    cp "$src" "$dest"
  else
    printf '# %s\n\n待确认\n' "$(basename "$dest" .md)" > "$dest"
  fi
}

ensure_pm_tree() {
  local harness="$1"
  mkdir -p \
    "${harness}/global/product" \
    "${harness}/global/references/prd" \
    "${harness}/global/references/ui" \
    "${harness}/global/references/tech" \
    "${harness}/global/references/api" \
    "${harness}/global/references/business" \
    "${harness}/global/references/assets" \
    "${harness}/global/references/design/pencil/source" \
    "${harness}/global/references/design/pencil/exports" \
    "${harness}/global/references/design/pencil/screenshots" \
    "${harness}/global/requirements/changes" \
    "${harness}/global/architecture" \
    "${harness}/global/dsl" \
    "${harness}/global/plans" \
    "${harness}/global/dispatch" \
    "${harness}/global/contracts" \
    "${harness}/global/delivery" \
    "${harness}/global/integration" \
    "${harness}/global/quality" \
    "${harness}/global/release" \
    "${harness}/global/analytics" \
    "${harness}/global/knowledge" \
    "${harness}/global/dashboard" \
    "${harness}/global/inbox" \
    "${harness}/global/outbox"

  local rel
  while IFS= read -r rel; do
    copy_pm_template "${PM_TPL}/${rel}" "${harness}/global/${rel}"
  done <<'EOF'
product/PRODUCT_BRIEF.md
product/STAKEHOLDERS.md
product/MVP_SCOPE.md
product/SUCCESS_METRICS.md
product/COMPETITOR_NOTES.md
references/README.md
references/design/DESIGN_INDEX.md
references/design/DESIGN_REVIEW.md
references/design/DESIGN_FREEZE.md
references/design/DESIGN_QA.md
references/design/DESIGN_CHANGELOG.md
references/design/pencil/README.md
requirements/BACKLOG.md
requirements/PRIORITIZATION.md
requirements/REVIEW_LOG.md
requirements/ACCEPTANCE_RECORD.md
architecture/ARCHITECTURE_DECISION_RECORDS.md
architecture/TECH_DESIGN.md
architecture/DATA_MODEL.md
architecture/AUTH_MODEL.md
architecture/INTEGRATION_DESIGN.md
dsl/INDEX.md
dsl/DSL_REQUIREMENTS.md
dsl/DSL_PAGES.md
dsl/DSL_INTERACTIONS.md
dsl/DSL_EVENTS.md
dsl/DSL_BOUNDARIES.md
dsl/DSL_ACCEPTANCE.md
plans/GLOBAL_PLAN.md
plans/FRONTEND_PLAN.md
plans/ADMIN_FRONTEND_PLAN.md
plans/BACKEND_PLAN.md
plans/ATOMIC_TASKS.md
dispatch/TASK_BOARD.md
dispatch/FRONTEND_ASSIGNMENTS.md
dispatch/ADMIN_ASSIGNMENTS.md
dispatch/BACKEND_ASSIGNMENTS.md
contracts/INTEGRATION_MATRIX.md
delivery/ITERATION_PLAN.md
delivery/DAILY_SYNC.md
delivery/DEPENDENCY_GRAPH.md
delivery/REWORK_LOG.md
delivery/DELIVERY_RISKS.md
integration/INTEGRATION_PLAN.md
integration/MOCK_STRATEGY.md
integration/INTEGRATION_ISSUES.md
integration/INTEGRATION_ACCEPTANCE.md
quality/TEST_STRATEGY.md
quality/TEST_CASES.md
quality/REGRESSION_PLAN.md
quality/UAT_RECORD.md
quality/QUALITY_REPORT.md
release/RELEASE_PLAN.md
release/GO_LIVE_CHECKLIST.md
release/ROLLBACK_PLAN.md
release/POST_RELEASE_REVIEW.md
analytics/METRICS_PLAN.md
analytics/EVENT_TRACKING.md
analytics/FUNNEL.md
analytics/METRICS_REVIEW.md
knowledge/PRODUCT_KNOWLEDGE.md
knowledge/TECH_KNOWLEDGE.md
knowledge/FAQ.md
knowledge/DECISION_LOG.md
dashboard/PROJECT_DASHBOARD.md
dashboard/LIFECYCLE_BOARD.md
dashboard/PROGRESS_BOARD.md
dashboard/BLOCKERS.md
dashboard/RISKS.md
dashboard/CHANGE_REQUESTS.md
dashboard/EXECUTIVE_SUMMARY.md
dashboard/DECISION_BOARD.md
EOF
}

pm_init() {
  local harness="" project="product" agent="pm-agent" role="pm"
  if [[ $# -gt 0 && "${1:-}" != --* ]]; then
    harness="$1"
    shift
  fi
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --project) project="${2:-}"; shift 2 ;;
      --agent) agent="${2:-}"; shift 2 ;;
      --role) role="${2:-}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  harness="$(pm_harness "$harness")"
  ensure_pm_tree "$harness"
  cat > "${harness}/global/PM_CENTER.md" <<EOF
# PM Sync Center

| 字段 | 内容 |
|------|------|
| **项目名** | $(sanitize_name "$project") |
| **PM Agent** | ${agent} |
| **角色** | ${role} |
| **初始化时间** | $(now_utc) |
| **同步中心路径** | ${harness} |

## 使用方式

- PM 上传资料到 \`global/references/\`。
- PM 同步 Pencil 到 \`global/references/design/pencil/\`。
- PM Agent 维护 \`global/dsl/\`、\`global/plans/\`、\`global/dispatch/\`、\`global/dashboard/\`。
- 三端 Agent 从 \`global/dispatch/*_ASSIGNMENTS.md\` 认领任务，并通过 \`aw sync pull/push\` 同步状态。
EOF
  echo "created/ok: PM sync center"
  echo "path: ${harness}"
  echo "next:"
  echo "  1. Upload PRD/UI/tech/API/business/design files under ${harness}/global/references/"
  echo "  2. ./scripts/aw pm intake-check --write"
  echo "  3. ./scripts/aw pm dashboard --write"
}

count_files() {
  local dir="$1"
  [[ -d "$dir" ]] || { echo 0; return 0; }
  find "$dir" -type f ! -name '.DS_Store' ! -name 'README.md' ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' '
}

pm_intake_check() {
  local write=false harness
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --write) write=true; shift ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  harness="$(pm_harness "")"
  ensure_pm_tree "$harness"
  local base="${harness}/global/references"
  local prd ui tech api business pencil exports screenshots out
  prd="$(count_files "${base}/prd")"
  ui="$(count_files "${base}/ui")"
  tech="$(count_files "${base}/tech")"
  api="$(count_files "${base}/api")"
  business="$(count_files "${base}/business")"
  pencil="$(count_files "${base}/design/pencil/source")"
  exports="$(count_files "${base}/design/pencil/exports")"
  screenshots="$(count_files "${base}/design/pencil/screenshots")"
  out="$(cat <<EOF
# PM Intake Check

| 资料类型 | 数量 | 状态 |
|----------|------|------|
| PRD | ${prd} | $([[ "$prd" -gt 0 ]] && echo "ok" || echo "缺失") |
| UI 规范 / 截图 | ${ui} | $([[ "$ui" -gt 0 ]] && echo "ok" || echo "缺失") |
| 技术资料 | ${tech} | $([[ "$tech" -gt 0 ]] && echo "ok" || echo "缺失") |
| 接口资料 | ${api} | $([[ "$api" -gt 0 ]] && echo "ok" || echo "缺失") |
| 业务规则 | ${business} | $([[ "$business" -gt 0 ]] && echo "ok" || echo "缺失") |
| Pencil 源文件 | ${pencil} | $([[ "$pencil" -gt 0 ]] && echo "ok" || echo "缺失") |
| Pencil 导出物 | ${exports} | $([[ "$exports" -gt 0 ]] && echo "ok" || echo "建议补充") |
| Pencil 截图 | ${screenshots} | $([[ "$screenshots" -gt 0 ]] && echo "ok" || echo "建议补充") |

## 建议补充

- 接口资料为 0 时，生成 Plan 前必须标记接口待确认，并进入 Contract 草案流程。
- 业务规则为 0 时，权限、状态机、枚举和异常态必须在 DSL 中标记待确认。
- Pencil 源文件存在但导出物为 0 时，前端 Agent 不应直接解析 .pen，应先通过 Pencil 工具导出或截图。

## 下一步

1. 资料足够：生成 DSL 草案并输出摘要。
2. 资料不足：补充资料后重新运行 \`aw pm intake-check --write\`。
3. 允许先生成草案：在 DSL 中保留待确认项。
EOF
)"
  printf '%s\n' "$out"
  if $write; then
    printf '%s\n' "$out" > "${base}/INTAKE_CHECK.md"
    echo "written: ${base}/INTAKE_CHECK.md"
  fi
}

task_counts_for_role() {
  local file="$1"
  local total done progress blocked
  total="$(awk '/^\|/ && $0 !~ /^\|[- ]+\|/ && $0 !~ /ID.*状态/ && $0 ~ /\|/ {c++} END{print c+0}' "$file" 2>/dev/null || echo 0)"
  done="$(grep -c '已完成' "$file" 2>/dev/null || true)"
  progress="$(grep -c '进行中' "$file" 2>/dev/null || true)"
  blocked="$(grep -c '阻塞' "$file" 2>/dev/null || true)"
  echo "${done}|${total}|${progress}|${blocked}"
}

pm_dashboard() {
  local write=false harness dash progress
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --write) write=true; shift ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  harness="$(pm_harness "")"
  ensure_pm_tree "$harness"
  local f a b c fd ft fp fb ad at ap ab bd bt bp bb blockers changes
  f="${harness}/global/dispatch/FRONTEND_ASSIGNMENTS.md"
  a="${harness}/global/dispatch/ADMIN_ASSIGNMENTS.md"
  b="${harness}/global/dispatch/BACKEND_ASSIGNMENTS.md"
  IFS='|' read -r fd ft fp fb <<< "$(task_counts_for_role "$f")"
  IFS='|' read -r ad at ap ab <<< "$(task_counts_for_role "$a")"
  IFS='|' read -r bd bt bp bb <<< "$(task_counts_for_role "$b")"
  blockers="$(grep -c '|.*阻塞' "${harness}/global/dashboard/BLOCKERS.md" 2>/dev/null || true)"
  changes="$(grep -c '^|' "${harness}/global/dashboard/CHANGE_REQUESTS.md" 2>/dev/null || true)"
  [[ "$changes" -gt 2 ]] && changes=$((changes - 2)) || changes=0
  dash="$(cat <<EOF
# PROJECT_DASHBOARD

| 字段 | 内容 |
|------|------|
| **更新时间** | $(now_utc) |
| **项目阶段** | $(awk -F'|' '/当前阶段/ {gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit}' "${harness}/global/product/PRODUCT_BRIEF.md" 2>/dev/null || echo "待确认") |
| **DSL 状态** | $(awk -F'|' '/DSL_REQUIREMENTS/ {gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit}' "${harness}/global/dsl/INDEX.md" 2>/dev/null || echo "待确认") |
| **Plan 状态** | $(awk -F'|' '/\*\*状态\*\*/ {gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit}' "${harness}/global/plans/GLOBAL_PLAN.md" 2>/dev/null || echo "待确认") |
| **前台前端进度** | ${fd} / ${ft} |
| **后台管理前端进度** | ${ad} / ${at} |
| **后端进度** | ${bd} / ${bt} |
| **当前阻塞** | ${blockers} |
| **新增 / 变更需求** | ${changes} |

## 当前建议

1. 若 DSL / Plan 仍为草稿，先完成 PM/工程师确认。
2. 若三端任务为 0，运行 \`aw pm dispatch --write\` 或维护 global/plans/ATOMIC_TASKS.md。
3. 若存在阻塞，先处理 global/dashboard/BLOCKERS.md 和 global/contracts/INTEGRATION_MATRIX.md。
EOF
)"
  progress="$(cat <<EOF
# PROGRESS_BOARD

| 端 | 已完成 | 总任务 | 进行中 | 阻塞 |
|----|--------|--------|--------|------|
| 前台前端 | ${fd} | ${ft} | ${fp} | ${fb} |
| 后台管理前端 | ${ad} | ${at} | ${ap} | ${ab} |
| 后端 | ${bd} | ${bt} | ${bp} | ${bb} |
EOF
)"
  printf '%s\n' "$dash"
  printf '\n%s\n' "$progress"
  if $write; then
    printf '%s\n' "$dash" > "${harness}/global/dashboard/PROJECT_DASHBOARD.md"
    printf '%s\n' "$progress" > "${harness}/global/dashboard/PROGRESS_BOARD.md"
    echo "written: ${harness}/global/dashboard/PROJECT_DASHBOARD.md"
    echo "written: ${harness}/global/dashboard/PROGRESS_BOARD.md"
  fi
}

assignments_file() {
  local role="$1" harness="$2"
  case "$role" in
    frontend|fe|前台|前台前端) echo "${harness}/global/dispatch/FRONTEND_ASSIGNMENTS.md" ;;
    admin|admin-frontend|后台|后台管理|后台管理前端) echo "${harness}/global/dispatch/ADMIN_ASSIGNMENTS.md" ;;
    backend|be|后端) echo "${harness}/global/dispatch/BACKEND_ASSIGNMENTS.md" ;;
    *) return 1 ;;
  esac
}

pm_assignments() {
  local role="" harness file
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --role) role="${2:-}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  [[ -n "$role" ]] || { echo "error: --role frontend|admin|backend|all is required" >&2; exit 1; }
  harness="$(pm_harness "")"
  ensure_pm_tree "$harness"
  if [[ "$role" == "all" ]]; then
    for role in frontend admin backend; do
      file="$(assignments_file "$role" "$harness")"
      echo "== ${role} assignments: ${file} =="
      sed -n '1,120p' "$file"
      echo
    done
    return 0
  fi
  file="$(assignments_file "$role" "$harness")" || { echo "error: unknown role: $role" >&2; exit 1; }
  echo "== ${role} assignments =="
  echo "path: ${file}"
  sed -n '1,160p' "$file"
}

pm_lifecycle() {
  local write=false harness board
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --write) write=true; shift ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  harness="$(pm_harness "")"
  ensure_pm_tree "$harness"
  board="${harness}/global/dashboard/LIFECYCLE_BOARD.md"
  if $write; then
    copy_pm_template "${PM_TPL}/dashboard/LIFECYCLE_BOARD.md" "$board"
    echo "written/ok: ${board}"
  fi
  sed -n '1,160p' "$board"
}

pm_gate() {
  local strict=false harness err=0 warn=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --strict) strict=true; shift ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  echo "== PM lifecycle gate =="
  harness="$(pm_harness "")" || exit 1
  ensure_pm_tree "$harness"
  need_file() {
    local f="$1" label="$2"
    if [[ -f "$f" ]]; then
      echo "ok  ${label}: ${f}"
    else
      echo "block: missing ${label}: ${f}" >&2
      err=1
    fi
  }
  need_file "${harness}/global/product/PRODUCT_BRIEF.md" "product brief"
  need_file "${harness}/global/requirements/BACKLOG.md" "requirements backlog"
  need_file "${harness}/global/references/design/DESIGN_FREEZE.md" "design freeze"
  need_file "${harness}/global/architecture/TECH_DESIGN.md" "tech design"
  need_file "${harness}/global/contracts/INTEGRATION_MATRIX.md" "integration matrix"
  need_file "${harness}/global/quality/TEST_STRATEGY.md" "test strategy"
  need_file "${harness}/global/quality/UAT_RECORD.md" "UAT record"
  need_file "${harness}/global/release/GO_LIVE_CHECKLIST.md" "go-live checklist"
  need_file "${harness}/global/release/POST_RELEASE_REVIEW.md" "post-release review"
  need_file "${harness}/global/dashboard/LIFECYCLE_BOARD.md" "lifecycle board"

  check_placeholder() {
    local f="$1" label="$2"
    if grep -qE '待确认|未确认|未冻结|未生成|未开始|未记录' "$f" 2>/dev/null; then
      echo "warn ${label} still has pending lifecycle status"
      warn=1
    else
      echo "ok  ${label} has no pending lifecycle status"
    fi
  }
  check_placeholder "${harness}/global/product/PRODUCT_BRIEF.md" "product brief"
  check_placeholder "${harness}/global/references/design/DESIGN_FREEZE.md" "design freeze"
  check_placeholder "${harness}/global/architecture/TECH_DESIGN.md" "tech design"
  check_placeholder "${harness}/global/quality/TEST_STRATEGY.md" "test strategy"
  check_placeholder "${harness}/global/quality/UAT_RECORD.md" "UAT"
  check_placeholder "${harness}/global/release/GO_LIVE_CHECKLIST.md" "go-live checklist"
  check_placeholder "${harness}/global/release/POST_RELEASE_REVIEW.md" "post-release review"

  if [[ "$err" -ne 0 ]]; then
    echo "PM gate: blocked" >&2
    exit 1
  fi
  if $strict && [[ "$warn" -ne 0 ]]; then
    echo "PM gate: strict blocked by pending lifecycle status" >&2
    exit 1
  fi
  echo "PM gate: ok"
}

pm_check() {
  local err=0 rel
  echo "== PM template check =="
  for rel in \
    product/PRODUCT_BRIEF.md \
    references/README.md \
    references/design/pencil/README.md \
    references/design/DESIGN_CHANGELOG.md \
    requirements/BACKLOG.md \
    dsl/INDEX.md \
    plans/GLOBAL_PLAN.md \
    plans/ATOMIC_TASKS.md \
    dispatch/TASK_BOARD.md \
    dispatch/FRONTEND_ASSIGNMENTS.md \
    dispatch/ADMIN_ASSIGNMENTS.md \
    dispatch/BACKEND_ASSIGNMENTS.md \
    contracts/INTEGRATION_MATRIX.md \
    dashboard/PROJECT_DASHBOARD.md \
    dashboard/LIFECYCLE_BOARD.md \
    quality/TEST_STRATEGY.md \
    release/GO_LIVE_CHECKLIST.md; do
    if [[ -f "${PM_TPL}/${rel}" ]]; then
      echo "ok  templates/pm/${rel}"
    else
      echo "missing  templates/pm/${rel}"
      err=1
    fi
  done
  if grep -q 'pm)' "${SCRIPT_DIR}/aw" 2>/dev/null; then
    echo "ok  aw routes pm"
  else
    echo "missing  aw pm route"
    err=1
  fi
  if cfg_harness_path >/dev/null 2>&1; then
    echo "info: PM sync center configured; run aw pm gate for lifecycle status"
  else
    echo "info: PM sync center not configured; run aw pm init <project-harness-path> in a product project"
  fi
  exit "$err"
}

pm_design_init() {
  local harness
  harness="$(pm_harness "")"
  ensure_pm_tree "$harness"
  echo "created/ok: ${harness}/global/references/design/pencil"
}

append_design_index() {
  local harness="$1" title="$2" source="$3" export_file="$4" screenshot="$5" req="$6"
  local idx="${harness}/global/references/design/DESIGN_INDEX.md"
  printf '| DESIGN-%s | %s | `%s` | %s%s | %s | 已登记 | %s |\n' \
    "$(date -u +%Y%m%d%H%M%S)" "$title" "$source" \
    "$([[ -n "$export_file" ]] && printf '`%s`' "$export_file" || printf '—')" \
    "$([[ -n "$screenshot" ]] && printf ' / `%s`' "$screenshot")" \
    "${req:-—}" "$(now_utc)" >> "$idx"
}

pm_design_import() {
  local file="" req="" title="" summary="" harness dest
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --file) file="${2:-}"; shift 2 ;;
      --req) req="${2:-}"; shift 2 ;;
      --title) title="${2:-}"; shift 2 ;;
      --summary) summary="${2:-}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  [[ -n "$file" && -f "$file" ]] || { echo "error: --file is required and must exist" >&2; exit 1; }
  harness="$(pm_harness "")"
  ensure_pm_tree "$harness"
  title="${title:-$(basename "$file")}"
  dest="${harness}/global/references/design/pencil/source/$(basename "$file")"
  cp "$file" "$dest"
  append_design_index "$harness" "$title" "global/references/design/pencil/source/$(basename "$file")" "" "" "$req"
  if [[ -n "$req" ]]; then
    mkdir -p "${harness}/global/requirements/changes"
    cat > "${harness}/global/requirements/changes/${req}-design-link.md" <<EOF
# ${req} 关联设计稿

| 字段 | 内容 |
|------|------|
| **REQ** | ${req} |
| **设计稿** | global/references/design/pencil/source/$(basename "$file") |
| **说明** | ${summary:-待确认} |
| **时间** | $(now_utc) |
EOF
  fi
  echo "imported: ${dest}"
  [[ -n "$req" ]] && echo "linked req: ${req}"
  echo "note: .pen files should be read through Pencil export/screenshot tools, not plain text parsing."
}

pm_design_link() {
  local req="" source="" export_file="" screenshot="" summary="" harness
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --req) req="${2:-}"; shift 2 ;;
      --source) source="${2:-}"; shift 2 ;;
      --export) export_file="${2:-}"; shift 2 ;;
      --screenshot) screenshot="${2:-}"; shift 2 ;;
      --summary) summary="${2:-}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  [[ -n "$req" && -n "$source" ]] || { echo "error: --req and --source are required" >&2; exit 1; }
  harness="$(pm_harness "")"
  ensure_pm_tree "$harness"
  mkdir -p "${harness}/global/requirements/changes"
  cat > "${harness}/global/requirements/changes/${req}-design-link.md" <<EOF
# ${req} 关联设计稿

| 类型 | 路径 | 说明 |
|------|------|------|
| Pencil 源文件 | \`${source}\` | ${summary:-待确认} |
| 导出物 | \`${export_file:-—}\` | 可供 Agent 阅读 |
| 截图 | \`${screenshot:-—}\` | 可供前端实现参考 |
EOF
  append_design_index "$harness" "$req design" "$source" "$export_file" "$screenshot" "$req"
  echo "linked: ${req} → ${source}"
}

pm_design_change() {
  local file="" summary="" req="—" tasks="—" harness log
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --file) file="${2:-}"; shift 2 ;;
      --summary) summary="${2:-}"; shift 2 ;;
      --req) req="${2:-}"; shift 2 ;;
      --tasks) tasks="${2:-}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  [[ -n "$file" && -n "$summary" ]] || { echo "error: --file and --summary are required" >&2; exit 1; }
  harness="$(pm_harness "")"
  ensure_pm_tree "$harness"
  log="${harness}/global/references/design/DESIGN_CHANGELOG.md"
  printf '| %s | %s | %s | %s | %s | 待确认 |\n' "$(now_utc)" "$file" "$summary" "$req" "$tasks" >> "$log"
  echo "recorded: ${log}"
  echo "next: update REQ → DSL → Plan → TASK_BOARD before coding."
}

pm_change() {
  local title="" type="口述新增" impact="待确认" acceptance="待确认" harness id file
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --title) title="${2:-}"; shift 2 ;;
      --type) type="${2:-}"; shift 2 ;;
      --impact) impact="${2:-}"; shift 2 ;;
      --acceptance) acceptance="${2:-}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  [[ -n "$title" ]] || { echo "error: --title is required" >&2; exit 1; }
  harness="$(pm_harness "")"
  ensure_pm_tree "$harness"
  id="REQ-$(date -u +%Y%m%d%H%M%S)"
  file="${harness}/global/requirements/changes/${id}.md"
  cat > "$file" <<EOF
# ${id} ${title}

| 字段 | 内容 |
|------|------|
| **需求类型** | ${type} |
| **状态** | 待确认 |
| **影响范围** | ${impact} |
| **验收标准** | ${acceptance} |
| **创建时间** | $(now_utc) |

## PM 处理流程

1. 确认影响范围。
2. 关联 PRD / UI / Pencil / 技术资料。
3. 更新 DSL。
4. 更新 GLOBAL_PLAN 和三端 Plan。
5. 更新 TASK_BOARD 和三端 assignments。
6. 通知相关 Agent sync pull。
EOF
  printf '| %s | %s | %s | 待确认 | 待确认 | %s | — |\n' "$id" "$type" "$title" "$impact" >> "${harness}/global/requirements/BACKLOG.md"
  printf '| %s | %s | %s | %s | 待确认 | — |\n' "$id" "$type" "$title" "$impact" >> "${harness}/global/dashboard/CHANGE_REQUESTS.md"
  echo "created: ${file}"
  echo "next: aw pm dashboard --write && aw pm dispatch --write after confirmation"
}

pm_plan() {
  local write=false from="" harness dsl_dir plans dsl_files dsl_list dsl_links source_note ts
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --write) write=true; shift ;;
      --from) from="${2:-}"; shift 2 ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  harness="$(pm_harness "")"
  ensure_pm_tree "$harness"
  dsl_dir="${from:-${harness}/global/dsl}"
  dsl_dir="$(abs_path "$dsl_dir")"
  [[ -d "$dsl_dir" ]] || { echo "error: DSL directory not found: ${dsl_dir}" >&2; exit 1; }
  plans="${harness}/global/plans"
  ts="$(now_utc)"
  dsl_files="$(find "$dsl_dir" -maxdepth 2 -type f -name '*.md' ! -name 'README.md' | sort 2>/dev/null || true)"
  if [[ -z "$dsl_files" ]]; then
    echo "error: no DSL markdown files found under ${dsl_dir}" >&2
    echo "hint: put reviewed DSL files under ${harness}/global/dsl/ before generating PM plans." >&2
    exit 1
  fi
  dsl_list="$(printf '%s\n' "$dsl_files" | sed "s#${harness}/##" | awk '{print "- `" $0 "`"}')"
  dsl_links="$(printf '%s\n' "$dsl_files" | sed "s#${harness}/##" | paste -sd ', ' -)"
  source_note="Generated from reviewed DSL files at ${ts}. This is a PM scaffold: PM/engineer must review task IDs, dependencies, API contracts, design links, and verification before dispatch."

  if ! $write; then
    cat <<EOF
preview: would generate PM global plans from ${dsl_dir}

DSL files:
${dsl_list}

Outputs:
  ${plans}/GLOBAL_PLAN.md
  ${plans}/FRONTEND_PLAN.md
  ${plans}/ADMIN_FRONTEND_PLAN.md
  ${plans}/BACKEND_PLAN.md
  ${plans}/ATOMIC_TASKS.md

run with --write after DSL review is confirmed.
EOF
    return 0
  fi

  cat > "${plans}/GLOBAL_PLAN.md" <<EOF
# GLOBAL_PLAN

| 字段 | 内容 |
|------|------|
| **状态** | 待审核 |
| **关联 DSL** | ${dsl_links} |
| **生成时间** | ${ts} |

## 来源 DSL

${dsl_list}

## 三端边界

| 功能 / 模块 | 前台前端 | 后台管理前端 | 后端 | 依赖 / 风险 |
|-------------|----------|--------------|------|-------------|
| 待从 DSL 细化 | 页面、交互、状态、埋点 | 管理页面、审核/配置/运营动作 | API、数据模型、权限、任务/事件 | API 契约、设计稿、验收口径待确认 |

## PM 审核清单

- [ ] 每个 DSL 需求都有 Plan 覆盖。
- [ ] 前台前端、后台管理前端、后端边界没有空白或重复。
- [ ] 跨端接口进入 \`global/contracts/INTEGRATION_MATRIX.md\` 或 OpenAPI。
- [ ] 设计稿 / Pencil / 截图已关联到相关任务。
- [ ] 任务依赖、验收、验证命令明确。

> ${source_note}
EOF

  cat > "${plans}/FRONTEND_PLAN.md" <<EOF
# FRONTEND_PLAN

| 字段 | 内容 |
|------|------|
| **状态** | 待审核 |
| **关联 DSL** | ${dsl_links} |

## 前台前端范围

| 模块 | 页面 / 组件 | 交互行为 | 依赖后端 / API | 验收 |
|------|-------------|----------|----------------|------|
| 待从 DSL 细化 | 待确认 | 待确认 | 待确认 | 待确认 |

## 任务拆分建议

- 页面结构、路由、状态管理、表单校验、错误态、空态、加载态。
- 与后端联动的 API 调用、mock、contract test、schema diff。
- 埋点事件、权限可见性、响应式适配、可访问性。
EOF

  cat > "${plans}/ADMIN_FRONTEND_PLAN.md" <<EOF
# ADMIN_FRONTEND_PLAN

| 字段 | 内容 |
|------|------|
| **状态** | 待审核 |
| **关联 DSL** | ${dsl_links} |

## 后台管理前端范围

| 模块 | 管理页面 / 操作 | 权限 / 审批 | 依赖后端 / API | 验收 |
|------|-----------------|-------------|----------------|------|
| 待从 DSL 细化 | 待确认 | 待确认 | 待确认 | 待确认 |

## 任务拆分建议

- 列表、筛选、详情、编辑、审核、批量操作、导入导出。
- 权限边界、操作日志、异常提示、数据刷新和并发冲突。
- 与后端管理 API 的契约、mock、contract test。
EOF

  cat > "${plans}/BACKEND_PLAN.md" <<EOF
# BACKEND_PLAN

| 字段 | 内容 |
|------|------|
| **状态** | 待审核 |
| **关联 DSL** | ${dsl_links} |

## 后端范围

| 模块 | API / 服务 | 数据模型 | 权限 / 状态机 | 验收 |
|------|------------|----------|---------------|------|
| 待从 DSL 细化 | 待确认 | 待确认 | 待确认 | 待确认 |

## 任务拆分建议

- OpenAPI / schema、领域模型、数据迁移、鉴权鉴权、业务校验。
- 前台与后台管理的接口差异、幂等、分页、错误码、审计日志。
- mock、contract test、集成测试、回归验证。
EOF

  cat > "${plans}/ATOMIC_TASKS.md" <<EOF
# ATOMIC_TASKS

| ID | 所属端 | 标题 | 状态 | 依赖任务 | 依赖接口 | 关联 REQ | 关联设计稿 | 验证 |
|----|--------|------|------|----------|----------|----------|------------|------|
| DECISION-T001 | pm | 确认 DSL 到三端计划的业务边界 | 待确认 | — | — | 待确认 | 待确认 | PM/工程师确认 GLOBAL_PLAN |
| CONTRACT-T001 | backend | 建立前后台共用接口契约草案 | 待确认 | DECISION-T001 | OpenAPI 待确认 | 待确认 | — | aw contract diff --write && aw contract gate |
| FE-T001 | frontend | 根据 DSL 细化前台前端页面和交互任务 | 待确认 | DECISION-T001, CONTRACT-T001 | 待确认 | 待确认 | 待确认 | pnpm test / 项目真实验证命令 |
| ADMIN-T001 | admin | 根据 DSL 细化后台管理前端任务 | 待确认 | DECISION-T001, CONTRACT-T001 | 待确认 | 待确认 | 待确认 | pnpm test / 项目真实验证命令 |
| BE-T001 | backend | 根据 DSL 细化后端 API、数据和权限任务 | 待确认 | DECISION-T001 | 待确认 | 待确认 | — | 项目真实测试命令 |
| INTEGRATION-T001 | pm | 确认前台/后台/后端联调边界和阻塞项 | 待确认 | FE-T001, ADMIN-T001, BE-T001 | 待确认 | 待确认 | 待确认 | aw pm dispatch --write && aw pm dashboard --write |
| QA-T001 | qa | 建立跨端验收和回归验证清单 | 待确认 | INTEGRATION-T001 | 待确认 | 待确认 | 待确认 | aw check tp / 项目真实验证命令 |

> ${source_note}
EOF

  echo "written: ${plans}/GLOBAL_PLAN.md"
  echo "written: ${plans}/FRONTEND_PLAN.md"
  echo "written: ${plans}/ADMIN_FRONTEND_PLAN.md"
  echo "written: ${plans}/BACKEND_PLAN.md"
  echo "written: ${plans}/ATOMIC_TASKS.md"
  echo "next:"
  echo "  1. PM/工程师审核 global/plans/*，补齐真实任务、依赖、接口、设计稿、验证命令。"
  echo "  2. 审核通过后运行：./scripts/aw pm dispatch --write"
  echo "  3. 三端 Agent 读取：./scripts/aw pm assignments --role frontend|admin|backend"
}

pm_dispatch() {
  local write=false harness atomic board fe admin be line id domain title st deps api req design verify
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --write) write=true; shift ;;
      -h|--help) usage 0 ;;
      *) echo "Unknown: $1" >&2; usage 1 ;;
    esac
  done
  harness="$(pm_harness "")"
  ensure_pm_tree "$harness"
  atomic="${harness}/global/plans/ATOMIC_TASKS.md"
  board="${harness}/global/dispatch/TASK_BOARD.md"
  fe="${harness}/global/dispatch/FRONTEND_ASSIGNMENTS.md"
  admin="${harness}/global/dispatch/ADMIN_ASSIGNMENTS.md"
  be="${harness}/global/dispatch/BACKEND_ASSIGNMENTS.md"
  if ! $write; then
    echo "preview: would derive dispatch board from ${atomic}"
    sed -n '1,120p' "$atomic"
    echo "run with --write to update dispatch files"
    return 0
  fi
  cat > "$board" <<'EOF'
# TASK_BOARD

| ID | 所属端 | 标题 | 状态 | 依赖任务 | 依赖接口 | 负责人 Agent | 最后同步 |
|----|--------|------|------|----------|----------|---------------|----------|
EOF
  cat > "$fe" <<'EOF'
# FRONTEND_ASSIGNMENTS

| ID | 标题 | 状态 | 关联 REQ | 关联设计稿 | 依赖后端 / API | 验收 |
|----|------|------|----------|------------|----------------|------|
EOF
  cat > "$admin" <<'EOF'
# ADMIN_ASSIGNMENTS

| ID | 标题 | 状态 | 关联 REQ | 关联设计稿 | 依赖后端 / API | 验收 |
|----|------|------|----------|------------|----------------|------|
EOF
  cat > "$be" <<'EOF'
# BACKEND_ASSIGNMENTS

| ID | 标题 | 状态 | 关联 REQ | 依赖前端 / 页面 | API / 数据 | 验收 |
|----|------|------|----------|----------------|------------|------|
EOF
  while IFS= read -r line; do
    [[ "$line" =~ ^\|[[:space:]]*[A-Z]+-T ]] || continue
    IFS='|' read -r _ id domain title st deps api req design verify _ <<< "$line"
    id="$(echo "${id:-}" | xargs)"
    domain="$(echo "${domain:-}" | xargs)"
    title="$(echo "${title:-}" | xargs)"
    st="$(echo "${st:-待确认}" | xargs)"
    deps="$(echo "${deps:-—}" | xargs)"
    api="$(echo "${api:-—}" | xargs)"
    req="$(echo "${req:-—}" | xargs)"
    design="$(echo "${design:-—}" | xargs)"
    verify="$(echo "${verify:-—}" | xargs)"
    [[ -n "$id" ]] || continue
    printf '| %s | %s | %s | %s | %s | %s | 待认领 | %s |\n' "$id" "$domain" "$title" "$st" "$deps" "$api" "$(now_utc)" >> "$board"
    case "$(echo "$domain" | tr '[:upper:]' '[:lower:]')" in
      frontend|front|fe|前台|前台前端)
        printf '| %s | %s | %s | %s | %s | %s | %s |\n' "$id" "$title" "$st" "$req" "$design" "$api" "$verify" >> "$fe" ;;
      admin|admin-frontend|后台|后台管理|后台管理前端)
        printf '| %s | %s | %s | %s | %s | %s | %s |\n' "$id" "$title" "$st" "$req" "$design" "$api" "$verify" >> "$admin" ;;
      backend|back|be|后端)
        printf '| %s | %s | %s | %s | %s | %s | %s |\n' "$id" "$title" "$st" "$req" "$deps" "$api" "$verify" >> "$be" ;;
    esac
  done < "$atomic"
  echo "written: ${board}"
  echo "written: ${fe}"
  echo "written: ${admin}"
  echo "written: ${be}"
}

case "$CMD" in
  start) pm_start "$@" ;;
  init) pm_init "$@" ;;
  intake|intake-check|check-intake) pm_intake_check "$@" ;;
  dashboard) pm_dashboard "$@" ;;
  assignments) pm_assignments "$@" ;;
  plan) pm_plan "$@" ;;
  lifecycle) pm_lifecycle "$@" ;;
  gate) pm_gate "$@" ;;
  check) pm_check "$@" ;;
  dispatch) pm_dispatch "$@" ;;
  change) pm_change "$@" ;;
  design)
    sub="${1:-init}"
    shift || true
    case "$sub" in
      init) pm_design_init "$@" ;;
      import) pm_design_import "$@" ;;
      link) pm_design_link "$@" ;;
      change) pm_design_change "$@" ;;
      export)
        echo "Pencil export is environment-dependent. Use Pencil tools to export .pen into global/references/design/pencil/exports/, then run aw pm design link." ;;
      *) echo "Unknown design command: $sub" >&2; usage 1 ;;
    esac
    ;;
  -h|--help|help) usage 0 ;;
  *) echo "Unknown pm command: $CMD" >&2; usage 1 ;;
esac
