#!/usr/bin/env bash
# One-shot setup for a target repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
DO_ADAPTERS=true
DO_CI=true
DO_HOOKS=false

usage() {
  cat <<'EOF'
Usage:
  aw setup [--no-adapters] [--no-ci] [--hooks]

Runs the common first-time setup path:
  install package if needed -> init -> adapters -> CI -> status -> doctor
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-adapters) DO_ADAPTERS=false ;;
    --no-ci) DO_CI=false ;;
    --hooks) DO_HOOKS=true ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown: $1" >&2; usage 1 ;;
  esac
  shift
done

if [[ ! -f "${ROOT}/agent-workflow/INVOCATION.md" || ! -x "${ROOT}/scripts/aw" ]]; then
  install_args=(".")
  $DO_ADAPTERS && install_args+=("--adapters")
  "${SCRIPT_DIR}/aw-install.sh" "${install_args[@]}"
elif $DO_ADAPTERS; then
  "${SCRIPT_DIR}/install-aw-adapters.sh" --all
fi

"${SCRIPT_DIR}/init-project.sh"
$DO_CI && "${SCRIPT_DIR}/aw-ci.sh" install
$DO_HOOKS && "${SCRIPT_DIR}/install-git-hooks.sh"

"${SCRIPT_DIR}/aw-status.sh"
echo ""
"${SCRIPT_DIR}/aw-doctor.sh"
