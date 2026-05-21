#!/usr/bin/env bash
# Install CI workflow templates into the target repository.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
SOURCE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CMD="${1:-install}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw ci install [--force]

Installs .github/workflows/agent-workflow.yml for this repository. The workflow
runs aw check all, skill package checks, and e2e-smoke.
EOF
  exit "${1:-0}"
}

FORCE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown: $1" >&2; usage 1 ;;
  esac
  shift
done

case "$CMD" in
  install)
    mkdir -p "${ROOT}/.github/workflows"
    dest="${ROOT}/.github/workflows/agent-workflow.yml"
    if [[ -f "$dest" && "$FORCE" != true ]]; then
      echo "skip (exists): .github/workflows/agent-workflow.yml"
      echo "use --force to overwrite"
      exit 0
    fi
    cat > "$dest" <<'EOF'
name: agent-workflow

on:
  pull_request:
  push:
    branches: [main, master]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Prepare scripts
        run: chmod +x scripts/aw scripts/*.sh .githooks/* 2>/dev/null || chmod +x scripts/aw scripts/*.sh

      - name: Check workflow
        run: ./scripts/aw check all

      - name: Check skill
        run: |
          ./scripts/check-skill-source.sh
          AW_SYNC_PROJECT_SKILL=0 ./scripts/sync-skill.sh
          ./scripts/check-skill-package.sh "${HOME}/.cursor/skills/agent-workflow"

      - name: E2E smoke
        run: ./scripts/e2e-smoke.sh
EOF
    echo "created: .github/workflows/agent-workflow.yml"
    ;;
  -h|--help|help) usage 0 ;;
  *) echo "Unknown: $CMD" >&2; usage 1 ;;
esac
