#!/usr/bin/env bash
# Test plan helpers: list | show | link to AT-T*
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"
# shellcheck source=_aw-verify-lib.sh
source "${SCRIPT_DIR}/_aw-verify-lib.sh"

ROOT="$(aw_repo_root)"
TP_DIR="${ROOT}/docs/quality/test-plans"
CMD="${1:-list}"
shift || true

usage() {
  cat <<EOF
Usage:
  aw tp list                    List TP-*.md
  aw tp show <id|path>          Print TP summary for Agent
  aw tp new <slug> "title"      Create TP (wraps new-test-plan.sh)
  aw tp link <AT-T> <tp-id|path>  Append TP:… to AT-T Verify column
EOF
  exit "${1:-0}"
}

resolve_tp_file() {
  local arg="$1"
  [[ -z "$arg" ]] && return 1
  if aw_is_tp_spec "$arg"; then
    aw_resolve_tp_path "$arg" && return 0
  fi
  if [[ -f "${ROOT}/${arg}" ]]; then
    echo "${arg}"
    return 0
  fi
  aw_resolve_tp_path "TP:${arg}" 2>/dev/null || aw_resolve_tp_path "$arg"
}

update_verify_with_tp() {
  local atomic_file="$1" task_id="$2" tp_rel="$3"
  local row ver new_ver
  row="$(aw_task_get_row "$atomic_file" "$task_id")" || return 1
  ver="$(echo "$row" | awk -F'\t' '{print $5}' | tr -d '`')"
  if [[ "$ver" == *"TP:${tp_rel}"* ]] || [[ "$ver" == *"${tp_rel}"* ]]; then
    echo "info: already linked"
    return 0
  fi
  if [[ -z "$ver" || "$ver" == "—" ]]; then
    new_ver="TP:${tp_rel}"
  else
    new_ver="${ver}; TP:${tp_rel}"
  fi
  aw_task_set_verify "${atomic_file}" "$task_id" "$new_ver"
}

case "$CMD" in
  list)
    echo "== Test plans =="
    shopt -s nullglob
    any=false
    for f in "${TP_DIR}"/TP-*.md; do
      [[ -f "$f" ]] || continue
      any=true
      echo "  docs/quality/test-plans/$(basename "$f")"
    done
    $any || echo "  （无）— aw tp new <slug> \"title\""
    ;;
  show)
    arg="${1:-}"
    [[ -n "$arg" ]] || { echo "error: aw tp show <id|path>" >&2; exit 1; }
    rel="$(resolve_tp_file "$arg")" || { echo "error: TP not found: $arg" >&2; exit 1; }
    echo "== ${rel} =="
    head -n 35 "${ROOT}/${rel}"
    echo ""
    echo "Run manual / E2E per ${rel}; then aw verify --task <AT-T> (if linked)"
    ;;
  new)
    exec "${SCRIPT_DIR}/new-test-plan.sh" "$@"
    ;;
  link)
    task_id="${1:-}"
    tp_arg="${2:-}"
    [[ -n "$task_id" && -n "$tp_arg" ]] || {
      echo "error: aw tp link <AT-T> <tp-id|path>" >&2
      exit 1
    }
    tp_rel="$(resolve_tp_file "$tp_arg")" || {
      echo "error: TP not found: $tp_arg" >&2
      exit 1
    }
    atomic="$(aw_resolve_atomic_tasks_file 2>/dev/null || true)"
    [[ -n "$atomic" ]] || { echo "error: no ATOMIC_TASKS file" >&2; exit 1; }
    aw_task_get_row "${ROOT}/${atomic}" "$task_id" >/dev/null || {
      echo "error: unknown task ${task_id}" >&2
      exit 1
    }
    update_verify_with_tp "${ROOT}/${atomic}" "$task_id" "$tp_rel"
    echo "ok: ${task_id} verify → includes TP:${tp_rel}"
    aw_refresh_engineering_index
  ;;
  -h|--help) usage 0 ;;
  *) echo "Unknown: $CMD" >&2; usage 1 ;;
esac
