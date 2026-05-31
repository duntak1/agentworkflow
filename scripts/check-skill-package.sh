#!/usr/bin/env bash
# Validate skill directory layout (run after sync-skill).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="${1:-}"

if [[ -z "$SKILL_DIR" ]]; then
  if [[ -f "${SCRIPT_DIR}/../SKILL.md" ]]; then
    SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
  else
    SKILL_DIR="${CURSOR_SKILLS_DIR:-$HOME/.cursor/skills}/agent-workflow"
  fi
fi

ERR=0
need() {
  if [[ -e "${SKILL_DIR}/$1" ]]; then
    echo "ok  $1"
  else
    echo "missing  $1"
    ERR=1
  fi
}

echo "== skill package check: ${SKILL_DIR} =="
need "SKILL.md"
need "QUICKSTART.md"
need "reference.md"
need "VERSION"
need "scripts/aw"
need "scripts/aw-dsl-review.sh"
need "scripts/aw-dsl-suite.sh"
need "scripts/aw-demo.sh"
need "scripts/aw-capabilities.sh"
need "scripts/aw-dashboard.sh"
need "scripts/aw-compact.sh"
need "scripts/aw-memory.sh"
need "scripts/aw-bug.sh"
need "scripts/aw-req.sh"
need "scripts/aw-changelog.sh"
need "scripts/aw-audit.sh"
need "scripts/aw-policy.sh"
need "scripts/aw-security.sh"
need "scripts/aw-service-catalog.sh"
need "scripts/aw-release.sh"
need "scripts/aw-report.sh"
need "scripts/aw-trace.sh"
need "scripts/aw-metrics.sh"
need "scripts/aw-ops.sh"
need "scripts/aw-agents.sh"
need "scripts/aw-sync.sh"
need "scripts/aw-pm.sh"
need "scripts/aw-vcs.sh"
need "scripts/aw-code-map.sh"
need "scripts/check-file-index-sync.sh"
need "scripts/generate-file-index.sh"
need "scripts/_aw-bug-lib.sh"
need "scripts/aw-rules.sh"
need "scripts/check-plugin-metadata.sh"
need "scripts/check-memory.sh"
need "scripts/aw-doctor.sh"
need "scripts/aw-setup.sh"
need "scripts/aw-upgrade.sh"
need "scripts/aw-remove.sh"
need "scripts/aw-status.sh"
need "scripts/aw-dsl-apply.sh"
need "scripts/aw-plan-apply.sh"
need "scripts/aw-plan-change.sh"
need "scripts/aw-config.sh"
need "scripts/aw-project.sh"
need "scripts/aw-ci.sh"
need "scripts/aw-dsl-select.sh"
need "scripts/aw-plan-select.sh"
need "templates/prompts/PROMPT-DSL.md"
need "templates/pm/product/PRODUCT_BRIEF.md"
need "templates/pm/references/README.md"
need "templates/pm/references/design/pencil/README.md"
need "templates/pm/dispatch/TASK_BOARD.md"
need "templates/pm/dashboard/PROJECT_DASHBOARD.md"
need "templates/pm/contracts/INTEGRATION_MATRIX.md"
need "templates/dsl/DSL_SUITE_INDEX.md"
need "templates/dsl/DSL_SUITE_ACCEPTANCE.md"
need "templates/rules/ENGINEERING_RULES.md"
need "templates/memory/INDEX.md"
need "templates/memory/_TEMPLATE.md"
need "templates/audit/AGENT_TRACE.md"
need "templates/policy/POLICY.yml"
need "templates/security/SECURITY_FINDINGS.md"
need "templates/release/RELEASE_RECORD.md"
need "templates/metrics/DELIVERY_METRICS.md"
need "templates/ops/SLO.md"
need "templates/ops/INCIDENTS.md"
need "templates/ops/RUNBOOKS.md"
need "templates/agents/AGENT_ROLES.md"
need "templates/agents/AGENT_HANDOFFS.md"
need "templates/agents/AGENT_REVIEWS.md"
need "templates/agents/AGENT_REGISTRY.md"
need "templates/agents/AGENT_PRESETS.tsv"
need "templates/context/CODE_MAP.md"
need "templates/context/CODE_CONTEXT_INDEX.md"
need "templates/SERVICE_CATALOG.md"
need "package/INVOCATION.md"
need "package/INVOCATION.en.md"
need "package/CROSS_PROJECT_SYNC.md"
need "package/AGENTWORKFLOW_MANUAL.html"
need "package/WINDOWS.md"
need "package/AGENT_RULES.md"
need "package/AICODING_WORKFLOW.md"
need "package/CHANGELOG.md"
need "package/adapters/codex-context/README.md"
need "package/templates/prompts/PROMPT-DSL.md"

if grep -q 'aw confirm <dsl> <plan>' "${SKILL_DIR}/SKILL.md" 2>/dev/null; then
  echo "ok  SKILL.md mentions confirm gates"
else
  echo "warn  SKILL.md may be stale (confirm syntax)"
fi

