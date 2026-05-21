#!/usr/bin/env bash
# Block staging business code paths when active DSL is not 已审.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"

if [[ "${SKIP_DSL_GATE:-}" == "1" ]]; then
  exit 0
fi

STAGED="$(git diff --cached --name-only 2>/dev/null || true)"
[[ -n "$STAGED" ]] || exit 0

BUSINESS=false
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  case "$path" in
    docs/*|reference/*|agent-workflow/*|scripts/*|.githooks/*|.github/*|*.md|ENGINEERING_INDEX.md|CHANGELOG.md|CLAUDE.md|AGENTS.md|AGENT_RULES.md|SECURITY.md|.gitignore|.cursor/*)
      continue
      ;;
    frontend/*|backend/*|mobile/*|src/*|app/*|lib/*|packages/*|api/*|server/*|client/*)
      BUSINESS=true
      break
      ;;
    *.ts|*.tsx|*.js|*.jsx|*.vue|*.py|*.go|*.java|*.rs|*.kt|*.swift)
      # root-level or misc app code
      if [[ "$path" != docs/* ]]; then
        BUSINESS=true
        break
      fi
      ;;
  esac
done <<< "$STAGED"

$BUSINESS || exit 0

dsl_file=""
if [[ -f "${ROOT}/docs/.aw-active-dsl" ]]; then
  dsl_file="$(tr -d '[:space:]' < "${ROOT}/docs/.aw-active-dsl")"
fi
if [[ -z "$dsl_file" ]]; then
  for candidate in "${ROOT}"/docs/dsl/DSL_DRAFT.md "${ROOT}"/docs/dsl/DSL_*.md; do
    [[ -f "$candidate" ]] || continue
    base="$(basename "$candidate")"
    case "$base" in
      DSL_SPEC_TEMPLATE.md|FRONTEND_PAGE_SPEC_TEMPLATE.md|README.md) continue ;;
    esac
    dsl_file="docs/dsl/${base}"
    break
  done
fi

if [[ -z "$dsl_file" || ! -f "${ROOT}/${dsl_file}" ]]; then
  echo "error: staging app code but no docs/dsl/*.md found (run: aw init; aw dsl)" >&2
  exit 1
fi

if grep -qE '状态[^|]*\|[^|]*已审' "${ROOT}/${dsl_file}" 2>/dev/null; then
  exit 0
fi

echo "error: DSL not 已审 — cannot stage business code (${dsl_file})" >&2
echo "  fix: review DSL, then: ./scripts/aw approve dsl ${dsl_file}" >&2
echo "  skip: SKIP_DSL_GATE=1 git commit ..." >&2
exit 1
