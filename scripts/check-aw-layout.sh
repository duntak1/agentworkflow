#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
ERR=0

check() {
  if [[ -e "${ROOT}/$1" ]]; then
    echo "ok  $1"
  else
    echo "missing  $1"
    ERR=1
  fi
}

echo "== agent-workflow layout check =="
check "reference/README.md"
if [[ -f "${ROOT}/reference/manifest.yaml" ]]; then
  check "reference/manifest.yaml"
else
  check "reference/manifest.yaml.example"
fi
check "docs/dsl/DSL_SPEC_TEMPLATE.md"
check "docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md"
check "docs/plans/_TEMPLATE_PLAN.md"
check "docs/PROJECT_CONFIG.md"
check "docs/FILE_INDEX.md"
check "docs/ENGINEERING_RULES.md"
check "docs/SERVICE_CATALOG.md"
check "docs/handoff/PROJECT_HANDOFF.md"
check "docs/handoff/AI_BUG_LOG.md"
check "docs/memory/INDEX.md"
check "docs/audit/AGENT_TRACE.md"
check "docs/policy/POLICY.yml"
check "docs/policy/POLICY_DECISIONS.md"
check "docs/security/SECURITY_FINDINGS.md"
check "docs/security/DEPENDENCY_REVIEW.md"
check "docs/release/ENVIRONMENTS.md"
check "docs/release/RELEASE_RECORD.md"
check "docs/metrics/DELIVERY_METRICS.md"
check "docs/ops/SLO.md"
check "docs/ops/INCIDENTS.md"
check "docs/ops/RUNBOOKS.md"
check "docs/agents/AGENT_ROLES.md"
check "docs/agents/AGENT_HANDOFFS.md"
check "docs/agents/AGENT_REVIEWS.md"
check "docs/reports"

exit "$ERR"
