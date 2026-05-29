#!/usr/bin/env bash
# Validate skill/ source in repo (no sync required).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILL_SRC="${ROOT}/skill"
ERR=0

need() {
  [[ -e "${SKILL_SRC}/$1" ]] && echo "ok  skill/$1" || { echo "missing  skill/$1"; ERR=1; }
}

echo "== skill source check =="
need "SKILL.md"
need "QUICKSTART.md"
need "reference.md"
need "VERSION"
[[ -f "${ROOT}/agent-workflow/templates/memory/INDEX.md" ]] && echo "ok  templates/memory/INDEX.md" || { echo "missing  templates/memory/INDEX.md"; ERR=1; }
[[ -f "${ROOT}/agent-workflow/templates/dsl/DSL_SUITE_INDEX.md" ]] && echo "ok  templates/dsl/DSL_SUITE_INDEX.md" || { echo "missing  templates/dsl/DSL_SUITE_INDEX.md"; ERR=1; }
[[ -f "${ROOT}/agent-workflow/templates/rules/ENGINEERING_RULES.md" ]] && echo "ok  templates/rules/ENGINEERING_RULES.md" || { echo "missing  templates/rules/ENGINEERING_RULES.md"; ERR=1; }
[[ -f "${ROOT}/agent-workflow/templates/audit/AGENT_TRACE.md" ]] && echo "ok  templates/audit/AGENT_TRACE.md" || { echo "missing  templates/audit/AGENT_TRACE.md"; ERR=1; }
[[ -f "${ROOT}/agent-workflow/templates/policy/POLICY.yml" ]] && echo "ok  templates/policy/POLICY.yml" || { echo "missing  templates/policy/POLICY.yml"; ERR=1; }
[[ -f "${ROOT}/agent-workflow/templates/security/SECURITY_FINDINGS.md" ]] && echo "ok  templates/security/SECURITY_FINDINGS.md" || { echo "missing  templates/security/SECURITY_FINDINGS.md"; ERR=1; }
[[ -f "${ROOT}/agent-workflow/templates/release/RELEASE_RECORD.md" ]] && echo "ok  templates/release/RELEASE_RECORD.md" || { echo "missing  templates/release/RELEASE_RECORD.md"; ERR=1; }
[[ -f "${ROOT}/agent-workflow/templates/metrics/DELIVERY_METRICS.md" ]] && echo "ok  templates/metrics/DELIVERY_METRICS.md" || { echo "missing  templates/metrics/DELIVERY_METRICS.md"; ERR=1; }
[[ -f "${ROOT}/agent-workflow/templates/ops/SLO.md" ]] && echo "ok  templates/ops/SLO.md" || { echo "missing  templates/ops/SLO.md"; ERR=1; }
[[ -f "${ROOT}/agent-workflow/templates/agents/AGENT_ROLES.md" ]] && echo "ok  templates/agents/AGENT_ROLES.md" || { echo "missing  templates/agents/AGENT_ROLES.md"; ERR=1; }
[[ -f "${ROOT}/scripts/aw-report.sh" ]] && echo "ok  scripts/aw-report.sh" || { echo "missing  scripts/aw-report.sh"; ERR=1; }
[[ -f "${ROOT}/scripts/aw-trace.sh" ]] && echo "ok  scripts/aw-trace.sh" || { echo "missing  scripts/aw-trace.sh"; ERR=1; }
[[ -f "${ROOT}/scripts/aw-project.sh" ]] && echo "ok  scripts/aw-project.sh" || { echo "missing  scripts/aw-project.sh"; ERR=1; }
[[ -f "${ROOT}/scripts/aw-code-map.sh" ]] && echo "ok  scripts/aw-code-map.sh" || { echo "missing  scripts/aw-code-map.sh"; ERR=1; }
[[ -f "${ROOT}/agent-workflow/templates/context/CODE_MAP.md" ]] && echo "ok  templates/context/CODE_MAP.md" || { echo "missing  templates/context/CODE_MAP.md"; ERR=1; }

