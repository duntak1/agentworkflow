#!/usr/bin/env bash
# Run verification commands from PROJECT_CONFIG and/or AT-T Verify column.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"
# shellcheck source=_aw-verify-lib.sh
source "${SCRIPT_DIR}/_aw-verify-lib.sh"

ROOT="$(aw_repo_root)"
TASK_ID=""
RUN_CONFIG=true
RUN_E2E=false
RUN_AFFECTED=false

audit_verify() {
  local action="$1" result="$2"
  if [[ -x "${SCRIPT_DIR}/aw-audit.sh" ]]; then
    "${SCRIPT_DIR}/aw-audit.sh" add --task "${TASK_ID:-—}" --action "$action" --result "$result" --evidence "aw verify" >/dev/null || true
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK_ID="${2:-}"; shift 2 ;;
    --config-only) RUN_CONFIG=true; TASK_ID=""; shift ;;
    --run-e2e) RUN_E2E=true; shift ;;
    --affected) RUN_AFFECTED=true; shift ;;
    -h|--help)
      echo "Usage: aw verify [--task AT-T...] [--config-only] [--run-e2e] [--affected]"
      echo "  AT-T Verify may use: shell cmd; TP:docs/quality/test-plans/TP-….md; combine with ;"
      echo "  --run-e2e executes PROJECT_CONFIG e2e/playwright command for TP specs when configured."
      exit 0
      ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

aw_resolve_verify_cmd() {
  local cmd="$1"
  if [[ "$cmd" =~ ^aw[[:space:]] ]]; then
    echo "./scripts/${cmd}"
  else
    echo "$cmd"
  fi
}

run_shell_verify() {
  local label="$1" cmd="$2"
  [[ -z "$cmd" ]] && return 0
  cmd="$(aw_resolve_verify_cmd "$cmd")"
  echo "== ${label}: ${cmd} =="
  (cd "$ROOT" && eval "$cmd") || {
    echo "fail: ${label}" >&2
    return 1
  }
  echo "ok: ${label}"
}

run_tp_verify() {
  local label="$1" spec="$2"
  local tp_rel e2e_cmd
  tp_rel="$(aw_resolve_tp_path "$spec")" || {
    echo "fail: ${label} — TP not found (${spec})" >&2
    return 1
  }
  echo "== ${label}: TP ${tp_rel} =="
  if [[ -n "$TASK_ID" ]] && ! grep -qE "${TASK_ID}|AT-T" "${ROOT}/${tp_rel}" 2>/dev/null; then
    echo "  warn: ${tp_rel} does not mention ${TASK_ID} (optional cross-ref)"
  fi
  if $RUN_E2E; then
    e2e_cmd="$(aw_parse_project_config_cmd "e2e" 2>/dev/null || aw_parse_project_config_cmd "playwright" 2>/dev/null || true)"
    if [[ -z "$e2e_cmd" ]]; then
      echo "fail: ${label} — --run-e2e requested but PROJECT_CONFIG e2e/playwright command is not set" >&2
      return 1
    fi
    run_shell_verify "${label} e2e" "$e2e_cmd"
  else
    echo "  ok: TP file present — execute checklist manually, or pass --run-e2e when configured"
  fi
  return 0
}

run_verify_spec() {
  local label="$1" spec="$2"
  if aw_is_tp_spec "$spec"; then
    run_tp_verify "$label" "$spec"
  else
    run_shell_verify "$label" "$spec"
  fi
}

ERR=0

if $RUN_AFFECTED; then
  if [[ -n "$TASK_ID" ]]; then
    "${SCRIPT_DIR}/aw-context.sh" affected --task "$TASK_ID" || true
  else
    "${SCRIPT_DIR}/aw-context.sh" affected || true
  fi
fi

if [[ -n "$TASK_ID" ]]; then
  atomic="$(aw_resolve_atomic_tasks_file 2>/dev/null || true)"
  if [[ -n "$atomic" ]]; then
    row="$(aw_task_get_row "${ROOT}/${atomic}" "$TASK_ID" 2>/dev/null || true)"
    if [[ -n "$row" ]]; then
      ver="$(echo "$row" | awk -F'\t' '{print $6}')"
      if [[ -n "$ver" && "$ver" != "—" ]]; then
        n=0
        while IFS= read -r spec; do
          n=$((n + 1))
          run_verify_spec "task ${TASK_ID}#${n}" "$spec" || ERR=1
        done < <(aw_verify_specs_from_cell "$ver")
      fi
    fi
  fi
fi

if $RUN_CONFIG; then
  for key in lint format typecheck test build; do
    cmd="$(aw_parse_project_config_cmd "$key" 2>/dev/null || true)"
    if [[ -n "$cmd" ]]; then
      run_shell_verify "$key" "$cmd" || ERR=1
    else
      echo "skip: PROJECT_CONFIG ${key} not set"
    fi
  done
fi

if [[ "$ERR" -eq 0 ]]; then
  echo ""
  echo "aw verify: ok"
  audit_verify "verify" "ok"
else
  echo ""
  echo "aw verify: failed" >&2
  audit_verify "verify" "failed"
  exit 1
fi
