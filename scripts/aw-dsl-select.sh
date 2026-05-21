#!/usr/bin/env bash
# List / select active DSL file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
CMD="${1:-list}"
shift || true
ACTIVE_FILE="${ROOT}/docs/.aw-active-dsl"
active=""
[[ -f "$ACTIVE_FILE" ]] && active="$(tr -d '[:space:]' < "$ACTIVE_FILE")"

usage() {
  cat <<'EOF'
Usage:
  aw dsl list
  aw dsl use <path|slug>
  aw dsl suite <slug> "title"
EOF
  exit "${1:-0}"
}

resolve_dsl_path() {
  local arg="$1" slug upper_slug slug_dash
  [[ -z "$arg" ]] && return 1
  [[ -f "${ROOT}/${arg}" ]] && { echo "${arg#${ROOT}/}"; return 0; }
  [[ -d "${ROOT}/${arg}" && -f "${ROOT}/${arg}/INDEX.md" ]] && { echo "${arg#${ROOT}/}/INDEX.md"; return 0; }
  [[ -f "$arg" ]] && { echo "${arg#${ROOT}/}"; return 0; }
  [[ -d "$arg" && -f "$arg/INDEX.md" ]] && { echo "${arg#${ROOT}/}/INDEX.md"; return 0; }
  slug="$arg"
  slug="${slug##*/}"
  slug="${slug#DSL_}"
  slug="${slug#dsl_}"
  slug="${slug%.md}"
  slug_dash="$(echo "$slug" | tr '[:upper:]_' '[:lower:]-' | tr -cs 'a-z0-9-' '-' | sed 's/^-//;s/-$//')"
  upper_slug="$(echo "$slug_dash" | tr '[:lower:]-' '[:upper:]_')"
  for p in "${ROOT}/docs/dsl/DSL_${upper_slug}.md" "${ROOT}/docs/dsl/DSL_${slug}.md" "${ROOT}/docs/dsl/${slug}.md"; do
    [[ -f "$p" ]] && { echo "docs/dsl/$(basename "$p")"; return 0; }
  done
  for d in "${ROOT}/docs/dsl/DSL_${upper_slug}" "${ROOT}/docs/dsl/DSL_${slug}"; do
    [[ -d "$d" && -f "$d/INDEX.md" ]] && { echo "docs/dsl/$(basename "$d")/INDEX.md"; return 0; }
  done
  return 1
}

case "$CMD" in
  list)
    echo "== DSL files =="
    shopt -s nullglob
    any=false
    for f in "${ROOT}"/docs/dsl/*.md; do
      base="$(basename "$f")"
      case "$base" in README.md|DSL_SPEC_TEMPLATE.md|FRONTEND_PAGE_SPEC_TEMPLATE.md|DSL_SUITE_*.md) continue ;; esac
      any=true
      rel="docs/dsl/${base}"
      mark=" "
      [[ "$rel" == "$active" ]] && mark="*"
      echo "${mark} ${rel}"
    done
    for d in "${ROOT}"/docs/dsl/DSL_*; do
      [[ -d "$d" && -f "$d/INDEX.md" ]] || continue
      any=true
      rel="docs/dsl/$(basename "$d")/INDEX.md"
      mark=" "
      [[ "$rel" == "$active" ]] && mark="*"
      echo "${mark} ${rel}"
    done
    $any || echo "（无）— create via aw dsl / aw dsl apply"
    [[ -n "$active" ]] && echo "" && echo "Active: ${active}"
    true
    ;;
  use)
    target="${1:-}"
    [[ -n "$target" ]] || { echo "error: aw dsl use <path|slug>" >&2; exit 1; }
    rel="$(resolve_dsl_path "$target")" || { echo "error: not found: $target" >&2; exit 1; }
    mkdir -p "${ROOT}/docs"
    echo "$rel" > "$ACTIVE_FILE"
    echo "ok: active DSL → ${rel}"
    ;;
  -h|--help) usage 0 ;;
  *) echo "Unknown: $CMD" >&2; usage 1 ;;
esac
