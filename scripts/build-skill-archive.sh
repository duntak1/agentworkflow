#!/usr/bin/env bash
# Build dist/agent-workflow-skill-<version>.tar.gz for release.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "${ROOT}/agent-workflow/VERSION")"
STAGE="${ROOT}/dist/stage"
OUT="${ROOT}/dist/agent-workflow-skill-${VERSION}.tar.gz"

export AW_SYNC_PROJECT_SKILL=0
export CURSOR_SKILLS_DIR="${STAGE}/cursor-skills"
rm -rf "${ROOT}/dist"
mkdir -p "${CURSOR_SKILLS_DIR}"

bash "${ROOT}/scripts/sync-skill.sh"
SKILL="${CURSOR_SKILLS_DIR}/agent-workflow"
bash "${SKILL}/scripts/check-skill-package.sh" "${SKILL}"

mkdir -p "${ROOT}/dist"
tar \
  --exclude='.DS_Store' \
  --exclude='*/.DS_Store' \
  -czf "${OUT}" \
  -C "${CURSOR_SKILLS_DIR}" \
  agent-workflow

# Include install helper at archive root
cp "${ROOT}/scripts/install-cursor-skill.sh" "${ROOT}/dist/"
cp "${ROOT}/skill/QUICKSTART.md" "${ROOT}/dist/QUICKSTART.md"
cp "${ROOT}/skill/VERSION" "${ROOT}/dist/VERSION"
cp "${ROOT}/PUBLISH.md" "${ROOT}/dist/PUBLISH.md"

echo "Wrote: ${OUT}"
echo "      ${ROOT}/dist/install-cursor-skill.sh"
ls -lh "${OUT}"
