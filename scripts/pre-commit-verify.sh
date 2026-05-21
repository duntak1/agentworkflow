#!/usr/bin/env bash
# Pre-commit verification (agent-workflow repos).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
cd "$ROOT"

echo "== pre-commit-verify =="

"${SCRIPT_DIR}/check-dsl-business-gate.sh"
"${SCRIPT_DIR}/check-req-index.sh"
"${SCRIPT_DIR}/check-test-plan-index.sh"

for shf in "${SCRIPT_DIR}"/*.sh .githooks/*; do
  [[ -f "$shf" ]] || continue
  bash -n "$shf"
done

# CHANGELOG gate when policy paths staged
if [[ "${SKIP_CHANGELOG_GATE:-}" != "1" ]]; then
  STAGED="$(git diff --cached --name-only 2>/dev/null || true)"
  if echo "$STAGED" | grep -qE '^(agent-workflow/|scripts/|\.githooks/|\.github/)'; then
    if ! echo "$STAGED" | grep -qE '^agent-workflow/CHANGELOG\.md$'; then
      echo "error: policy paths staged but agent-workflow/CHANGELOG.md not staged" >&2
      echo "  fix: edit CHANGELOG [Unreleased] and git add agent-workflow/CHANGELOG.md" >&2
      echo "  skip: SKIP_CHANGELOG_GATE=1 git commit ..." >&2
      exit 1
    fi
  fi
fi

# Optional full layout check (fast)
if [[ "${SKIP_AW_CHECK:-}" != "1" ]]; then
  "${SCRIPT_DIR}/check-aw-all.sh" layout req || true
fi

# Frontend / maven when staged (optional projects)
if [[ "${SKIP_PRE_COMMIT_TESTS:-}" != "1" ]]; then
  STAGED="$(git diff --cached --name-only 2>/dev/null || true)"
  if echo "$STAGED" | grep -q '^frontend/' && [[ -f frontend/package.json ]]; then
    if [[ -d frontend/node_modules ]]; then
      (cd frontend && pnpm run test && pnpm run build)
    else
      echo "warn: frontend/ staged but no node_modules (cd frontend && pnpm install)" >&2
    fi
  fi
  if [[ -f pom.xml ]] && command -v mvn >/dev/null 2>&1; then
    if echo "$STAGED" | grep -qE '\.(java|xml)$'; then
      mvn -q test
    fi
  fi
fi

echo "pre-commit-verify: ok"
