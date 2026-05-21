#!/usr/bin/env bash
# Read-only terminal dashboard for agent-workflow.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-}" in
  -h|--help)
    cat <<'EOF'
Usage: aw dashboard

Print a read-only terminal dashboard for workflow state and capabilities.
EOF
    exit 0
    ;;
esac

echo "== agent-workflow dashboard =="
echo ""
"${SCRIPT_DIR}/aw" status
echo ""
echo "== capabilities =="
"${SCRIPT_DIR}/aw" capabilities | sed '1d'
echo ""
echo "== machine-readable =="
echo "  ./scripts/aw status --json"
echo "  ./scripts/aw capabilities --json"
