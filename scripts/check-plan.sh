#!/usr/bin/env bash
# Validate PLAN_*.md and matching ATOMIC_TASKS_*.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"
# shellcheck source=_aw-verify-lib.sh
source "${SCRIPT_DIR}/_aw-verify-lib.sh"

ROOT="$(aw_repo_root)"
PLANS_DIR="${ROOT}/docs/plans"
ERR=0
WARN=0

warn() { echo "  warn: $*" >&2; WARN=1; }
fail() { echo "  fail: $*" >&2; ERR=1; }
ok() { echo "  ok: $*"; }

echo "== Plan check =="

if [[ ! -d "$PLANS_DIR" ]]; then
  echo "missing  docs/plans/"
  exit 1
fi

extract_meta_path() {
  local file="$1" key="$2"
  local line
  line="$(grep -E "^\|[[:space:]]*\*?\*?${key}\*?\*?[[:space:]]*\|" "$file" 2>/dev/null | head -1 || true)"
  [[ -z "$line" ]] && return 1
  echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}' | tr -d '`'
}

check_plan() {
  local rel="$1"
  local f="${ROOT}/${rel}"
  local base slug atomic_rel atomic_f
  echo "check ${rel}"

  if ! grep -qE '^\|[[:space:]]*\*?\*?状态\*?\*?' "$f"; then
    warn "no 状态 row in metadata"
  fi

  local st
  st="$(aw_read_metadata_status "$f")"
  if [[ "$st" == "可执行" ]]; then
    ok "status 可执行"
  elif [[ "$st" == "草稿" ]]; then
    echo "  info: status 草稿 (approve before confirm)"
  else
    warn "status not parsed (${st})"
  fi

  local dsl_ref=""
  dsl_ref="$(extract_meta_path "$f" "关联 DSL" 2>/dev/null || true)"
  if [[ -n "$dsl_ref" ]]; then
    if [[ -f "${ROOT}/${dsl_ref}" ]]; then
      local dsl_st
      dsl_st="$(aw_read_metadata_status "${ROOT}/${dsl_ref}")"
      if [[ "$dsl_st" == "已审" ]]; then
        ok "linked DSL 已审: ${dsl_ref}"
      else
        warn "linked DSL not 已审: ${dsl_ref} (${dsl_st})"
      fi
    else
      fail "linked DSL missing: ${dsl_ref}"
    fi
  else
    warn "no 关联 DSL in metadata"
  fi

  local req_ref=""
  req_ref="$(extract_meta_path "$f" "关联 REQ" 2>/dev/null || true)"
  if [[ -n "$req_ref" && "$req_ref" != "—" && "$req_ref" != "-" ]]; then
    if [[ -f "${ROOT}/${req_ref}" ]]; then
      ok "linked REQ: ${req_ref}"
      req_plan="$(aw_extract_meta_field "${ROOT}/${req_ref}" "联动 Plan" 2>/dev/null || true)"
      if [[ -n "$req_plan" && "$req_plan" != "—" && "$req_plan" != "$rel" ]]; then
        fail "REQ reverse link mismatch: ${req_ref} 联动 Plan=${req_plan}, expected ${rel}"
      elif [[ "$req_plan" == "$rel" ]]; then
        ok "REQ reverse link: ${req_ref}"
      fi
    else
      fail "linked REQ missing: ${req_ref}"
    fi
  fi

  base="$(basename "$rel" .md)"
  slug="${base#PLAN_}"
  atomic_rel="docs/plans/ATOMIC_TASKS_${slug}.md"
  atomic_f="${ROOT}/${atomic_rel}"

  if [[ ! -f "$atomic_f" ]]; then
    fail "missing ${atomic_rel}"
    return
  fi
  ok "atomic file ${atomic_rel}"

  local count=0 empty_verify=0
  local line id domain ver nf
  while IFS= read -r line; do
    [[ "$line" =~ ^\|[[:space:]]*AT-T ]] || continue
    count=$((count + 1))
    nf="$(awk -F'|' '{print NF}' <<< "$line")"
    id="$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')"
    if [[ "$nf" -ge 8 ]]; then
      domain="$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}')"
      ver="$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $7); print $7}' | tr -d '`')"
      case "$domain" in
        Frontend|Backend|Fullstack|QA|Docs|Ops|Data) ;;
        *) warn "AT-T ${id}: unknown domain (${domain})" ;;
      esac
    else
      domain="—"
      ver="$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $6); print $6}' | tr -d '`')"
      warn "AT-T ${id}: no domain column (recommended: Frontend/Backend/Fullstack/QA/Docs/Ops/Data)"
    fi
    if [[ -z "$ver" || "$ver" == "—" || "$ver" == "-" ]]; then
      empty_verify=$((empty_verify + 1))
      warn "AT-T ${id}: empty Verify column"
    else
      spec=""
      tp_rel=""
      while IFS= read -r spec; do
        if aw_is_tp_spec "$spec"; then
          tp_rel="$(aw_resolve_tp_path "$spec" 2>/dev/null || true)"
          [[ -n "$tp_rel" ]] && ok "AT-T ${id}: TP ${tp_rel}" || warn "AT-T ${id}: TP not found (${spec})"
        fi
      done < <(aw_verify_specs_from_cell "$ver")
    fi
  done < <(grep -E '\| AT-T[0-9]' "$atomic_f" 2>/dev/null || true)

  if [[ "$count" -eq 0 ]]; then
    fail "no AT-T* rows in ${atomic_rel}"
  else
    ok "${count} AT-T* row(s)"
  fi

  # TP hint (optional quality docs)
  if [[ -d "${ROOT}/docs/quality/test-plans" ]]; then
    local tp_count=0
    for _ in "${ROOT}"/docs/quality/test-plans/TP-*.md; do
      [[ -f "$_" ]] || continue
      tp_count=$((tp_count + 1))
    done
    if [[ "$tp_count" -eq 0 ]]; then
      echo "  info: no TP-*.md yet (optional; see aw tp new)"
    else
      ok "test-plans: ${tp_count} TP file(s)"
    fi
  fi
}

found=false
shopt -s nullglob
for f in "${PLANS_DIR}"/PLAN_*.md; do
  [[ -f "$f" ]] || continue
  found=true
  check_plan "docs/plans/$(basename "$f")"
done

$found || echo "info: no PLAN_*.md yet (run aw plan <dsl>)"

exit "$ERR"