if [[ -f "${ROOT}/.codex-plugin/plugin.json" ]]; then
  echo "ok  .codex-plugin/plugin.json"
else
  echo "missing  .codex-plugin/plugin.json"
  ERR=1
fi

if [[ -f "${ROOT}/.agents/plugins/marketplace.json" ]]; then
  echo "ok  .agents/plugins/marketplace.json"
else
  echo "missing  .agents/plugins/marketplace.json"
  ERR=1
fi

plugin_name="$(grep -E '"name"[[:space:]]*:' "${ROOT}/.codex-plugin/plugin.json" 2>/dev/null | head -1 | sed -E 's/.*"name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' || true)"
market_name="$(grep -E '"name"[[:space:]]*:[[:space:]]*"agent-workflow"' "${ROOT}/.agents/plugins/marketplace.json" 2>/dev/null | head -1 | sed -E 's/.*"name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' || true)"
if [[ -n "$plugin_name" && "$plugin_name" == "$market_name" ]]; then
  echo "ok  marketplace entry matches plugin name (${plugin_name})"
else
  echo "missing  marketplace/plugin name match"
  ERR=1
fi

plugin_ver="$(grep -E '"version"[[:space:]]*:' "${ROOT}/.codex-plugin/plugin.json" 2>/dev/null | head -1 | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' || true)"
pkg_ver_for_plugin="$(tr -d '[:space:]' < "${ROOT}/agent-workflow/VERSION" 2>/dev/null || true)"
if [[ -n "$plugin_ver" && -n "$pkg_ver_for_plugin" && "$plugin_ver" == "$pkg_ver_for_plugin" ]]; then
  echo "ok  plugin.json version matches agent-workflow/VERSION (${plugin_ver})"
else
  echo "missing  plugin.json version match"
  ERR=1
fi

if grep -q '^name: agent-workflow' "${SKILL_SRC}/SKILL.md" 2>/dev/null; then
  echo "ok  SKILL.md frontmatter name"
else
  echo "missing  SKILL.md name: agent-workflow"
  ERR=1
fi

if grep -q 'argument-hint: .*demo' "${SKILL_SRC}/SKILL.md" 2>/dev/null && grep -q 'argument-hint: .*capabilities' "${SKILL_SRC}/SKILL.md" 2>/dev/null && grep -q 'argument-hint: .*dashboard' "${SKILL_SRC}/SKILL.md" 2>/dev/null && grep -q 'argument-hint: .*memory' "${SKILL_SRC}/SKILL.md" 2>/dev/null && grep -q 'argument-hint: .*audit' "${SKILL_SRC}/SKILL.md" 2>/dev/null; then
  echo "ok  SKILL.md argument-hint includes demo/capabilities/dashboard/memory/audit"
else
  echo "missing  SKILL.md argument-hint demo/capabilities/dashboard/memory/audit"
  ERR=1
fi

if grep -q 'Handoff' "${SKILL_SRC}/SKILL.md" 2>/dev/null && grep -q 'Memory' "${SKILL_SRC}/SKILL.md" 2>/dev/null && grep -q 'docs/handoff/PROJECT_HANDOFF.md' "${ROOT}/agent-workflow/INVOCATION.md" 2>/dev/null && grep -q 'docs/memory/' "${ROOT}/agent-workflow/INVOCATION.md" 2>/dev/null; then
  echo "ok  handoff/memory boundary documented"
else
  echo "missing  handoff/memory boundary docs"
  ERR=1
fi

if grep -q 'DSL suite' "${SKILL_SRC}/SKILL.md" 2>/dev/null && grep -q 'aw dsl suite' "${ROOT}/skill/reference.md" 2>/dev/null; then
  echo "ok  DSL suite documented"
else
  echo "missing  DSL suite docs"
  ERR=1
