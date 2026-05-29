#!/usr/bin/env bash
# Development-time Plan/ATOMIC changes: append tasks or split an existing task.
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
  aw plan change --summary "..." [--type small|major] [--related REQ/AT-T] [--dsl-update "path or summary"] [--plan-update "path or summary"]
  aw plan task-add --title "..." [--domain Frontend|Backend|Fullstack|QA] [--deps AT-T...] [--verify "..."] [--related REQ/AT-T]
  aw task split <AT-T...> --into "Title A; Title B" [--domain Frontend] [--verify "..."] [--related REQ/AT-T]

Rules:
  - Small changes update the active Plan / ATOMIC.
  - Major scope, architecture, delivery batch, or domain changes should create a new Plan / ATOMIC separately.
  - Every change should be linked to REQ/AT-T and audited.
EOF
  exit "${1:-0}"
}

atomic_path() {
  local atomic
  atomic="$(aw_resolve_atomic_tasks_file)" || {
    echo "error: no active ATOMIC_TASKS file (run: aw plan use <slug> or aw confirm)" >&2
    exit 1
  }
  echo "${ROOT}/${atomic}"
}

plan_path() {
  local plan
  plan="$(aw_resolve_plan_file 2>/dev/null || true)"
  [[ -n "$plan" && -f "${ROOT}/${plan}" ]] || return 1
  echo "${ROOT}/${plan}"
}

next_task_id() {
  local atomic="$1" max=0 n
  while IFS= read -r n; do
    [[ -n "$n" ]] || continue
    (( n > max )) && max="$n"
  done < <(grep -Eo 'AT-T[0-9]+-[0-9]+' "$atomic" | sed -E 's/AT-T[0-9]+-0*//' || true)
  printf 'AT-T1-%03d\n' $((max + 1))
}

append_task_row() {
  local atomic="$1" id="$2" domain="$3" title="$4" deps="$5" verify="$6"
  local tmp
  tmp="$(mktemp)"
  awk -v row="| ${id} | ${domain} | ${title} | 待办 | ${deps} | ${verify} |" '
    { print }
    /^\| AT-T/ { seen=1 }
    END {
      if (!seen) {
        print ""
        print "| ID | 领域 | 标题 | 状态 | 依赖 | 验证 |"
        print "|----|------|------|------|------|------|"
      }
      print row
    }
  ' "$atomic" > "$tmp"
  mv "$tmp" "$atomic"
}

append_change_note() {
  local file="$1" summary="$2" related="$3" kind="$4"
  [[ -f "$file" ]] || return 0
  {
    echo ""
    echo "## 研发中计划变更 - $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo ""
    echo "- 类型：${kind}"
    echo "- 关联：${related:-—}"
    echo "- 摘要：${summary}"
  } >> "$file"
}

audit_plan_change() {
  local action="$1" result="$2" evidence="$3"
  if [[ -x "${SCRIPT_DIR}/aw-audit.sh" ]]; then
    "${SCRIPT_DIR}/aw-audit.sh" add --task "${RELATED:-—}" --action "$action" --result "$result" --evidence "$evidence" >/dev/null || true
  fi
}

reset_requirement_confirmation_if_task() {
  local related="$1" f tmp
  [[ "$related" == AT-T* ]] || return 0
  f="$(aw_task_requirement_confirm_path)"
  [[ -f "$f" ]] || return 0
  tmp="$(mktemp)"
  grep -vE "^${related}[[:space:]]" "$f" > "$tmp" || true
  mv "$tmp" "$f"
  echo "reset: ${related} requirement confirmation"
}

