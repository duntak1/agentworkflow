#!/usr/bin/env bash
# Automatic gate runner for critical agent-workflow lifecycle points.
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
  aw gate init
  aw gate check
  aw gate index-refresh
  aw gate pre-commit
  aw gate task [--task AT-T...]
  aw gate pr [--strict]
  aw gate release [--strict]
EOF
  exit "${1:-0}"
}

ensure_gate_docs() {
  local templates
  templates="$(aw_templates_dir)"
  mkdir -p "${ROOT}/docs/hooks"
  [[ -f "${ROOT}/docs/hooks/HOOKS.md" ]] || cp "${templates}/hooks/HOOKS.md" "${ROOT}/docs/hooks/HOOKS.md"
}

run_or_mark() {
  local label="$1"
  shift
  echo ""
  echo "== ${label} =="
  if "$@"; then
    echo "ok  ${label}"
  else
    echo "fail ${label}" >&2
    ERR=1
  fi
}

case "$CMD" in
  init)
    ensure_gate_docs
    echo "created/ok: docs/hooks/HOOKS.md"
    ;;
  index-refresh)
    aw_refresh_engineering_index
    ;;
  check)
    ERR=0
    ensure_gate_docs
    run_or_mark "config" "${SCRIPT_DIR}/check-project-config.sh"
    run_or_mark "dsl business gate" "${SCRIPT_DIR}/check-dsl-business-gate.sh"
    run_or_mark "requirements" "${SCRIPT_DIR}/check-req-index.sh"
    run_or_mark "test plans" "${SCRIPT_DIR}/check-test-plan-index.sh"
    run_or_mark "trace" "${SCRIPT_DIR}/aw-trace.sh" check
    run_or_mark "contract" "${SCRIPT_DIR}/aw-contract.sh" check
    run_or_mark "context" "${SCRIPT_DIR}/aw-context.sh" check
    run_or_mark "agents" "${SCRIPT_DIR}/aw-agents.sh" gate
    run_or_mark "score" "${SCRIPT_DIR}/aw-score.sh" check
    exit "$ERR"
    ;;
  pre-commit)
    ERR=0
    ensure_gate_docs
    run_or_mark "dsl business gate" "${SCRIPT_DIR}/check-dsl-business-gate.sh"
    run_or_mark "requirements" "${SCRIPT_DIR}/check-req-index.sh"
    run_or_mark "test plans" "${SCRIPT_DIR}/check-test-plan-index.sh"
    run_or_mark "contract" "${SCRIPT_DIR}/aw-contract.sh" gate
    run_or_mark "context" "${SCRIPT_DIR}/aw-context.sh" check
    run_or_mark "agents" "${SCRIPT_DIR}/aw-agents.sh" gate --strict
    run_or_mark "score" "${SCRIPT_DIR}/aw-score.sh" check
    aw_refresh_engineering_index
    exit "$ERR"
    ;;
  task)
    TASK_ID=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task) TASK_ID="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    ERR=0
    run_or_mark "coding gates" bash -c 'source "'"${SCRIPT_DIR}"'/_aw-task-lib.sh"; aw_gate_coding_ready'
    if [[ -n "$TASK_ID" ]]; then
      run_or_mark "context" "${SCRIPT_DIR}/aw-context.sh" gate --task "$TASK_ID"
      run_or_mark "task lock" "${SCRIPT_DIR}/aw-agents.sh" lock-check --task "$TASK_ID"
    fi
    run_or_mark "verify" "${SCRIPT_DIR}/aw-verify.sh" ${TASK_ID:+--task "$TASK_ID"}
    run_or_mark "trace" "${SCRIPT_DIR}/aw-trace.sh" check
    run_or_mark "score" "${SCRIPT_DIR}/aw-score.sh" record --scope "${TASK_ID:-task}"
    exit "$ERR"
    ;;
  pr)
    STRICT=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --strict) STRICT=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    ERR=0
    run_or_mark "github-pr" "${SCRIPT_DIR}/aw-github-pr.sh" gate
    run_or_mark "contract" "${SCRIPT_DIR}/aw-contract.sh" gate
    run_or_mark "context" "${SCRIPT_DIR}/aw-context.sh" check
    run_or_mark "trace" "${SCRIPT_DIR}/aw-trace.sh" check
    run_or_mark "agents" "${SCRIPT_DIR}/aw-agents.sh" gate --strict
    if $STRICT; then
      run_or_mark "release" "${SCRIPT_DIR}/aw-release.sh" gate --strict-report --strict-policy
    else
      run_or_mark "release" "${SCRIPT_DIR}/aw-release.sh" gate
    fi
    run_or_mark "score" "${SCRIPT_DIR}/aw-score.sh" record --scope pr
    exit "$ERR"
    ;;
  release)
    STRICT=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --strict) STRICT=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    if $STRICT; then
      exec "${SCRIPT_DIR}/aw-release.sh" gate --strict-report --strict-policy --run-security
    fi
    exec "${SCRIPT_DIR}/aw-release.sh" gate
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
