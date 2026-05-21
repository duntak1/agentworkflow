#!/usr/bin/env bash
# Refresh agent-workflow package/scripts in the current repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
ROOT="$(aw_repo_root)"
RUN_ADAPTERS=false
RUN_CI=false

usage() {
  cat <<'EOF'
Usage:
  aw upgrade [--adapters] [--ci]

Refreshes agent-workflow/ and scripts/ from the current installed source. Business
docs under docs/, reference/, and generated workflow state are preserved.
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --adapters) RUN_ADAPTERS=true ;;
    --ci) RUN_CI=true ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown: $1" >&2; usage 1 ;;
  esac
  shift
done

SOURCE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
if [[ "$SOURCE_ROOT" == "$ROOT" && -f "${ROOT}/agent-workflow/INVOCATION.md" ]]; then
  echo "info: scripts already run from this repo; skip self-copy"
else
  "${SCRIPT_DIR}/aw-install.sh" .
fi
$RUN_ADAPTERS && "${SCRIPT_DIR}/install-aw-adapters.sh" --all
$RUN_CI && "${SCRIPT_DIR}/aw-ci.sh" install
"${SCRIPT_DIR}/check-aw-all.sh" all
echo "upgrade: ok"
