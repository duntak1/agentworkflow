#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
REQ_DIR="${ROOT}/docs/requirements"
INDEX="${REQ_DIR}/INDEX.md"
ERR=0

fail() { echo "fail: $*" >&2; ERR=1; }
ok() { echo "ok  $*"; }

extract_meta_field() {
  local file="$1" field="$2"
  local line
  line="$(grep -E "^\|[[:space:]]*\*?\*?${field}\*?\*?[[:space:]]*\|" "$file" 2>/dev/null | head -1 || true)"
  [[ -z "$line" ]] && return 1
  echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}' | tr -d '`' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

check_linked_path() {
  local file="$1" field="$2" ref="$3"
  [[ -z "$ref" || "$ref" == "—" || "$ref" == "-" ]] && return 0
  if [[ -f "${ROOT}/${ref}" ]]; then
    ok "$(basename "$file"): ${field} ${ref}"
  else
    fail "$(basename "$file"): ${field} missing: ${ref}"
  fi
}

echo "== REQ index check =="

if [[ ! -d "$REQ_DIR" ]]; then
  echo "skip: no docs/requirements/"
  exit 0
fi

shopt -s nullglob
for f in "${REQ_DIR}"/REQ-*.md; do
  base="$(basename "$f")"
  [[ "$base" == "_TEMPLATE.md" ]] && continue
  if ! grep -qF "${base}" "$INDEX" 2>/dev/null; then
    echo "missing in INDEX: docs/requirements/${base}"
    ERR=1
  else
    ok "docs/requirements/${base}"
  fi
  dsl_ref="$(extract_meta_field "$f" "联动 DSL" 2>/dev/null || true)"
  plan_ref="$(extract_meta_field "$f" "联动 Plan" 2>/dev/null || true)"
  req_type="$(extract_meta_field "$f" "需求类型" 2>/dev/null || true)"
  if [[ -n "$req_type" ]]; then
    ok "$(basename "$f"): 需求类型 ${req_type}"
  else
    fail "$(basename "$f"): missing 需求类型"
  fi
  check_linked_path "$f" "联动 DSL" "$dsl_ref"
  check_linked_path "$f" "联动 Plan" "$plan_ref"
done

if [[ ! -f "$INDEX" ]]; then
  echo "warn: INDEX.md missing"
  exit 0
fi

if grep -q '需求类型' "$INDEX" 2>/dev/null; then
  ok "INDEX has 需求类型 column"
else
  req_count="$(find "$REQ_DIR" -maxdepth 1 -name 'REQ-*.md' 2>/dev/null | wc -l | tr -d '[:space:]')"
  if [[ "${req_count:-0}" == "0" ]]; then
    echo "warn: INDEX missing 需求类型 column (no REQ entries yet)"
  else
    fail "INDEX missing 需求类型 column"
  fi
fi

exit "$ERR"
