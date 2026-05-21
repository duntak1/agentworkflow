#!/usr/bin/env bash
# Bug ledger commands.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-bug-lib.sh
source "${SCRIPT_DIR}/_aw-bug-lib.sh"

CMD="${1:-list}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw bug add "summary" [--source chat|test|review|runtime|prod] [--status open|investigating|done|wontfix] [--scope AT-T...|path|module] [--evidence "..."]
  aw bug list
  aw bug path

Rule: every bug or suspected bug must be recorded before/while fixing it.
EOF
  exit "${1:-0}"
}

case "$CMD" in
  add)
    SUMMARY="${1:-}"
    [[ -n "$SUMMARY" ]] || { echo "error: aw bug add \"summary\"" >&2; exit 1; }
    shift || true
    SOURCE="chat"
    STATUS="open"
    SCOPE="—"
    EVIDENCE="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --source) SOURCE="${2:-}"; shift 2 ;;
        --status) STATUS="${2:-}"; shift 2 ;;
        --scope) SCOPE="${2:-}"; shift 2 ;;
        --evidence) EVIDENCE="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    case "$SOURCE" in
      test|chat|review|runtime|prod|hook-*) ;;
      *) echo "error: unsupported source: $SOURCE" >&2; exit 1 ;;
    esac
    case "$STATUS" in
      open|investigating|done|wontfix) ;;
      *) echo "error: unsupported status: $STATUS" >&2; exit 1 ;;
    esac
    aw_bug_append "$SOURCE" "$STATUS" "$SCOPE" "$SUMMARY" "$EVIDENCE"
    echo "logged: docs/handoff/AI_BUG_LOG.md"
    aw_refresh_engineering_index
    ;;
  list)
    aw_bug_ensure_log
    sed -n '1,120p' "$(aw_bug_log_path)"
    ;;
  path)
    aw_bug_ensure_log
    bug_log="$(aw_bug_log_path)"
    root="$(aw_repo_root)"
    printf '%s\n' "${bug_log#"${root}/"}"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