fi

if [[ -f "${ROOT}/scripts/aw-dsl-review.sh" ]] && grep -q 'aw dsl review' "${SKILL_SRC}/SKILL.md" 2>/dev/null && grep -q 'aw dsl review' "${ROOT}/skill/reference.md" 2>/dev/null; then
  echo "ok  DSL review documented"
else
  echo "missing  DSL review docs"
  ERR=1
fi

if [[ -f "${ROOT}/scripts/aw-plan-change.sh" ]] && grep -q 'aw plan change' "${SKILL_SRC}/SKILL.md" 2>/dev/null && grep -q 'aw task split' "${ROOT}/skill/reference.md" 2>/dev/null; then
  echo "ok  plan change/task split documented"
else
  echo "missing  plan change/task split docs"
  ERR=1
fi

if grep -q 'aw metrics summary' "${SKILL_SRC}/SKILL.md" "${ROOT}/skill/reference.md" 2>/dev/null && grep -q 'aw ops gate' "${SKILL_SRC}/SKILL.md" "${ROOT}/skill/reference.md" 2>/dev/null && grep -q 'aw agents gate' "${SKILL_SRC}/SKILL.md" "${ROOT}/skill/reference.md" 2>/dev/null; then
  echo "ok  harness summary/gates documented"
else
  echo "missing  harness summary/gates docs"
  ERR=1
fi

if grep -q 'aw trace check' "${SKILL_SRC}/SKILL.md" "${ROOT}/skill/reference.md" 2>/dev/null && grep -q 'aw policy gate --strict' "${SKILL_SRC}/SKILL.md" "${ROOT}/skill/reference.md" 2>/dev/null; then
  echo "ok  trace/strict policy documented"
else
  echo "missing  trace/strict policy docs"
  ERR=1
fi

if grep -q 'aw report handoff' "${SKILL_SRC}/SKILL.md" "${ROOT}/skill/reference.md" 2>/dev/null && grep -q 'aw report release' "${ROOT}/skill/reference.md" 2>/dev/null; then
  echo "ok  report docs documented"
else
  echo "missing  report docs"
  ERR=1
fi

if grep -q 'aw code-map' "${SKILL_SRC}/SKILL.md" "${ROOT}/skill/reference.md" "${ROOT}/agent-workflow/INVOCATION.md" 2>/dev/null && grep -q 'CODE_MAP' "${SKILL_SRC}/SKILL.md" "${ROOT}/skill/reference.md" 2>/dev/null; then
  echo "ok  code-map docs documented"
else
  echo "missing  code-map docs"
  ERR=1
fi

for phrase in "Think before coding" "Simplicity first" "Mature solutions first" "Surgical changes" "Goal-driven execution"; do
  if grep -qF "$phrase" "${SKILL_SRC}/SKILL.md"; then
    echo "ok  SKILL.md principle: ${phrase}"
  else
    echo "missing  SKILL.md principle: ${phrase}"
    ERR=1
  fi
done

if [[ $(wc -l < "${SKILL_SRC}/SKILL.md") -lt 500 ]]; then
  echo "ok  SKILL.md line count (<500)"
else
  echo "warn  SKILL.md exceeds 500 lines"
fi

if [[ -f "${SKILL_SRC}/VERSION" && -f "${ROOT}/agent-workflow/VERSION" ]]; then
  skill_ver="$(tr -d '[:space:]' < "${SKILL_SRC}/VERSION")"
  pkg_ver="$(tr -d '[:space:]' < "${ROOT}/agent-workflow/VERSION")"
  if [[ "$skill_ver" == "$pkg_ver" ]]; then
    echo "ok  skill/VERSION matches agent-workflow/VERSION (${skill_ver})"
  else
    echo "fail skill/VERSION (${skill_ver}) != agent-workflow/VERSION (${pkg_ver})"
    ERR=1
  fi
fi

exit "$ERR"
