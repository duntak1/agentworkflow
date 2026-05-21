#!/usr/bin/env bash
# List / select active Plan file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"
CMD="${1:-list}"
shift || true
ACTIVE_FILE="${ROOT}/docs/.aw-active-plan"
active=""
[[ -f "$ACTIVE_FILE" ]] && active="$(tr -d '[:space:]' < "$ACTIVE_FILE")"

usage() {
  cat <<'EOF'
Usage:
  aw plan list
  aw plan use <path|slug>
EOF
  exit "${1:-0}"
}

resolve_plan_path() {
  local arg="$1" slug upper_slug
  [[ -z "$arg" ]] && return 1
  [[ -f "${ROOT}/${arg}" ]] && { echo "${arg#${ROOT}/}"; return 0; }
  [[ -f "$arg" ]] && { echo "${arg#${ROOT}/}"; return 0; }
  slug="$arg"
  slug="${slug#PLAN_}"
  slug="${slug%.md}"
  upper_slug="$(echo "$slug" | tr '[:lower:]' '[:upper:]')"
  for p in "${ROOT}/docs/plans/PLAN_${slug}.md" "${ROOT}/docs/plans/PLAN_${upper_slug}.md"; do
    [[ -f "$p" ]] && { echo "docs/plans/$(basename "$p")"; return 0; }
  done
  return 1
}

case "$CMD" in
  list)
    echo "== Plan files =="
    shopt -s nullglob
    any=false
    for f in "${ROOT}"/docs/plans/PLAN_*.md; do
      [[ -f "$f" ]] || continue
      any=true
      rel="docs/plans/$(basename "$f")"
      mark=" "
      [[ "$rel" == "$active" ]] && mark="*"
      echo "${mark} ${rel}"
    done
    $any || echo "（无）— create via aw plan / aw plan apply"
    [[ -n "$active" ]] && echo "" && echo "Active: ${active}"
    true
    ;;
  use)
    target="${1:-}"
    [[ -n "$target" ]] || { echo "error: aw plan use <path|slug>" >&2; exit 1; }
    rel="$(resolve_plan_path "$target")" || { echo "error: not found: $target" >&2; exit 1; }
    mkdir -p "${ROOT}/docs"
    echo "$rel" > "$ACTIVE_FILE"
    atomic=""
    base="$(basename "$rel" .md)"
    slug="${base#PLAN_}"
    [[ -f "${ROOT}/docs/plans/ATOMIC_TASKS_${slug}.md" ]] && atomic="docs/plans/ATOMIC_TASKS_${slug}.md"
    [[ -n "$atomic" ]] && echo "$atomic" > "${ROOT}/docs/.aw-active-atomic-tasks"
    if [[ -f "$(aw_workflow_json_path)" ]]; then
      tmp="$(mktemp)"
      sed -E "s#\"plan_file\"[[:space:]]*:[[:space:]]*\"[^\"]*\"#\"plan_file\": \"${rel}\"#" "$(aw_workflow_json_path)" > "$tmp"
      if [[ -n "$atomic" ]]; then
        sed -E "s#\"atomic_tasks_file\"[[:space:]]*:[[:space:]]*\"[^\"]*\"#\"atomic_tasks_file\": \"${atomic}\"#" "$tmp" > "${tmp}.2"
        mv "${tmp}.2" "$tmp"
      fi
      mv "$tmp" "$(aw_workflow_json_path)"
    fi
    echo "ok: active Plan → ${rel}"
    [[ -n "$atomic" ]] && echo "ok: active ATOMIC → ${atomic}"
    ;;
  -h|--help) usage 0 ;;
  *) echo "Unknown: $CMD" >&2; usage 1 ;;
esac
