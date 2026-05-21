#!/usr/bin/env bash
# List / select active ATOMIC_TASKS_*.md (multi-plan repos)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"
CMD="${1:-list}"
shift || true

active="$(tr -d '[:space:]' < "${ROOT}/docs/.aw-active-atomic-tasks" 2>/dev/null || true)"
if [[ -z "$active" && -f "$(aw_workflow_json_path)" ]]; then
  active="$(grep -E '"atomic_tasks_file"' "$(aw_workflow_json_path)" 2>/dev/null | sed -E 's/.*"atomic_tasks_file"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' | head -1 || true)"
fi

usage() {
  cat <<EOF
Usage:
  aw atomic list              List ATOMIC_TASKS_*.md (* = active)
  aw atomic use <path|slug>  Set active atomic tasks file
EOF
  exit "${1:-0}"
}

resolve_atomic_path() {
  local arg="$1"
  [[ -z "$arg" ]] && return 1
  if [[ -f "${ROOT}/${arg}" ]]; then
    echo "${arg#${ROOT}/}"
    return 0
  fi
  if [[ -f "$arg" ]]; then
    echo "${arg#${ROOT}/}"
    return 0
  fi
  local slug="$arg"
  slug="${slug#ATOMIC_TASKS_}"
  slug="${slug%.md}"
  if [[ -f "${ROOT}/docs/plans/ATOMIC_TASKS_${slug}.md" ]]; then
    echo "docs/plans/ATOMIC_TASKS_${slug}.md"
    return 0
  fi
  return 1
}

case "$CMD" in
  list)
    echo "== ATOMIC_TASKS files =="
    shopt -s nullglob
    any=false
    for f in "${ROOT}"/docs/plans/ATOMIC_TASKS_*.md; do
      [[ -f "$f" ]] || continue
      any=true
      rel="docs/plans/$(basename "$f")"
      mark=" "
      [[ "$rel" == "$active" ]] && mark="*"
      echo "${mark} ${rel}"
    done
    $any || echo "（无）— create via aw plan / paste plan-write"
    [[ -n "$active" ]] && echo "" && echo "Active: ${active}"
    ;;
  use)
    target="${1:-}"
    [[ -n "$target" ]] || { echo "error: aw atomic use <path|slug>" >&2; exit 1; }
    rel="$(resolve_atomic_path "$target")" || {
      echo "error: not found: $target" >&2
      exit 1
    }
    mkdir -p "${ROOT}/docs"
    echo "$rel" > "${ROOT}/docs/.aw-active-atomic-tasks"
    if [[ -f "$(aw_workflow_json_path)" ]]; then
      local tmp
      tmp="$(mktemp)"
      if grep -q '"atomic_tasks_file"' "$(aw_workflow_json_path)"; then
        sed -E "s/\"atomic_tasks_file\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"atomic_tasks_file\": \"${rel}\"/" "$(aw_workflow_json_path)" > "$tmp"
        mv "$tmp" "$(aw_workflow_json_path)"
      fi
    fi
    echo "ok: active → ${rel}"
    echo "next: ./scripts/aw next"
    ;;
  -h|--help) usage 0 ;;
  *) echo "Unknown: $CMD" >&2; usage 1 ;;
esac
