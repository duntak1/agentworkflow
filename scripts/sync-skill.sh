#!/usr/bin/env bash
# Sync repo → ~/.cursor/skills/agent-workflow.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILL_SRC="${ROOT}/skill"
AW="${ROOT}/agent-workflow"
SKILL_ROOT="${CURSOR_SKILLS_DIR:-$HOME/.cursor/skills}"
PRIMARY="${SKILL_ROOT}/agent-workflow"
LEGACY="${SKILL_ROOT}/aw-delivery"

# Files copied into skill package/ (installed to target repo as agent-workflow/)
PACKAGE_FILES=(
  INVOCATION.md
  INVOCATION.en.md
  PRODUCT_INPUT_WORKFLOW.md
  CROSS_PROJECT_SYNC.md
  AICODING_WORKFLOW.md
  AGENT_RULES.md
  AGENTWORKFLOW_MANUAL.html
  AGENTS.md
  CLAUDE.md
  VERSION_CHANGELOG_QUALITY_LOOP.md
  CHANGELOG.md
  BOOTSTRAP.md
  README.md
  INDEX.md
  REPOSITORY.md
  PROMPTS.md
  VERSION
  SECURITY.md
  WINDOWS.md
)

sync_one() {
  local dest="$1"
  echo "== sync → ${dest} =="

  mkdir -p "${dest}/scripts" "${dest}/templates" "${dest}/package/adapters"

  # Skill docs (source of truth: skill/)
  cp "${SKILL_SRC}/SKILL.md" "${dest}/SKILL.md"
  cp "${SKILL_SRC}/QUICKSTART.md" "${dest}/QUICKSTART.md"
  cp "${SKILL_SRC}/reference.md" "${dest}/reference.md"
  cp "${SKILL_SRC}/VERSION" "${dest}/VERSION" 2>/dev/null || cp "${AW}/VERSION" "${dest}/VERSION" 2>/dev/null || true

  # CLI + templates
  cp -R "${AW}/templates/." "${dest}/templates/"
  for f in "${ROOT}/scripts/"*; do
    [[ -f "$f" ]] && cp "$f" "${dest}/scripts/"
  done
  chmod +x "${dest}/scripts/"* 2>/dev/null || true

  # Slim policy package for aw install
  for rel in "${PACKAGE_FILES[@]}"; do
    [[ -f "${AW}/${rel}" ]] && cp "${AW}/${rel}" "${dest}/package/${rel}"
  done
  cp -R "${AW}/adapters/." "${dest}/package/adapters/"
  cp -R "${AW}/meta/." "${dest}/package/meta/" 2>/dev/null || mkdir -p "${dest}/package/meta"
  cp -R "${AW}/templates" "${dest}/package/templates"

  rm -f "${dest}/EXAMPLES.md"
  # Do not rm REFERENCE.md — case-insensitive FS would delete reference.md
}

write_alias_skill() {
  local dest="$1" name="$2"
  mkdir -p "$dest"
  sync_one "$dest"
  sed -e "s/^name: agent-workflow/name: ${name}/" "${SKILL_SRC}/SKILL.md" > "${dest}/SKILL.md"
}

mkdir -p "$SKILL_ROOT"
sync_one "$PRIMARY"
if [[ "${AW_SYNC_LEGACY_SKILL:-0}" == "1" ]]; then
  write_alias_skill "$LEGACY" "aw-delivery"
fi

# Optional: project skill in source repo (for contributors)
PROJ_SKILL="${ROOT}/.cursor/skills/agent-workflow"
if [[ "${AW_SYNC_PROJECT_SKILL:-1}" == "1" ]]; then
  mkdir -p "${ROOT}/.cursor/skills"
  rm -rf "${PROJ_SKILL}"
  cp -R "${PRIMARY}" "${PROJ_SKILL}"
  echo "== project skill → ${PROJ_SKILL} =="
fi

echo ""
echo "Done: ${PRIMARY}"
if [[ "${AW_SYNC_LEGACY_SKILL:-0}" == "1" ]]; then
  echo "      alias: ${LEGACY}"
fi
echo "Test:  ${PRIMARY}/scripts/check-skill-package.sh"
