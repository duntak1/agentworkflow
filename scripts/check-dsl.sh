#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"
DSL_DIR="${ROOT}/docs/dsl"
ERR=0
WARN=0

warn() { echo "  warn: $*" >&2; WARN=1; }
ok() { echo "  ok: $*"; }
fail() { echo "  fail: $*" >&2; ERR=1; }

echo "== DSL check =="

if [[ ! -d "$DSL_DIR" ]]; then
  echo "missing  docs/dsl/"
  exit 1
fi

check_linked_path() {
  local label="$1" path="$2"
  [[ -z "$path" || "$path" == "—" ]] && return 0
  path="$(echo "$path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  if [[ -f "${ROOT}/${path}" ]]; then
    ok "${label}: ${path}"
  else
    fail "${label} missing: ${path}"
  fi
}

check_reverse_req_link() {
  local dsl_rel="$1" req_ref="$2"
  [[ -z "$req_ref" || "$req_ref" == "—" || "$req_ref" == "-" ]] && return 0
  [[ -f "${ROOT}/${req_ref}" ]] || return 0
  local req_dsl
  req_dsl="$(aw_extract_meta_field "${ROOT}/${req_ref}" "联动 DSL" 2>/dev/null || true)"
  if [[ -n "$req_dsl" && "$req_dsl" != "—" && "$req_dsl" != "$dsl_rel" ]]; then
    fail "REQ reverse link mismatch: ${req_ref} 联动 DSL=${req_dsl}, expected ${dsl_rel}"
  elif [[ "$req_dsl" == "$dsl_rel" ]]; then
    ok "REQ reverse link: ${req_ref}"
  fi
}

check_reverse_plan_link() {
  local dsl_rel="$1" plan_ref="$2"
  [[ -z "$plan_ref" || "$plan_ref" == "—" || "$plan_ref" == "-" ]] && return 0
  [[ -f "${ROOT}/${plan_ref}" ]] || return 0
  local plan_dsl
  plan_dsl="$(aw_extract_meta_field "${ROOT}/${plan_ref}" "关联 DSL" 2>/dev/null || true)"
  if [[ -n "$plan_dsl" && "$plan_dsl" != "$dsl_rel" ]]; then
    fail "Plan reverse link mismatch: ${plan_ref} 关联 DSL=${plan_dsl}, expected ${dsl_rel}"
  elif [[ "$plan_dsl" == "$dsl_rel" ]]; then
    ok "Plan reverse link: ${plan_ref}"
  fi
}

check_file() {
  local rel="$1"
  local f="${ROOT}/${rel}"
  [[ -f "$f" ]] || return 0
  echo "check ${rel}"

  if ! grep -qE '^\|[[:space:]]*\*?\*?状态\*?\*?' "$f"; then
    warn "no 状态 row in metadata"
  fi
  if ! grep -qE '验收' "$f"; then
    warn "no 验收 section"
  fi

  local st
  st="$(aw_read_metadata_status "$f")"
  if [[ "$st" == "已审" ]]; then
    ok "status 已审"
    local plan_ref req_ref
    plan_ref="$(aw_extract_meta_field "$f" "关联 Plan" 2>/dev/null || true)"
    req_ref="$(aw_extract_meta_field "$f" "关联 REQ" 2>/dev/null || true)"
    if [[ -n "$plan_ref" ]]; then
      check_linked_path "关联 Plan" "$plan_ref"
      check_reverse_plan_link "$rel" "$plan_ref"
    else
      warn "已审 but no 关联 Plan (add after aw plan)"
    fi
    if [[ -n "$req_ref" ]]; then
      check_linked_path "关联 REQ" "$req_ref"
      check_reverse_req_link "$rel" "$req_ref"
    fi
  else
    echo "  info: status ${st} (gate for business code until 已审)"
  fi
}

check_suite() {
  local rel_dir="$1"
  local idx="${rel_dir}/INDEX.md"
  local f="${ROOT}/${idx}"
  echo "check ${rel_dir}/"
  check_file "$idx"
  local required=(
    "00-requirements.md"
    "10-pages.md"
    "20-interactions.md"
    "30-events.md"
    "40-boundaries.md"
    "90-acceptance.md"
  )
  local part
  for part in "${required[@]}"; do
    if [[ -f "${ROOT}/${rel_dir}/${part}" ]]; then
      ok "suite part: ${part}"
    else
      fail "suite part missing: ${rel_dir}/${part}"
    fi
  done
  if grep -Rqi '待填写' "${ROOT}/${rel_dir}" 2>/dev/null; then
    warn "suite still contains 待填写"
  fi
}

shopt -s nullglob
found=false
seen=""
for f in "${DSL_DIR}"/*.md; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f")"
  case "$base" in
    README.md|DSL_SPEC_TEMPLATE.md|FRONTEND_PAGE_SPEC_TEMPLATE.md|DSL_SUITE_*.md) continue ;;
  esac
  [[ "$seen" == *"|${base}|"* ]] && continue
  seen="${seen}|${base}|"
  found=true
  check_file "docs/dsl/${base}"
done

for d in "${DSL_DIR}"/DSL_*; do
  [[ -d "$d" && -f "$d/INDEX.md" ]] || continue
  found=true
  check_suite "docs/dsl/$(basename "$d")"
done

$found || echo "info: no DSL_*.md or *_DRAFT.md yet"

if [[ -f "${ROOT}/reference/manifest.yaml" ]]; then
  echo "check reference/manifest.yaml"
  dsl_out=""
  dsl_out="$(grep -E '^[[:space:]]*dsl_file:' "${ROOT}/reference/manifest.yaml" 2>/dev/null | head -1 | sed 's/.*dsl_file:[[:space:]]*//' | tr -d '"' | tr -d "'" || true)"
  if [[ -n "$dsl_out" ]]; then
    if [[ -f "${ROOT}/${dsl_out}" ]]; then
      ok "manifest dsl_file → ${dsl_out}"
    else
      warn "manifest dsl_file not found yet: ${dsl_out}"
    fi
  fi
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    case "$path" in
      inputs/*|source/*)
        if [[ ! -e "${ROOT}/reference/${path}" && ! -e "${ROOT}/reference/${path#inputs/}" && ! -e "${ROOT}/${path}" ]]; then
          warn "manifest path not found (ok if not added yet): ${path}"
        fi
        ;;
    esac
  done < <(grep -E '^[[:space:]]+path:[[:space:]]+' "${ROOT}/reference/manifest.yaml" | sed 's/.*path:[[:space:]]*//' | tr -d '"' | tr -d "'")
fi

exit "$ERR"
