#!/usr/bin/env bash
# Write a generated DSL markdown file to the configured docs/dsl path.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
MANIFEST="${ROOT}/reference/manifest.yaml"
INPUT_FILE=""
OUT_FILE=""

usage() {
  cat <<'EOF'
Usage:
  aw dsl apply [--file DSL.md] [--out docs/dsl/DSL_DRAFT.md]

Reads from stdin when --file is omitted. Default output comes from
reference/manifest.yaml output.draft_file, falling back to docs/dsl/DSL_DRAFT.md.
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file|-f) INPUT_FILE="${2:-}"; shift 2 ;;
    --out|-o) OUT_FILE="${2:-}"; shift 2 ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown: $1" >&2; usage 1 ;;
  esac
done

if [[ -z "$OUT_FILE" ]]; then
  draft_file="$(grep -E '^[[:space:]]*draft_file:' "$MANIFEST" 2>/dev/null | head -1 | sed 's/.*draft_file:[[:space:]]*//' | tr -d '"' | tr -d "'" || true)"
  dsl_dir="$(grep -E '^[[:space:]]*dsl_dir:' "$MANIFEST" 2>/dev/null | head -1 | sed 's/.*dsl_dir:[[:space:]]*//' | tr -d '"' | tr -d "'" || true)"
  OUT_FILE="${dsl_dir:-docs/dsl}/${draft_file:-DSL_DRAFT.md}"
fi

case "$OUT_FILE" in
  docs/dsl/*.md) ;;
  *) echo "error: --out must be under docs/dsl/*.md: ${OUT_FILE}" >&2; exit 1 ;;
esac

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
if [[ -n "$INPUT_FILE" ]]; then
  [[ -f "$INPUT_FILE" ]] || { echo "error: input file not found: $INPUT_FILE" >&2; exit 1; }
  cp "$INPUT_FILE" "$TMP"
else
  cat > "$TMP"
fi

grep -qE '^# ' "$TMP" || { echo "error: DSL must be Markdown with a top-level heading" >&2; exit 1; }
grep -qE '^\|[[:space:]]*\*?\*?状态\*?\*?[[:space:]]*\|' "$TMP" || { echo "error: DSL metadata must include 状态 row" >&2; exit 1; }
grep -qE '验收' "$TMP" || { echo "error: DSL must include 验收 section" >&2; exit 1; }

mkdir -p "${ROOT}/$(dirname "$OUT_FILE")"
cp "$TMP" "${ROOT}/${OUT_FILE}"
echo "ok: wrote ${OUT_FILE}"
aw_refresh_engineering_index
echo "next: ./scripts/aw check dsl → ./scripts/aw approve dsl ${OUT_FILE}"
