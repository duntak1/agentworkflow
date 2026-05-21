#!/usr/bin/env bash
# Confirm task (DSL 已审 + Plan 可执行) and regenerate ENGINEERING_INDEX.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"
DSL_FILE="${1:-}"
PLAN_FILE="${2:-}"
SKIP_GATE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force|-f) SKIP_GATE=true ;;
    --dsl) DSL_FILE="${2:-}"; shift 2; continue ;;
    --plan) PLAN_FILE="${2:-}"; shift 2; continue ;;
    -h|--help)
      echo "Usage: aw confirm [--force] [--dsl path] [--plan path] [dsl] [plan]"
      echo "  Requires DSL 状态=已审, Plan 状态=可执行 (unless --force)"
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      [[ -z "$DSL_FILE" ]] && DSL_FILE="$1" || PLAN_FILE="${PLAN_FILE:-$1}"
      ;;
  esac
  shift
done

resolve_path() {
  local p="$1"
  [[ -z "$p" ]] && return 1
  [[ -f "${ROOT}/${p}" ]] && echo "$p" && return 0
  [[ -f "$p" ]] && echo "${p#${ROOT}/}" && return 0
  return 1
}

DSL_FILE="$(resolve_path "$DSL_FILE" 2>/dev/null || true)"
PLAN_FILE="$(resolve_path "$PLAN_FILE" 2>/dev/null || true)"

if [[ -z "$DSL_FILE" ]]; then
  echo "error: specify DSL file, e.g. aw confirm docs/dsl/DSL_DRAFT.md" >&2
  exit 1
fi

dsl_ok=false
plan_ok=false

if grep -qE '状态[^|]*\|[^|]*已审' "${ROOT}/${DSL_FILE}" 2>/dev/null; then
  dsl_ok=true
fi

if [[ -n "$PLAN_FILE" ]] && grep -qE '状态[^|]*\|[^|]*可执行' "${ROOT}/${PLAN_FILE}" 2>/dev/null; then
  plan_ok=true
fi

if ! $SKIP_GATE; then
  if ! $dsl_ok; then
    echo "error: DSL 元数据状态须为「已审」: ${DSL_FILE}" >&2
    echo "  修正后重试，或 aw confirm --force" >&2
    exit 1
  fi
  if [[ -n "$PLAN_FILE" ]] && ! $plan_ok; then
    echo "error: Plan 元数据状态须为「可执行」: ${PLAN_FILE}" >&2
    exit 1
  fi
  if [[ -z "$PLAN_FILE" ]]; then
    echo "error: specify Plan file, e.g. aw confirm docs/dsl/DSL_DRAFT.md docs/plans/PLAN_xxx.md" >&2
    echo "  or aw confirm --force ... to skip gates" >&2
    exit 1
  fi
fi

ATOMIC_FILE=""
ATOMIC_FILE="$(aw_resolve_atomic_tasks_file "$PLAN_FILE" 2>/dev/null || true)"
if [[ -z "$ATOMIC_FILE" ]]; then
  base="$(basename "$PLAN_FILE" .md)"
  slug="${base#PLAN_}"
  [[ -f "${ROOT}/docs/plans/ATOMIC_TASKS_${slug}.md" ]] && ATOMIC_FILE="docs/plans/ATOMIC_TASKS_${slug}.md"
fi

aw_write_workflow_json "$DSL_FILE" "$PLAN_FILE" "${ATOMIC_FILE:-}"

"${SCRIPT_DIR}/generate-file-index.sh" >/dev/null 2>&1 || true
AW_INDEX_MODE=confirm exec "${SCRIPT_DIR}/generate-engineering-index.sh" "$DSL_FILE" "$PLAN_FILE" --confirm
