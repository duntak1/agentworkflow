#!/usr/bin/env bash
# Write generated Plan and ATOMIC_TASKS markdown files into docs/plans.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
PLAN_IN=""
ATOMIC_IN=""
SLUG=""
DSL_FILE=""

usage() {
  cat <<'EOF'
Usage:
  aw plan apply --plan-file PLAN.md --atomic-file ATOMIC_TASKS.md [--slug name] [--dsl docs/dsl/DSL_DRAFT.md]

Writes:
  docs/plans/PLAN_<slug>.md
  docs/plans/ATOMIC_TASKS_<slug>.md
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan-file) PLAN_IN="${2:-}"; shift 2 ;;
    --atomic-file) ATOMIC_IN="${2:-}"; shift 2 ;;
    --slug) SLUG="${2:-}"; shift 2 ;;
    --dsl) DSL_FILE="${2:-}"; shift 2 ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown: $1" >&2; usage 1 ;;
  esac
done

[[ -n "$PLAN_IN" && -f "$PLAN_IN" ]] || { echo "error: --plan-file is required" >&2; usage 1; }
[[ -n "$ATOMIC_IN" && -f "$ATOMIC_IN" ]] || { echo "error: --atomic-file is required" >&2; usage 1; }
aw_require_planning_intake_ready

if [[ -z "$DSL_FILE" ]]; then
  DSL_FILE="$(aw_resolve_dsl_file 2>/dev/null || true)"
fi
if [[ -n "$DSL_FILE" && -f "${ROOT}/${DSL_FILE}" ]]; then
  dsl_base="$(basename "$DSL_FILE" .md)"
else
  dsl_base="draft"
fi
if [[ -z "$SLUG" ]]; then
  SLUG="$dsl_base"
  SLUG="${SLUG#DSL_}"
  SLUG="${SLUG#DSL-}"
  SLUG="$(echo "$SLUG" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9_' '_')"
  SLUG="${SLUG##_}"
  SLUG="${SLUG%%_}"
  [[ -n "$SLUG" ]] || SLUG="draft"
fi

PLAN_OUT="docs/plans/PLAN_${SLUG}.md"
ATOMIC_OUT="docs/plans/ATOMIC_TASKS_${SLUG}.md"

grep -qE '^# ' "$PLAN_IN" || { echo "error: Plan must be Markdown with a top-level heading" >&2; exit 1; }
grep -qE '^\|[[:space:]]*\*?\*?状态\*?\*?[[:space:]]*\|' "$PLAN_IN" || { echo "error: Plan metadata must include 状态 row" >&2; exit 1; }
grep -qE '^\|[[:space:]]*AT-T' "$ATOMIC_IN" || { echo "error: ATOMIC_TASKS must include at least one AT-T row" >&2; exit 1; }

mkdir -p "${ROOT}/docs/plans"
cp "$PLAN_IN" "${ROOT}/${PLAN_OUT}"
cp "$ATOMIC_IN" "${ROOT}/${ATOMIC_OUT}"
echo "ok: wrote ${PLAN_OUT}"
echo "ok: wrote ${ATOMIC_OUT}"
aw_refresh_engineering_index
echo "next: ./scripts/aw check plan → ./scripts/aw approve plan ${PLAN_OUT}"
