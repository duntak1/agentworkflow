#!/usr/bin/env bash
# Agent execution audit log.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
TRACE="${ROOT}/docs/audit/AGENT_TRACE.md"
CMD="${1:-list}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw audit init
  aw audit add --task AT-T... --action "..." --result "..." [--evidence path] [--confirm "name"]
  aw audit check
  aw audit list
  aw audit path

Rule: record key AI actions, decisions, commands, verification results, and human confirmations.
EOF
  exit "${1:-0}"
}

ensure_audit() {
  mkdir -p "${ROOT}/docs/audit"
  if [[ ! -f "$TRACE" ]]; then
    cp "${TEMPLATES}/audit/AGENT_TRACE.md" "$TRACE"
    echo "created: docs/audit/AGENT_TRACE.md"
  fi
}

case "$CMD" in
  init)
    ensure_audit
    ;;
  add)
    TASK="—"
    ACTION=""
    RESULT=""
    EVIDENCE="—"
    CONFIRM="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task|--req|--scope) TASK="${2:-}"; shift 2 ;;
        --action) ACTION="${2:-}"; shift 2 ;;
        --result) RESULT="${2:-}"; shift 2 ;;
        --evidence) EVIDENCE="${2:-}"; shift 2 ;;
        --confirm) CONFIRM="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$ACTION" ]] || { echo "error: --action is required" >&2; exit 1; }
    [[ -n "$RESULT" ]] || { echo "error: --result is required" >&2; exit 1; }
    case "${ACTION} ${RESULT} ${EVIDENCE} ${CONFIRM}" in
      *password*|*PASSWORD*|*token*|*TOKEN*|*secret*|*SECRET*)
        echo "error: possible secret detected; do not store secrets in audit log" >&2
        exit 1
        ;;
    esac
    ensure_audit >/dev/null
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    tmp="$(mktemp)"
    awk -v row="| ${now} | ${TASK} | ${ACTION} | ${RESULT} | ${EVIDENCE} | ${CONFIRM} |" '
      BEGIN{done=0}
      /^## 流水/ {print; next}
      /^\| 时间 \|/ {print; next}
      /^\|------/ && done==0 {print; print row; done=1; next}
      {print}
      END{if(done==0) print row}
    ' "$TRACE" > "$tmp"
    mv "$tmp" "$TRACE"
    echo "logged: docs/audit/AGENT_TRACE.md"
    aw_refresh_engineering_index
    ;;
  check)
    echo "== audit check =="
    if [[ ! -f "$TRACE" ]]; then
      echo "missing  docs/audit/AGENT_TRACE.md (run: aw audit init)" >&2
      exit 1
    fi
    echo "ok  docs/audit/AGENT_TRACE.md"
    if grep -qiE '(api[_-]?key[[:space:]]*[:=]|access[_-]?token[[:space:]]*[:=]|refresh[_-]?token[[:space:]]*[:=]|bearer[[:space:]]+[A-Za-z0-9._-]+|[A-Za-z0-9_]*(TOKEN|SECRET|PASSWORD|API_KEY)[A-Za-z0-9_]*[[:space:]]*=)' "$TRACE"; then
      echo "warn  audit log may contain sensitive text" >&2
    fi
    ;;
  list)
    ensure_audit >/dev/null
    sed -n '1,120p' "$TRACE"
    ;;
  path)
    ensure_audit >/dev/null
    printf '%s\n' "${TRACE#"${ROOT}/"}"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
