#!/usr/bin/env bash
# Install agent-workflow Cursor skill from a git URL or local path.
set -euo pipefail

REPO_URL="${AW_SKILL_REPO_URL:-}"
REF="${AW_SKILL_REF:-main}"
DEST="${CURSOR_SKILLS_DIR:-$HOME/.cursor/skills}/agent-workflow"
SOURCE="${1:-}"

usage() {
  cat <<EOF
Usage:
  $0 [path-to-agentworkflow-repo]
  $0 https://github.com/you/agentworkflow.git
  AW_SKILL_REPO_URL=https://github.com/you/agentworkflow.git $0

Installs to: ${DEST}
Optional:
  AW_SKILL_REF=<branch-or-tag>   default: main
EOF
  exit "${1:-0}"
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage 0

WORKDIR=""
cleanup() { [[ -n "$WORKDIR" && -d "$WORKDIR" ]] && rm -rf "$WORKDIR"; }
trap cleanup EXIT

case "$SOURCE" in
  http://*|https://*|git@*|ssh://*)
    REPO_URL="$SOURCE"
    SOURCE=""
    ;;
esac

if [[ -n "$SOURCE" ]]; then
  ROOT="$(cd "$SOURCE" && pwd)"
elif [[ -n "$REPO_URL" ]]; then
  WORKDIR="$(mktemp -d)"
  git clone --depth 1 --branch "$REF" "$REPO_URL" "$WORKDIR/repo"
  ROOT="$WORKDIR/repo"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
fi

[[ -f "${ROOT}/scripts/sync-skill.sh" ]] || {
  echo "error: not an agentworkflow repo: ${ROOT}" >&2
  exit 1
}

export AW_SYNC_PROJECT_SKILL=0
CURSOR_SKILLS_DIR="$(dirname "$DEST")" \
  AW_SKILL_REPO_URL="" \
  bash "${ROOT}/scripts/sync-skill.sh"

echo ""
echo "Installed: ${DEST}"
echo "In your app repo:"
echo "  ${DEST}/scripts/aw install ."
echo "  ./scripts/aw init && ./scripts/aw status"
