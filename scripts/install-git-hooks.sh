#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "$ROOT"

if [[ ! -d .githooks ]]; then
  echo "error: .githooks/ missing (run from agent-workflow source repo)" >&2
  exit 1
fi

chmod +x .githooks/* scripts/*.sh scripts/aw 2>/dev/null || true

git config core.hooksPath .githooks
echo "core.hooksPath = $(git config core.hooksPath)"
echo "Hooks installed. pre-commit runs scripts/pre-commit-verify.sh and aw gate pre-commit"
