#!/usr/bin/env bash
# Refresh agent-workflow package/scripts in the current repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
ROOT="$(aw_repo_root)"
RUN_ADAPTERS=false
RUN_CI=false
FROM_GITHUB=false
REPO_URL="${AW_SKILL_REPO_URL:-https://github.com/duntak1/agentworkflow.git}"
REF="${AW_SKILL_REF:-main}"
SKILL_DIR="${CURSOR_SKILLS_DIR:-$HOME/.cursor/skills}/agent-workflow"

usage() {
  cat <<'EOF'
Usage:
  aw upgrade [--adapters] [--ci]
  aw upgrade --from-github [--repo <git-url-or-path>] [--ref <branch-or-tag>] [--adapters] [--ci]

Refreshes agent-workflow/ and scripts/ from the current installed source. Business
docs under docs/, reference/, and generated workflow state are preserved.

With --from-github, aw clones the latest agentworkflow repo, replaces the local
installed skill, then uses that fresh skill to replace agent-workflow/ and
scripts/ in the current project.
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --adapters) RUN_ADAPTERS=true ;;
    --ci) RUN_CI=true ;;
    --from-github|--github|--remote) FROM_GITHUB=true ;;
    --repo|--url) REPO_URL="${2:-}"; shift ;;
    --ref|--branch|--tag) REF="${2:-}"; shift ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown: $1" >&2; usage 1 ;;
  esac
  shift
done

if $FROM_GITHUB; then
  [[ -n "$REPO_URL" ]] || { echo "error: --repo is empty" >&2; exit 1; }
  WORKDIR="$(mktemp -d)"
  cleanup() { rm -rf "$WORKDIR"; }
  trap cleanup EXIT

  echo "== aw remote upgrade =="
  echo "repo: ${REPO_URL}"
  echo "ref: ${REF}"
  if [[ -d "$REPO_URL" && -f "${REPO_URL}/scripts/install-cursor-skill.sh" ]]; then
    mkdir -p "$WORKDIR/agentworkflow"
    tar -C "$REPO_URL" --exclude .git --exclude .cursor --exclude dist -cf - . | tar -C "$WORKDIR/agentworkflow" -xf -
  else
    git clone --depth 1 --branch "$REF" "$REPO_URL" "$WORKDIR/agentworkflow"
  fi

  echo "== reinstall local skill =="
  AW_KEEP_OLD_SKILLS=0 AW_SYNC_LEGACY_SKILL=0 CURSOR_SKILLS_DIR="${CURSOR_SKILLS_DIR:-$HOME/.cursor/skills}" \
    bash "$WORKDIR/agentworkflow/scripts/install-cursor-skill.sh" "$WORKDIR/agentworkflow"

  [[ -x "${SKILL_DIR}/scripts/aw" ]] || {
    echo "error: fresh skill install missing ${SKILL_DIR}/scripts/aw" >&2
    exit 1
  }

  echo "== replace current project package/scripts =="
  "${SKILL_DIR}/scripts/aw" install "$ROOT"
  if [[ ! -f "${ROOT}/docs/PROJECT_CONFIG.md" || ! -f "${ROOT}/docs/agents/AGENT_REGISTRY.md" ]]; then
    (cd "$ROOT" && ./scripts/aw init >/dev/null)
  fi
  $RUN_ADAPTERS && (cd "$ROOT" && ./scripts/install-aw-adapters.sh --all)
  $RUN_CI && (cd "$ROOT" && ./scripts/aw ci install)
  (cd "$ROOT" && ./scripts/aw check layout)
  echo "upgrade: ok (from ${REPO_URL}@${REF})"
  exit 0
fi

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
