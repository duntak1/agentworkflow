#!/usr/bin/env bash
# Requirement commands: new | change
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"
CMD="${1:-}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw req new <slug> "title" [--type 口述新增|补充需求|约束规则] [--impact "..."] [--acceptance "..."]
  aw req change <AT-T> "change summary" [--impact "..."] [--acceptance "..."]

Rule: spoken new requirements and development-time changes are both recorded in docs/requirements/, distinguished by 需求类型.
EOF
  exit "${1:-0}"
}

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-//;s/-$//'
}

next_req_id() {
  local date="$1" req_dir="$2" max=0 n
  for f in "${req_dir}"/REQ-"${date}"-*.md; do
    [[ -f "$f" ]] || continue
    n="$(basename "$f" | sed -n "s/REQ-${date}-\\([0-9]*\\).*/\\1/p")"
    [[ -n "$n" ]] && ((10#$n > max)) && max=$((10#$n))
  done
  printf '%03d' $((max + 1))
}

append_section() {
  local file="$1" title="$2" body="$3"
  [[ -f "$file" ]] || return 0
  {
    printf '\n---\n\n'
    printf '## %s\n\n' "$title"
    printf '%s\n' "$body"
  } >> "$file"
}

clear_requirement_confirm() {
  local task_id="$1" f tmp
  f="$(aw_task_requirement_confirm_path)"
  [[ -f "$f" ]] || return 0
  tmp="$(mktemp)"
  grep -vE "^${task_id}[[:space:]]" "$f" > "$tmp" || true
  mv "$tmp" "$f"
}

ensure_req_index() {
  local req_dir="$1" index="${req_dir}/INDEX.md"
  if [[ ! -f "$index" ]] || ! grep -q '需求类型' "$index" 2>/dev/null; then
    cat > "$index" <<'EOF'
# 需求索引（REQ）

| ID | 标题 | 需求类型 | 状态 | 提出日期 | 备注 |
|----|------|----------|------|----------|------|
EOF
  fi
}

append_req_index_row() {
  local req_dir="$1" req_id="$2" req_base="$3" title="$4" req_type="$5" status="$6" note="$7"
  local index="${req_dir}/INDEX.md" tmp
  ensure_req_index "$req_dir"
  tmp="$(mktemp)"
  {
    awk 'NR<=6' "$index" 2>/dev/null
    echo "| [${req_id}](./${req_base}.md) | ${title} | ${req_type} | ${status} | $(date +%Y-%m-%d) | ${note} |"
    awk 'NR>6 && !/尚无更多/' "$index" 2>/dev/null || true
  } > "$tmp"
  mv "$tmp" "$index"
}

write_req_file() {
  local req_file="$1" req_base="$2" req_id="$3" req_type="$4" status="$5" source_task="$6" dsl_rel="$7" plan_rel="$8" title="$9" summary="${10}" impact="${11}" acceptance="${12}" atomic_rel="${13:-—}"
  cat > "$req_file" <<EOF
# ${req_base}

## 元数据

| 字段 | 内容 |
|------|------|
| **ID** | ${req_id} |
| **需求类型** | ${req_type} |
| **状态** | ${status} |
| **来源任务** | ${source_task:-—} |
| **联动 DSL** | ${dsl_rel:-—} |
| **联动 Plan** | ${plan_rel:-—} |
| **联动 ATOMIC** | ${atomic_rel:-—} |
| **提出日期** | $(date +%Y-%m-%d) |

## 标题

${title}

## 需求摘要

${summary}

## 影响范围

${impact}

## 验收更新

${acceptance}
EOF
}

case "$CMD" in
  new)
    SLUG="${1:-}"
    TITLE="${2:-}"
    [[ -n "$SLUG" && -n "$TITLE" ]] || { echo "error: aw req new <slug> \"title\"" >&2; usage 1; }
    shift 2
    REQ_TYPE="口述新增"
    IMPACT="待补充"
    ACCEPTANCE="待补充"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --type) REQ_TYPE="${2:-}"; shift 2 ;;
        --impact) IMPACT="${2:-}"; shift 2 ;;
        --acceptance) ACCEPTANCE="${2:-}"; shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    req_dir="${ROOT}/docs/requirements"
    mkdir -p "$req_dir"
    date_id="$(date +%Y%m%d)"
    seq="$(next_req_id "$date_id" "$req_dir")"
    slug="$(slugify "$SLUG")"
    [[ -n "$slug" ]] || slug="spoken-requirement"
    req_id="REQ-${date_id}-${seq}"
    req_base="${req_id}-${slug}"
    req_rel="docs/requirements/${req_base}.md"
    req_file="${ROOT}/${req_rel}"
    dsl_rel="$(aw_resolve_dsl_file 2>/dev/null || echo "—")"
    plan_rel="$(aw_resolve_plan_file 2>/dev/null || echo "—")"
    write_req_file "$req_file" "$req_base" "$req_id" "$REQ_TYPE" "草稿" "—" "$dsl_rel" "$plan_rel" "$TITLE" "$TITLE" "$IMPACT" "$ACCEPTANCE" "—"
    append_req_index_row "$req_dir" "$req_id" "$req_base" "$TITLE" "$REQ_TYPE" "草稿" "口述新增需求"
    echo "Created: ${req_rel}"
    echo "Updated: docs/requirements/INDEX.md"
    aw_refresh_engineering_index
    ;;
  change)
    TASK_ID="${1:-}"
    SUMMARY="${2:-}"
    [[ -n "$TASK_ID" && -n "$SUMMARY" ]] || { echo "error: aw req change <AT-T> \"change summary\"" >&2; usage 1; }
    shift 2
    IMPACT="待补充"
    ACCEPTANCE="待补充"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --impact) IMPACT="${2:-}"; shift 2 ;;
        --acceptance) ACCEPTANCE="${2:-}"; shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done

    aw_gate_coding_ready || exit 1
    atomic_rel="$(aw_resolve_atomic_tasks_file)" || exit 1
    task_row="$(aw_task_get_row "${ROOT}/${atomic_rel}" "$TASK_ID")" || {
      echo "error: unknown task $TASK_ID" >&2
      exit 1
    }
    IFS=$'\t' read -r _task_id domain title status deps verify <<< "$task_row"
    dsl_rel="$(aw_resolve_dsl_file)"
    plan_rel="$(aw_resolve_plan_file)"

    req_dir="${ROOT}/docs/requirements"
    mkdir -p "$req_dir"
    date_id="$(date +%Y%m%d)"
    seq="$(next_req_id "$date_id" "$req_dir")"
    slug="$(slugify "change-${TASK_ID}-${SUMMARY}")"
    [[ -n "$slug" ]] || slug="change-${TASK_ID}"
    req_id="REQ-${date_id}-${seq}"
    req_base="${req_id}-${slug}"
    req_rel="docs/requirements/${req_base}.md"
    req_file="${ROOT}/${req_rel}"

    write_req_file "$req_file" "$req_base" "$req_id" "研发中变更" "研发中变更" "$TASK_ID" "$dsl_rel" "$plan_rel" "$SUMMARY" "$SUMMARY" "$IMPACT" "$ACCEPTANCE" "$atomic_rel"
    cat >> "$req_file" <<EOF