if grep -q 'aw approve dsl' "${SKILL_DIR}/SKILL.md" 2>/dev/null; then
  echo "ok  SKILL.md mentions approve"
else
  echo "warn  SKILL.md missing approve"
fi

for phrase in "Think before coding" "Simplicity first" "Mature solutions first" "Surgical changes" "Goal-driven execution"; do
  if grep -qF "$phrase" "${SKILL_DIR}/SKILL.md"; then
    echo "ok  SKILL.md principle: ${phrase}"
  else
    echo "missing  SKILL.md principle: ${phrase}"
    ERR=1
  fi
done

if grep -q -- '--run-e2e' "${SKILL_DIR}/scripts/aw-verify.sh" 2>/dev/null; then
  echo "ok  aw-verify supports --run-e2e"
else
  echo "missing  aw-verify --run-e2e"
  ERR=1
fi

for cmd in "doctor" "demo" "dashboard" "status --json" "capabilities" "capabilities --json" "project scan" "project gate" "compact" "memory" "memory chat" "bug" "changelog" "audit" "policy" "policy gate" "security" "security scan" "service-catalog" "service-catalog discover" "release" "release gate" "release gate --strict-report" "release flag-check" "report handoff" "report release" "report check" "metrics" "metrics summary" "ops" "ops gate" "agents" "agents register" "agents list" "agents show" "agents unregister" "agents gate" "agents gate --strict" "sync" "sync init" "sync push" "sync pull" "sync gate" "sync baseline" "sync board" "sync event" "sync change" "sync inbox" "pm" "pm init" "pm intake-check" "pm plan" "pm dashboard" "pm assignments" "pm gate" "pm design" "pm dispatch" "vcs" "vcs gate" "trace check" "plan change" "plan task-add" "task split" "task checkpoint" "rules discover" "file-index" "code-map" "setup" "upgrade" "remove"; do
  if grep -q "aw ${cmd}" "${SKILL_DIR}/SKILL.md" "${SKILL_DIR}/reference.md" 2>/dev/null; then
    echo "ok  docs mention aw ${cmd}"
  else
    echo "missing docs mention aw ${cmd}"
    ERR=1
  fi
done

if grep -q 'demo)' "${SKILL_DIR}/scripts/aw" 2>/dev/null; then
  echo "ok  aw routes demo"
else
  echo "missing  aw demo route"
  ERR=1
fi

if grep -q 'capabilities)' "${SKILL_DIR}/scripts/aw" 2>/dev/null; then
  echo "ok  aw routes capabilities"
else
  echo "missing  aw capabilities route"
  ERR=1
fi

if grep -q 'dashboard)' "${SKILL_DIR}/scripts/aw" 2>/dev/null; then
  echo "ok  aw routes dashboard"
else
  echo "missing  aw dashboard route"
  ERR=1
fi

if grep -q 'memory)' "${SKILL_DIR}/scripts/aw" 2>/dev/null; then
  echo "ok  aw routes memory"
else
  echo "missing  aw memory route"
  ERR=1
fi

if grep -q 'compact)' "${SKILL_DIR}/scripts/aw" 2>/dev/null; then
  echo "ok  aw routes compact"
else
  echo "missing  aw compact route"
  ERR=1
fi

if grep -q 'bug)' "${SKILL_DIR}/scripts/aw" 2>/dev/null; then
  echo "ok  aw routes bug"
else
  echo "missing  aw bug route"
  ERR=1
fi

if grep -q 'vcs)' "${SKILL_DIR}/scripts/aw" 2>/dev/null; then
  echo "ok  aw routes vcs"
else
  echo "missing  aw vcs route"
  ERR=1
fi

if grep -q 'pm)' "${SKILL_DIR}/scripts/aw" 2>/dev/null; then
  echo "ok  aw routes pm"
else
  echo "missing  aw pm route"
  ERR=1
fi

if grep -q 'aw dsl suite' "${SKILL_DIR}/reference.md" 2>/dev/null && grep -q 'aw-dsl-suite.sh' "${SKILL_DIR}/scripts/aw" 2>/dev/null; then
  echo "ok  aw routes dsl suite"
else
  echo "missing  aw dsl suite route/docs"
  ERR=1
fi

if grep -q 'aw dsl review' "${SKILL_DIR}/reference.md" 2>/dev/null && grep -q 'aw-dsl-review.sh' "${SKILL_DIR}/scripts/aw" 2>/dev/null; then
  echo "ok  aw routes dsl review"
else
  echo "missing  aw dsl review route/docs"
  ERR=1
fi

skill_ver="$(tr -d '[:space:]' < "${SKILL_DIR}/VERSION" 2>/dev/null || true)"
pkg_ver="$(tr -d '[:space:]' < "${SKILL_DIR}/package/VERSION" 2>/dev/null || true)"
if [[ -n "$skill_ver" && -n "$pkg_ver" && "$skill_ver" == "$pkg_ver" ]]; then
  echo "ok  VERSION matches package/VERSION (${skill_ver})"
else
  echo "missing  VERSION/package version match"
  ERR=1
fi

exit "$ERR"
