#!/usr/bin/env bash
# Preview or remove generated agent-workflow integration files.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
EXECUTE=false
REMOVE_PACKAGE=false
REMOVE_ADAPTERS=false
REMOVE_CI=false
REMOVE_HOOKS=false

usage() {
  cat <<'EOF'
Usage:
  aw remove [--package] [--adapters] [--ci] [--hooks] [--all] [--execute]

Default is dry-run. Pass --execute to delete. Does not remove docs/, reference/,
or ENGINEERING_INDEX.md unless you delete them manually.
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package) REMOVE_PACKAGE=true ;;
    --adapters) REMOVE_ADAPTERS=true ;;
    --ci) REMOVE_CI=true ;;
    --hooks) REMOVE_HOOKS=true ;;
    --all) REMOVE_PACKAGE=true; REMOVE_ADAPTERS=true; REMOVE_CI=true; REMOVE_HOOKS=true ;;
    --execute) EXECUTE=true ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown: $1" >&2; usage 1 ;;
  esac
  shift
done

if ! $REMOVE_PACKAGE && ! $REMOVE_ADAPTERS && ! $REMOVE_CI && ! $REMOVE_HOOKS; then
  REMOVE_ADAPTERS=true
  REMOVE_CI=true
fi

targets=()
$REMOVE_PACKAGE && targets+=("agent-workflow")
$REMOVE_HOOKS && targets+=(".githooks")
if $REMOVE_ADAPTERS; then
  targets+=("AGENTS.md" "CLAUDE.md" "AGENT_RULES.md" ".github/copilot-instructions.md" ".cursor/rules/agent-workflow.mdc" ".windsurfrules" ".clinerules" ".continue/rules/agent-workflow.md" ".qoderwork/rules/agent-workflow.md" ".trae/rules/agent-workflow.md" ".lingma/rules/agent-workflow.md" ".openclaw/agent-workflow.md" ".qclaw/agent-workflow.md")
fi
$REMOVE_CI && targets+=(".github/workflows/agent-workflow.yml")

echo "== aw remove =="
$EXECUTE || echo "dry-run: pass --execute to delete"
for rel in "${targets[@]}"; do
  if [[ -e "${ROOT}/${rel}" ]]; then
    if $EXECUTE; then
      rm -rf "${ROOT:?}/${rel}"
      echo "removed: ${rel}"
    else
      echo "would remove: ${rel}"
    fi
  fi
done
