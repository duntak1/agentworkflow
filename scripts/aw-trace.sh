#!/usr/bin/env bash
# Traceability checks across REQ, DSL, Plan, AT-T, TP, Bug, Changelog, and Harness records.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw trace check
  aw trace list

Checks lightweight traceability links:
REQ -> DSL/Plan, Plan -> DSL/ATOMIC, AT-T -> Verify/TP, Bug -> scope,
Changelog -> [Unreleased], and Engineering Harness records.
EOF
  exit "${1:-0}"
}

ok() { echo "ok  $*"; }
warn() { echo "warn  $*" >&2; }
fail() { echo "fail  $*" >&2; ERR=1; }

extract_meta_field() {
  local file="$1" field="$2" line
  line="$(grep -E "^\|[[:space:]]*\*?\*?${field}\*?\*?[[:space:]]*\|" "$file" 2>/dev/null | head -1 || true)"
  [[ -z "$line" ]] && return 1
  echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}' | tr -d '`'
}

check_path_ref() {
  local label="$1" ref="$2"
  [[ -z "$ref" || "$ref" == "—" || "$ref" == "-" ]] && return 0
  if [[ -e "${ROOT}/${ref}" ]]; then
    ok "${label}: ${ref}"
  else
    fail "${label} missing: ${ref}"
  fi
}

current_plan_files() {
  find "${ROOT}/docs/plans" -maxdepth 1 -name 'PLAN_*.md' 2>/dev/null | sort
}

case "$CMD" in
  check)
    ERR=0
    echo "== traceability check =="

    req_count=0
    if [[ -d "${ROOT}/docs/requirements" ]]; then
      while IFS= read -r req; do
        [[ -n "$req" ]] || continue
        req_count=$((req_count + 1))
        rel="${req#"${ROOT}/"}"
        dsl="$(extract_meta_field "$req" "联动 DSL" 2>/dev/null || true)"
        plan="$(extract_meta_field "$req" "联动 Plan" 2>/dev/null || true)"
        req_type="$(extract_meta_field "$req" "需求类型" 2>/dev/null || true)"
        [[ -n "$req_type" ]] && ok "${rel}: 需求类型 ${req_type}" || fail "${rel}: missing 需求类型"
        check_path_ref "${rel}: 联动 DSL" "$dsl"
        check_path_ref "${rel}: 联动 Plan" "$plan"
      done < <(find "${ROOT}/docs/requirements" -maxdepth 1 -name 'REQ-*.md' 2>/dev/null | sort)
    fi
    [[ "$req_count" -gt 0 ]] && ok "REQ entries: ${req_count}" || warn "no REQ entries yet"

    plan_count=0
    while IFS= read -r plan_file; do
      [[ -n "$plan_file" ]] || continue
      plan_count=$((plan_count + 1))
      plan_rel="${plan_file#"${ROOT}/"}"
      dsl_ref="$(extract_meta_field "$plan_file" "关联 DSL" 2>/dev/null || true)"
      if [[ -n "$dsl_ref" ]]; then
        check_path_ref "${plan_rel}: 关联 DSL" "$dsl_ref"
      else
        warn "${plan_rel}: no 关联 DSL metadata"
      fi
      slug="$(basename "$plan_file" .md)"
      slug="${slug#PLAN_}"
      atomic_rel="docs/plans/ATOMIC_TASKS_${slug}.md"
      atomic_file="${ROOT}/${atomic_rel}"
      if [[ -f "$atomic_file" ]]; then
        ok "${plan_rel}: atomic ${atomic_rel}"
        at_count=0
        while IFS= read -r line; do
          [[ "$line" =~ ^\|[[:space:]]*AT-T ]] || continue
          at_count=$((at_count + 1))
          id="$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')"
          nf="$(awk -F'|' '{print NF}' <<< "$line")"
          if [[ "$nf" -ge 8 ]]; then
            verify="$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $7); print $7}' | tr -d '`')"
          else
            verify="$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $6); print $6}' | tr -d '`')"
          fi
          if [[ -z "$verify" || "$verify" == "—" || "$verify" == "-" ]]; then
            fail "${id}: missing verify evidence"
          elif [[ "$verify" == TP:* ]]; then
            tp_ref="${verify#TP:}"
            check_path_ref "${id}: TP" "$tp_ref"
          else
            ok "${id}: verify present"
          fi
        done < "$atomic_file"
        [[ "$at_count" -gt 0 ]] && ok "${atomic_rel}: AT-T rows ${at_count}" || fail "${atomic_rel}: no AT-T rows"
      else
        fail "${plan_rel}: missing ${atomic_rel}"
      fi
    done < <(current_plan_files)
    [[ "$plan_count" -gt 0 ]] && ok "Plan entries: ${plan_count}" || warn "no PLAN_*.md yet"

    if [[ -f "${ROOT}/docs/handoff/AI_BUG_LOG.md" ]]; then
      ok "bug ledger: docs/handoff/AI_BUG_LOG.md"
      if grep -Eq '\|[[:space:]]*(open|investigating)[[:space:]]*\|' "${ROOT}/docs/handoff/AI_BUG_LOG.md"; then
        warn "bug ledger contains open/investigating bugs"
      fi
    else
      fail "missing bug ledger"
    fi

    "${SCRIPT_DIR}/aw-changelog.sh" check || ERR=1
    "${SCRIPT_DIR}/aw-audit.sh" check || ERR=1
    "${SCRIPT_DIR}/aw-policy.sh" check || ERR=1
    "${SCRIPT_DIR}/aw-security.sh" check || ERR=1
    "${SCRIPT_DIR}/aw-release.sh" check || ERR=1
    "${SCRIPT_DIR}/aw-metrics.sh" check || ERR=1
    "${SCRIPT_DIR}/aw-ops.sh" check || ERR=1
    "${SCRIPT_DIR}/aw-agents.sh" check || ERR=1

    if [[ "$ERR" -eq 0 ]]; then
      echo "traceability: ok"
    else
      echo "traceability: failed" >&2
      exit "$ERR"
    fi
    ;;
  list)
    echo "== trace files =="
    for p in \
      docs/requirements/INDEX.md \
      docs/dsl \
      docs/plans \
      docs/quality/test-plans \
      docs/handoff/AI_BUG_LOG.md \
      docs/audit/AGENT_TRACE.md \
      docs/policy/POLICY_DECISIONS.md \
      docs/security/SECURITY_FINDINGS.md \
      docs/release/RELEASE_RECORD.md \
      docs/metrics/DELIVERY_METRICS.md \
      docs/ops/INCIDENTS.md \
      docs/agents/AGENT_REVIEWS.md \
      agent-workflow/CHANGELOG.md CHANGELOG.md; do
      [[ -e "${ROOT}/${p}" ]] && echo "$p"
    done
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
