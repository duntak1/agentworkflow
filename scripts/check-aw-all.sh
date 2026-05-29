#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUB="${1:-all}"
ERR=0

run() {
  echo ""
  if "$@"; then
    :
  else
    ERR=1
  fi
}

case "$SUB" in
  layout) run "${SCRIPT_DIR}/check-aw-layout.sh" ;;
  dsl) run "${SCRIPT_DIR}/check-dsl.sh" ;;
  plan) run "${SCRIPT_DIR}/check-plan.sh" ;;
  config) run "${SCRIPT_DIR}/check-project-config.sh" ;;
  req) run "${SCRIPT_DIR}/check-req-index.sh" ;;
  tp) run "${SCRIPT_DIR}/check-test-plan-index.sh" ;;
  docs) run "${SCRIPT_DIR}/check-docs-commands.sh" ;;
  plugin) run "${SCRIPT_DIR}/check-plugin-metadata.sh" ;;
  memory) run "${SCRIPT_DIR}/check-memory.sh" ;;
  changelog) run "${SCRIPT_DIR}/aw-changelog.sh" check ;;
  audit) run "${SCRIPT_DIR}/aw-audit.sh" check ;;
  policy) run "${SCRIPT_DIR}/aw-policy.sh" check ;;
  security) run "${SCRIPT_DIR}/aw-security.sh" check ;;
  service-catalog) run "${SCRIPT_DIR}/aw-service-catalog.sh" check ;;
  release) run "${SCRIPT_DIR}/aw-release.sh" check ;;
  report) run "${SCRIPT_DIR}/aw-report.sh" check ;;
  trace) run "${SCRIPT_DIR}/aw-trace.sh" check ;;
  metrics) run "${SCRIPT_DIR}/aw-metrics.sh" check ;;
  ops) run "${SCRIPT_DIR}/aw-ops.sh" check ;;
  agents) run "${SCRIPT_DIR}/aw-agents.sh" check ;;
  sync) run "${SCRIPT_DIR}/aw-sync.sh" check ;;
  pm) run "${SCRIPT_DIR}/aw-pm.sh" check ;;
  gate) run "${SCRIPT_DIR}/aw-gate.sh" check ;;
  contract) run "${SCRIPT_DIR}/aw-contract.sh" check ;;
  github-pr|pr) run "${SCRIPT_DIR}/aw-github-pr.sh" check ;;
  vcs) run "${SCRIPT_DIR}/aw-vcs.sh" check ;;
  context) run "${SCRIPT_DIR}/aw-context.sh" check ;;
  score) run "${SCRIPT_DIR}/aw-score.sh" check ;;
  recover|recovery) run "${SCRIPT_DIR}/aw-recover.sh" check ;;
  rules) run "${SCRIPT_DIR}/aw-rules.sh" check ;;
  all)
    run "${SCRIPT_DIR}/check-aw-layout.sh"
    run "${SCRIPT_DIR}/check-dsl.sh"
    run "${SCRIPT_DIR}/check-plan.sh"
    run "${SCRIPT_DIR}/check-project-config.sh"
    run "${SCRIPT_DIR}/aw-rules.sh" check
    run "${SCRIPT_DIR}/check-req-index.sh"
    run "${SCRIPT_DIR}/check-test-plan-index.sh"
    run "${SCRIPT_DIR}/check-docs-commands.sh"
    run "${SCRIPT_DIR}/check-plugin-metadata.sh"
    run "${SCRIPT_DIR}/check-memory.sh"
    run "${SCRIPT_DIR}/aw-changelog.sh" check
    run "${SCRIPT_DIR}/aw-audit.sh" check
    run "${SCRIPT_DIR}/aw-policy.sh" check
    run "${SCRIPT_DIR}/aw-security.sh" check
    run "${SCRIPT_DIR}/aw-service-catalog.sh" check
    run "${SCRIPT_DIR}/aw-release.sh" check
    run "${SCRIPT_DIR}/aw-report.sh" check
    run "${SCRIPT_DIR}/aw-trace.sh" check
    run "${SCRIPT_DIR}/aw-metrics.sh" check
    run "${SCRIPT_DIR}/aw-ops.sh" check
    run "${SCRIPT_DIR}/aw-agents.sh" check
    run "${SCRIPT_DIR}/aw-pm.sh" check
    run "${SCRIPT_DIR}/aw-contract.sh" check
    run "${SCRIPT_DIR}/aw-vcs.sh" check
    run "${SCRIPT_DIR}/aw-github-pr.sh" check
    run "${SCRIPT_DIR}/aw-context.sh" check
    run "${SCRIPT_DIR}/aw-score.sh" check
    run "${SCRIPT_DIR}/aw-recover.sh" check
  ;;
  *)
    echo "Usage: check-aw-all.sh [all|layout|dsl|plan|config|rules|req|tp|docs|plugin|memory|changelog|audit|policy|security|service-catalog|release|report|trace|metrics|ops|agents|sync|pm|gate|contract|github-pr|vcs|context|score|recover]" >&2
    exit 1
    ;;
esac

ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATE="${ROOT}/docs/.aw-task-confirmed.json"
if [[ -f "${ROOT}/ENGINEERING_INDEX.md" ]]; then
  echo ""
  echo "ok  ENGINEERING_INDEX.md present"
else
  echo ""
  echo "info: ENGINEERING_INDEX.md not generated (业务仓: aw confirm after DSL 已审 + Plan 可执行)"
fi
if [[ -f "$STATE" ]]; then
  dsl_st="$(grep -E '"dsl_status"' "$STATE" 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' || true)"
  if [[ "$dsl_st" != "已审" ]]; then
    echo "warn: .aw-task-confirmed.json exists but dsl_status=${dsl_st:-?} (stale? re-run aw confirm or remove state file)" >&2
  fi
fi

exit "$ERR"
