#!/usr/bin/env bash
# Recovery playbooks for broken context, stale plans, sync drift, failed tasks, and rollback.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
DIR="${ROOT}/docs/recovery"
PLAYBOOK="${DIR}/RECOVERY_PLAYBOOK.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw recover init
  aw recover context
  aw recover plan
  aw recover sync
  aw recover failed-task --task AT-T...
  aw recover conflict
  aw recover rollback
  aw recover check
EOF
  exit "${1:-0}"
}

ensure_recovery() {
  mkdir -p "$DIR"
  [[ -f "$PLAYBOOK" ]] || cp "${TEMPLATES}/recovery/RECOVERY_PLAYBOOK.md" "$PLAYBOOK"
}

case "$CMD" in
  init)
    ensure_recovery
    echo "created/ok: docs/recovery/RECOVERY_PLAYBOOK.md"
    ;;
  context)
    ensure_recovery
    echo "== recover context =="
    "${SCRIPT_DIR}/aw" handoff --check || true
    "${SCRIPT_DIR}/aw" memory inject || true
    "${SCRIPT_DIR}/aw" status || true
    "${SCRIPT_DIR}/aw" next || true
    ;;
  plan)
    ensure_recovery
    echo "== recover plan =="
    "${SCRIPT_DIR}/aw-trace.sh" check || true
    echo ""
    echo "If trace is broken: record requirement change, update DSL/Plan/ATOMIC, then rerun aw confirm."
    ;;
  sync)
    ensure_recovery
    echo "== recover sync =="
    "${SCRIPT_DIR}/aw-sync.sh" status || true
    "${SCRIPT_DIR}/aw-sync.sh" inbox || true
    "${SCRIPT_DIR}/aw-contract.sh" gate || true
    ;;
  failed-task)
    TASK=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task) TASK="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$TASK" ]] || { echo "error: --task is required" >&2; exit 1; }
    ensure_recovery
    echo "== recover failed task: ${TASK} =="
    "${SCRIPT_DIR}/aw-bug.sh" add "Task ${TASK} failed or needs recovery" --source runtime --scope "$TASK" || true
    "${SCRIPT_DIR}/aw-task.sh" blocked "$TASK" "recovery required" || true
    echo "Next: clarify requirement, split task if needed, update Plan/ATOMIC, then aw task confirm/start."
    ;;
  conflict)
    ensure_recovery
    echo "== recover conflict =="
    git -C "$ROOT" status --short || true
    echo ""
    echo "Stop coding. Ask engineer to choose merge strategy before editing conflict files."
    ;;
  rollback)
    ensure_recovery
    echo "== recover rollback =="
    git -C "$ROOT" log --oneline -10 || true
    echo ""
    [[ -f "${ROOT}/local/commit-autolog.jsonl" ]] && tail -20 "${ROOT}/local/commit-autolog.jsonl" || true
    echo ""
    echo "Use release record + commit checkpoint to choose rollback. Do not reset without engineer confirmation."
    ;;
  check)
    echo "== recovery check =="
    if [[ -f "$PLAYBOOK" ]]; then
      echo "ok  docs/recovery/RECOVERY_PLAYBOOK.md"
    else
      echo "missing  docs/recovery/RECOVERY_PLAYBOOK.md (run: aw recover init)" >&2
      exit 1
    fi
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