## 回写要求

- [ ] DSL 已回写：${dsl_rel}
- [ ] Plan 已回写：${plan_rel}
- [ ] ATOMIC 已回写：${atomic_rel}
- [ ] 已重新执行 \`aw task brief ${TASK_ID}\`
- [ ] 工程师已重新确认：\`aw task confirm ${TASK_ID} "已确认：范围=...；验收=...；非目标=..."\`
EOF

    append_req_index_row "$req_dir" "$req_id" "$req_base" "$SUMMARY" "研发中变更" "研发中变更" "${TASK_ID} · 已回写 DSL/Plan/ATOMIC"

    change_body="- 来源：${req_rel}
- 任务：${TASK_ID}（${title}）
- 变更：${SUMMARY}
- 影响：${IMPACT}
- 验收：${ACCEPTANCE}
- 要求：继续编码前重新 \`aw task brief ${TASK_ID}\` 并由工程师 \`aw task confirm ${TASK_ID} \"已确认：范围=...；验收=...；非目标=...\"\`。"
    append_section "${ROOT}/${dsl_rel}" "研发中需求变更回写 · ${req_id}" "$change_body"
    append_section "${ROOT}/${plan_rel}" "研发中需求变更回写 · ${req_id}" "$change_body"
    append_section "${ROOT}/${atomic_rel}" "研发中需求变更回写 · ${req_id}" "$change_body"
    clear_requirement_confirm "$TASK_ID"

    echo "Created: ${req_rel}"
    echo "Updated: docs/requirements/INDEX.md"
    echo "Updated: ${dsl_rel}"
    echo "Updated: ${plan_rel}"
    echo "Updated: ${atomic_rel}"
    echo "reset: ${TASK_ID} requirement confirmation"
    aw_refresh_engineering_index
    echo "next: ./scripts/aw task brief ${TASK_ID} → discuss → ./scripts/aw task confirm ${TASK_ID} \"已确认：范围=...；验收=...；非目标=...\""
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    usage 1
    ;;
esac
