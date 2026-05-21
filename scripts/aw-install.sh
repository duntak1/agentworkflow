#!/usr/bin/env bash
# Install agent-workflow package into target repo (or current repo).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

SOURCE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET="."
INSTALL_ADAPTERS=false
FROM_SKILL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --adapters|--all-adapters) INSTALL_ADAPTERS=true ;;
    -h|--help)
      echo "Usage: aw install [path] [--adapters]"
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      TARGET="$1"
      ;;
  esac
  shift
done

if [[ "$TARGET" == "." ]]; then
  TARGET="$(aw_repo_root)"
else
  TARGET="$(cd "$TARGET" && pwd)"
fi

PKG_SRC=""
SCRIPTS_SRC=""

if [[ -f "${SOURCE_ROOT}/SKILL.md" && -d "${SOURCE_ROOT}/package" ]]; then
  FROM_SKILL=true
  PKG_SRC="${SOURCE_ROOT}/package"
  SCRIPTS_SRC="${SOURCE_ROOT}/scripts"
  echo "== install from skill → ${TARGET} =="
elif [[ -d "${SOURCE_ROOT}/agent-workflow" ]]; then
  PKG_SRC="${SOURCE_ROOT}/agent-workflow"
  SCRIPTS_SRC="${SOURCE_ROOT}/scripts"
  if [[ "$TARGET" == "$SOURCE_ROOT" ]]; then
    echo "== install into current repo (refresh) =="
  else
    echo "== install agent-workflow → ${TARGET} =="
  fi
else
  echo "error: cannot find agent-workflow/ or skill package/" >&2
  exit 1
fi

copy_tree() {
  local src="$1" dest="$2"
  mkdir -p "$dest"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --exclude '.DS_Store' "$src/" "$dest/"
  else
    cp -R "$src/." "$dest/"
  fi
}

copy_tree "$PKG_SRC" "${TARGET}/agent-workflow"
# Ensure templates exist (older package/ may lack templates/)
if [[ ! -d "${TARGET}/agent-workflow/templates" ]]; then
  if [[ -d "${PKG_SRC}/templates" ]]; then
    copy_tree "${PKG_SRC}/templates" "${TARGET}/agent-workflow/templates"
  elif $FROM_SKILL && [[ -d "${SKILL_ROOT}/templates" ]]; then
    copy_tree "${SKILL_ROOT}/templates" "${TARGET}/agent-workflow/templates"
  elif [[ -d "${SOURCE_ROOT}/agent-workflow/templates" ]]; then
    copy_tree "${SOURCE_ROOT}/agent-workflow/templates" "${TARGET}/agent-workflow/templates"
  fi
fi

if ! $FROM_SKILL; then
  [[ -d "${SOURCE_ROOT}/.githooks" ]] && copy_tree "${SOURCE_ROOT}/.githooks" "${TARGET}/.githooks"
  if [[ -d "${SOURCE_ROOT}/.github" ]]; then
    mkdir -p "${TARGET}/.github"
    copy_tree "${SOURCE_ROOT}/.github" "${TARGET}/.github"
  fi
  if [[ -f "${SOURCE_ROOT}/.gitignore" && ! -f "${TARGET}/.gitignore" ]]; then
    cp "${SOURCE_ROOT}/.gitignore" "${TARGET}/.gitignore"
    echo "  created: .gitignore"
  fi
fi

mkdir -p "${TARGET}/scripts"
for f in "${SCRIPTS_SRC}/"*; do
  [[ -f "$f" ]] && cp "$f" "${TARGET}/scripts/"
done
chmod +x "${TARGET}/scripts/"*.sh "${TARGET}/scripts/aw" 2>/dev/null || true

stub_if_missing() {
  local path="$1" content="$2"
  if [[ ! -f "${TARGET}/${path}" ]]; then
    printf '%s\n' "$content" > "${TARGET}/${path}"
    echo "  created: ${path}"
  else
    echo "  skip (exists): ${path}"
  fi
}

stub_if_missing "CLAUDE.md" "# CLAUDE.md

正文：[\`agent-workflow/CLAUDE.md\`](./agent-workflow/CLAUDE.md) · 调用：[\`agent-workflow/INVOCATION.md\`](./agent-workflow/INVOCATION.md)
"

stub_if_missing "AGENTS.md" "# AGENTS.md

正文：[\`agent-workflow/AGENTS.md\`](./agent-workflow/AGENTS.md)
"

stub_if_missing "AGENT_RULES.md" "# AGENT_RULES.md

正文：[\`agent-workflow/AGENT_RULES.md\`](./agent-workflow/AGENT_RULES.md)
"

stub_if_missing "README.md" "# $(basename "$TARGET")

\`\`\`bash
chmod +x scripts/aw scripts/*.sh
./scripts/aw init
./scripts/aw status
\`\`\`

工作流：[\`agent-workflow/README.md\`](./agent-workflow/README.md)
"

if $INSTALL_ADAPTERS; then
  (cd "${TARGET}" && ./scripts/install-aw-adapters.sh --all)
fi

echo ""
echo "Run in target:"
echo "  cd ${TARGET} && ./scripts/aw init && ./scripts/aw status"
if ! $INSTALL_ADAPTERS; then
  echo "  optional: ./scripts/aw adapters --all   # Claude/Codex/Copilot/Cursor/Windsurf/Cline/Continue"
fi
