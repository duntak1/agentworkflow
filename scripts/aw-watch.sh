#!/usr/bin/env bash
# Lightweight automation watcher helpers.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
CMD="${1:-index}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw watch index [--once|--loop] [--interval 10]

Runs automatic index refresh and affected-analysis hints. Loop mode is intentionally local-only
and does not commit/push/deploy.
EOF
  exit "${1:-0}"
}

run_index_once() {
  echo "== watch index =="
  "${SCRIPT_DIR}/aw-code-map.sh" build --quiet >/dev/null 2>&1 || true
  "${SCRIPT_DIR}/generate-file-index.sh" >/dev/null 2>&1 || true
  AW_INDEX_MODE=scan "${SCRIPT_DIR}/generate-engineering-index.sh" --scan-only >/dev/null 2>&1 || true
  "${SCRIPT_DIR}/aw-context.sh" affected || true
  echo "watch index: refreshed CODE_MAP / FILE_INDEX / ENGINEERING_INDEX and printed affected analysis"
}

case "$CMD" in
  index)
    LOOP=false
    INTERVAL=10
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --once) LOOP=false; shift ;;
        --loop) LOOP=true; shift ;;
        --interval) INTERVAL="${2:-10}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    if $LOOP; then
      echo "watch index loop every ${INTERVAL}s (Ctrl-C to stop)"
      while true; do
        run_index_once
        sleep "$INTERVAL"
      done
    else
      run_index_once
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