case "$CMD" in
  change)
    SUMMARY=""
    KIND="small"
    RELATED="—"
    DSL_UPDATE="—"
    PLAN_UPDATE="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --summary) SUMMARY="${2:-}"; shift 2 ;;
        --type) KIND="${2:-}"; shift 2 ;;
        --related|--task|--req) RELATED="${2:-}"; shift 2 ;;
        --dsl-update) DSL_UPDATE="${2:-}"; shift 2 ;;
        --plan-update) PLAN_UPDATE="${2:-}"; shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$SUMMARY" ]] || { echo "error: --summary is required" >&2; exit 1; }
    case "$KIND" in small|major) ;; *) echo "error: --type must be small|major" >&2; exit 1 ;; esac
    plan="$(plan_path 2>/dev/null || true)"
    if [[ -n "$plan" ]]; then
      append_change_note "$plan" "$SUMMARY; DSL=${DSL_UPDATE}; Plan=${PLAN_UPDATE}" "$RELATED" "$KIND"
      echo "updated: ${plan#"${ROOT}/"}"
    fi
    atomic="$(atomic_path)"
    append_change_note "$atomic" "$SUMMARY; DSL=${DSL_UPDATE}; Plan=${PLAN_UPDATE}" "$RELATED" "$KIND"
    echo "updated: ${atomic#"${ROOT}/"}"
    if [[ "$KIND" == "major" ]]; then
      echo "warn: major change should generate/review a new Plan + ATOMIC if the current execution path no longer applies" >&2
      echo "next: aw plan <dsl> --domain ... → aw plan apply --slug <new> → aw approve plan → aw confirm" >&2
    fi
    audit_plan_change "plan change" "${KIND}: ${SUMMARY}" "${atomic#"${ROOT}/"}"
    reset_requirement_confirmation_if_task "$RELATED"
    aw_refresh_engineering_index
    ;;
  task-add)
    TITLE=""
    DOMAIN="Fullstack"
    DEPS="—"
    VERIFY="见 PROJECT_CONFIG"
    RELATED="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --title) TITLE="${2:-}"; shift 2 ;;
        --domain) DOMAIN="${2:-}"; shift 2 ;;
        --deps) DEPS="${2:-}"; shift 2 ;;
        --verify) VERIFY="${2:-}"; shift 2 ;;
        --related|--task|--req) RELATED="${2:-}"; shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$TITLE" ]] || { echo "error: --title is required" >&2; exit 1; }
    atomic="$(atomic_path)"
    id="$(next_task_id "$atomic")"
    append_task_row "$atomic" "$id" "$DOMAIN" "$TITLE" "$DEPS" "$VERIFY"
    echo "added: ${id} → ${atomic#"${ROOT}/"}"
    audit_plan_change "task add" "Added ${id}: ${TITLE}" "${atomic#"${ROOT}/"}"
    aw_refresh_engineering_index
    echo "next: ./scripts/aw task brief ${id}"
    ;;
  split)
    TASK_ID="${1:-}"
    [[ -n "$TASK_ID" ]] || { echo "error: aw task split <AT-T...> --into \"A; B\"" >&2; exit 1; }
    shift || true
    INTO=""
    DOMAIN=""
    VERIFY=""
    RELATED="$TASK_ID"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --into) INTO="${2:-}"; shift 2 ;;
        --domain) DOMAIN="${2:-}"; shift 2 ;;
        --verify) VERIFY="${2:-}"; shift 2 ;;
        --related|--req) RELATED="${2:-}"; shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$INTO" ]] || { echo "error: --into is required" >&2; exit 1; }
    atomic="$(atomic_path)"
    row="$(aw_task_get_row "$atomic" "$TASK_ID")" || { echo "error: task not found: $TASK_ID" >&2; exit 1; }
    IFS=$'\t' read -r _ old_domain old_title _ old_deps old_verify <<< "$row"
    [[ -n "$DOMAIN" ]] || DOMAIN="$old_domain"
    [[ -n "$VERIFY" ]] || VERIFY="$old_verify"
    dep="$TASK_ID"
    IFS=';' read -r -a parts <<< "$INTO"
    added=()
    for raw in "${parts[@]}"; do
      title="$(aw_trim "$raw")"
      [[ -n "$title" ]] || continue
      id="$(next_task_id "$atomic")"
      append_task_row "$atomic" "$id" "$DOMAIN" "$title" "$dep" "$VERIFY"
      added+=("$id")
      dep="$id"
    done
    [[ "${#added[@]}" -gt 0 ]] || { echo "error: no split task titles parsed" >&2; exit 1; }
    aw_task_set_status "$atomic" "$TASK_ID" "阻塞"
    append_change_note "$atomic" "拆分 ${TASK_ID}（${old_title}）为：${added[*]}" "$RELATED" "small"
    echo "split: ${TASK_ID} → ${added[*]}"
    echo "updated: ${atomic#"${ROOT}/"}"
    audit_plan_change "task split" "Split ${TASK_ID} into ${added[*]}" "${atomic#"${ROOT}/"}"
    aw_refresh_engineering_index
    echo "next: ./scripts/aw task brief ${added[0]}"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: ${CMD}" >&2
    usage 1
    ;;
esac
