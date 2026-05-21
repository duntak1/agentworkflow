#!/usr/bin/env bash
# Run pre-commit checks before commit (optional wrapper).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export FORCE_FULL_PRE_COMMIT="${FORCE_FULL_PRE_COMMIT:-1}"
"${SCRIPT_DIR}/pre-commit-verify.sh"
echo "commit-gate: ok — proceed with git commit"
