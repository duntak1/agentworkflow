#!/usr/bin/env bash
# End-to-end smoke: skill bundle → aw install → init → gates → confirm.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

SKILL_DIR="${TMP}/skill-bundle"
APP_DIR="${TMP}/app"

echo "== e2e-smoke =="
echo "tmp: ${TMP}"

export AW_SYNC_PROJECT_SKILL=0
export CURSOR_SKILLS_DIR="${TMP}/cursor-skills"
bash "${ROOT}/scripts/sync-skill.sh"
SKILL_DIR="${CURSOR_SKILLS_DIR}/agent-workflow"

[[ -f "${SKILL_DIR}/SKILL.md" ]] || { echo "fail: skill not synced"; exit 1; }
bash "${SKILL_DIR}/scripts/check-skill-package.sh" "${SKILL_DIR}"

mkdir -p "${APP_DIR}"
cd "${APP_DIR}"
# No git init required — aw_repo_root falls back to cwd
"${SKILL_DIR}/scripts/aw" install . --adapters
chmod +x scripts/aw scripts/*.sh

for f in .windsurfrules .clinerules .github/copilot-instructions.md .cursor/rules/agent-workflow.mdc; do
  [[ -e "$f" ]] || { echo "fail: missing adapter $f"; exit 1; }
done

./scripts/aw ci install
[[ -f .github/workflows/agent-workflow.yml ]] || { echo "fail: missing CI workflow"; exit 1; }
REMOVE_OUT="$(./scripts/aw remove --adapters --ci)"
case "$REMOVE_OUT" in *dry-run*) ;; *) echo "fail: remove dry-run"; echo "$REMOVE_OUT"; exit 1 ;; esac

./scripts/aw init
./scripts/aw check layout
[[ -f docs/FILE_INDEX.md ]] || { echo "fail: FILE_INDEX missing"; exit 1; }
[[ -f docs/audit/AGENT_TRACE.md ]] || { echo "fail: audit trace missing"; exit 1; }
[[ -f docs/policy/POLICY.yml ]] || { echo "fail: policy missing"; exit 1; }
[[ -f docs/security/SECURITY_FINDINGS.md ]] || { echo "fail: security findings missing"; exit 1; }
[[ -f docs/SERVICE_CATALOG.md ]] || { echo "fail: service catalog missing"; exit 1; }
[[ -f docs/release/RELEASE_RECORD.md ]] || { echo "fail: release record missing"; exit 1; }
[[ -f docs/metrics/DELIVERY_METRICS.md ]] || { echo "fail: delivery metrics missing"; exit 1; }
[[ -f docs/ops/SLO.md ]] || { echo "fail: ops slo missing"; exit 1; }
[[ -f docs/agents/AGENT_ROLES.md ]] || { echo "fail: agent roles missing"; exit 1; }
[[ -d docs/reports ]] || { echo "fail: reports dir missing"; exit 1; }
grep -q 'CLI / 脚本代码' docs/FILE_INDEX.md || { echo "fail: FILE_INDEX missing CLI section"; exit 1; }
grep -q 'scripts/aw' docs/FILE_INDEX.md || { echo "fail: FILE_INDEX missing scripts/aw"; exit 1; }
grep -q 'scripts/generate-file-index.sh' docs/FILE_INDEX.md || { echo "fail: FILE_INDEX missing generator"; exit 1; }
./scripts/aw file-index
grep -q '项目代码文件索引' docs/FILE_INDEX.md || { echo "fail: aw file-index did not generate detailed index"; exit 1; }
rm -f docs/PROJECT_SCAN.md
PLAN_SCAN_BLOCK="$(./scripts/aw plan docs/dsl/DSL_DRAFT.md 2>&1 >/dev/null || true)"
case "$PLAN_SCAN_BLOCK" in *"missing project scan"*) ;; *) echo "fail: plan should require project scan"; echo "$PLAN_SCAN_BLOCK"; exit 1 ;; esac
./scripts/aw project scan
grep -q 'Project Scan' docs/PROJECT_SCAN.md || { echo "fail: project scan file"; exit 1; }
PLAN_STAGE_BLOCK="$(./scripts/aw plan docs/dsl/DSL_DRAFT.md 2>&1 >/dev/null || true)"
case "$PLAN_STAGE_BLOCK" in *"project stage is not confirmed"*) ;; *) echo "fail: plan should require confirmed project stage"; echo "$PLAN_STAGE_BLOCK"; exit 1 ;; esac
./scripts/aw config init --project-stage "1" --project-kind "1" --build-target "3" --github-url "https://github.com/example/e2e-app" --default-branch "main" --language "shell" --package-manager "none" --frontend "shell" --ui "none" --backend "none" --database "none" --lint "./scripts/aw check layout" --format "./scripts/aw check layout" --typecheck "./scripts/aw check layout" --test "./scripts/aw check tp" --build "./scripts/aw check plan" --e2e "./scripts/aw check tp"
grep -q 'https://github.com/example/e2e-app' docs/PROJECT_CONFIG.md || { echo "fail: github url not written"; exit 1; }
grep -Fq '| **项目阶段** | new |' docs/PROJECT_CONFIG.md || { echo "fail: project stage not written"; exit 1; }
grep -Fq '| **项目类型** | github |' docs/PROJECT_CONFIG.md || { echo "fail: project kind not written"; exit 1; }
grep -Fq '| **构建目标** | fullstack |' docs/PROJECT_CONFIG.md || { echo "fail: build target not written"; exit 1; }
./scripts/aw check config
./scripts/aw changelog add --type Changed --message "E2E direct changelog entry"
CHANGELOG_PATH="$(./scripts/aw changelog path)"
grep -q 'E2E direct changelog entry' "$CHANGELOG_PATH" || { echo "fail: changelog add"; exit 1; }
./scripts/aw changelog check
./scripts/aw audit add --task AT-T0-000 --action "e2e init" --result "initialized Engineering Harness docs" --evidence "docs/audit/AGENT_TRACE.md" --confirm "e2e"
grep -q 'e2e init' docs/audit/AGENT_TRACE.md || { echo "fail: audit add"; exit 1; }
./scripts/aw policy decision --type "new_dependency" --related "AT-T0-000" --decision "approved for e2e only" --risk "none" --follow-up "none" --confirm "e2e"
grep -q 'new_dependency' docs/policy/POLICY_DECISIONS.md || { echo "fail: policy decision"; exit 1; }
./scripts/aw security finding "e2e simulated security finding" --source review --severity low --scope AT-T0-000 --status done --evidence "e2e"
grep -q 'e2e simulated security finding' docs/security/SECURITY_FINDINGS.md || { echo "fail: security finding"; exit 1; }
./scripts/aw security dependency "left-pad-e2e" --version "0.0.0" --purpose "e2e dependency review" --license "MIT" --decision "do not add"
grep -q 'left-pad-e2e' docs/security/DEPENDENCY_REVIEW.md || { echo "fail: dependency review"; exit 1; }
SECURITY_SCAN_OUT="$(./scripts/aw security scan)"
case "$SECURITY_SCAN_OUT" in *"security scan adapters"*);; *) echo "fail: security scan"; echo "$SECURITY_SCAN_OUT"; exit 1 ;; esac
mkdir -p src
cat > package.json <<'EOF'
{"scripts":{"dev":"node src/server.js","start":"node src/server.js"},"dependencies":{"express":"latest","pg":"latest"}}
EOF
cat > src/server.js <<'EOF'
const express = require('express')
const app = express()
const PORT = process.env.PORT || 3000
app.get('/api/health', (req, res) => res.json({ ok: true }))
app.listen(PORT)
EOF
./scripts/aw service-catalog add "e2e shell app" --owner "e2e" --type lib --responsibility "validate service catalog command" --entry "scripts/aw" --verify "./scripts/aw check all" --related "AT-T0-000"
grep -q 'e2e shell app' docs/SERVICE_CATALOG.md || { echo "fail: service catalog add"; exit 1; }
CATALOG_DISCOVER_OUT="$(./scripts/aw service-catalog discover)"
case "$CATALOG_DISCOVER_OUT" in *"service catalog discovery"*) ;; *) echo "fail: service catalog discover"; echo "$CATALOG_DISCOVER_OUT"; exit 1 ;; esac
case "$CATALOG_DISCOVER_OUT" in *routes:*src/server.js*ports/scripts:*package.json*) ;; *) echo "fail: service catalog deep discovery"; echo "$CATALOG_DISCOVER_OUT"; exit 1 ;; esac
./scripts/aw release record --version "unreleased" --env local --scope "e2e release record" --related "AT-T0-000" --evidence "aw check all" --rollback "delete tmp dir" --status verified --confirm "e2e"
grep -q 'e2e release record' docs/release/RELEASE_RECORD.md || { echo "fail: release record"; exit 1; }
./scripts/aw release flag "e2e.flag" --owner "e2e" --default off --scope "e2e" --cleanup "immediate"
grep -q 'e2e.flag' docs/release/FEATURE_FLAGS.md || { echo "fail: release flag"; exit 1; }
./scripts/aw release flag-check
RELEASE_GATE_OUT="$(./scripts/aw release gate)"
case "$RELEASE_GATE_OUT" in *"release gate: ok"*) ;; *) echo "fail: release gate"; echo "$RELEASE_GATE_OUT"; exit 1 ;; esac
case "$RELEASE_GATE_OUT" in *"metrics summary"*) ;; *) echo "fail: release gate metrics summary"; echo "$RELEASE_GATE_OUT"; exit 1 ;; esac
case "$RELEASE_GATE_OUT" in *"ops gate"*) ;; *) echo "fail: release gate ops gate"; echo "$RELEASE_GATE_OUT"; exit 1 ;; esac
case "$RELEASE_GATE_OUT" in *"agents gate"*) ;; *) echo "fail: release gate agents gate"; echo "$RELEASE_GATE_OUT"; exit 1 ;; esac
./scripts/aw policy gate --strict >/dev/null
./scripts/aw metrics record --type deploy --env local --related AT-T0-000 --lead-time "1m" --failed no --note "e2e deploy metric"
grep -q 'e2e deploy metric' docs/metrics/DELIVERY_METRICS.md || { echo "fail: metrics record"; exit 1; }
METRICS_SUMMARY_OUT="$(./scripts/aw metrics summary)"
case "$METRICS_SUMMARY_OUT" in *"metrics summary"*deployments*) ;; *) echo "fail: metrics summary"; echo "$METRICS_SUMMARY_OUT"; exit 1 ;; esac
./scripts/aw ops slo --service "e2e shell app" --owner "e2e" --sli "availability" --slo "99%" --source "manual" --alert "none"
grep -q 'e2e shell app' docs/ops/SLO.md || { echo "fail: ops slo"; exit 1; }
./scripts/aw ops incident --id INC-E2E --severity sev4 --service "e2e shell app" --summary "simulated incident" --status resolved --impact "none" --root-cause "test" --action "none" --related AT-T0-000
grep -q 'INC-E2E' docs/ops/INCIDENTS.md || { echo "fail: ops incident"; exit 1; }
./scripts/aw ops incident --id INC-E2E-OPEN --severity sev2 --service "e2e shell app" --summary "simulated open incident" --status open --impact "none" --related AT-T0-000
if ./scripts/aw ops gate; then
  echo "fail: ops gate should block open sev2 incident"
  exit 1
fi
./scripts/aw ops incident-close --id INC-E2E-OPEN --action "e2e recovered" --root-cause "test" --impact "none"
./scripts/aw ops gate
./scripts/aw ops runbook --scenario "e2e rollback" --service "e2e shell app" --signal "test" --steps "inspect logs" --fix "rerun" --rollback "delete tmp" --owner "e2e"
grep -q 'e2e rollback' docs/ops/RUNBOOKS.md || { echo "fail: ops runbook"; exit 1; }
./scripts/aw agents assign --role developer --owner "e2e-dev" --scope "AT-T0-000" --allowed "scripts/aw" --blocked "unrelated files" --related AT-T0-000
grep -q 'e2e-dev' docs/agents/AGENT_ROLES.md || { echo "fail: agents assign"; exit 1; }
./scripts/aw agents assign --role tester --owner "e2e-tester" --scope "AT-T0-000" --allowed "scripts" --blocked "business code" --related AT-T0-000
./scripts/aw agents handoff --from "e2e-dev" --to "e2e-review" --related AT-T0-000 --scope "e2e" --done "implemented" --todo "review" --risk "none" --evidence "docs/agents/AGENT_HANDOFFS.md"
grep -q 'e2e-review' docs/agents/AGENT_HANDOFFS.md || { echo "fail: agents handoff"; exit 1; }
./scripts/aw agents review --reviewer "e2e-review" --type code --related AT-T0-000 --result pass --evidence "e2e"
grep -q 'e2e-review' docs/agents/AGENT_REVIEWS.md || { echo "fail: agents review"; exit 1; }
./scripts/aw agents gate
PLAN_SYNC_BLOCK="$(./scripts/aw plan docs/dsl/DSL_DRAFT.md 2>&1 >/dev/null || true)"
case "$PLAN_SYNC_BLOCK" in *"requires sync center confirmation"*) ;; *) echo "fail: fullstack plan should require sync center"; echo "$PLAN_SYNC_BLOCK"; exit 1 ;; esac
SYNC_HARNESS="${TMP}/project-harness"
./scripts/aw sync init "$SYNC_HARNESS" --project frontend --agent frontend-agent --role frontend
./scripts/aw sync push --task AT-T0-000 --note "frontend e2e snapshot"
grep -q 'frontend e2e snapshot' "$SYNC_HARNESS/projects/frontend/MANIFEST.md" || { echo "fail: sync push"; exit 1; }
BACKEND_DIR="${TMP}/backend-app"
mkdir -p "$BACKEND_DIR"
(
  cd "$BACKEND_DIR"
  "${SKILL_DIR}/scripts/aw" install . >/dev/null
  chmod +x scripts/aw scripts/*.sh
  ./scripts/aw init >/dev/null
  ./scripts/aw sync init "$SYNC_HARNESS" --project backend --agent backend-agent --role backend >/dev/null
  ./scripts/aw sync pull --from frontend
  grep -q 'frontend e2e snapshot' docs/sync/inbox/frontend/MANIFEST.md || { echo "fail: sync pull"; exit 1; }
  ./scripts/aw sync check
)
REPORT_HANDOFF_OUT="$(./scripts/aw report handoff --focus "e2e early report")"
case "$REPORT_HANDOFF_OUT" in *"Engineering Report"*) ;; *) echo "fail: report handoff title"; echo "$REPORT_HANDOFF_OUT"; exit 1 ;; esac
case "$REPORT_HANDOFF_OUT" in *"Traceability Snapshot"*) ;; *) echo "fail: report handoff trace"; echo "$REPORT_HANDOFF_OUT"; exit 1 ;; esac
case "$REPORT_HANDOFF_OUT" in *"Release Gate Snapshot"*) ;; *) echo "fail: report handoff release gate"; echo "$REPORT_HANDOFF_OUT"; exit 1 ;; esac
./scripts/aw report release --focus "e2e release report" --write
ls docs/reports/REPORT-*release.md >/dev/null 2>&1 || { echo "fail: report release write"; exit 1; }
./scripts/aw report handoff --focus "e2e handoff report" --write
./scripts/aw report check --strict
RELEASE_GATE_REPORT_OUT="$(./scripts/aw release gate --strict-report)"
case "$RELEASE_GATE_REPORT_OUT" in *"report check"*);; *) echo "fail: release gate report check"; echo "$RELEASE_GATE_REPORT_OUT"; exit 1 ;; esac
if ./scripts/aw agents gate --strict; then
  echo "fail: agents strict gate should block overlapping allowed paths"
  exit 1
fi
./scripts/aw agents review --reviewer "e2e-review" --type code --related AT-T0-001 --result block --blockers "e2e blocker" --evidence "e2e"
if ./scripts/aw agents gate; then
  echo "fail: agents gate should block blocking review"
  exit 1
fi
./scripts/aw check audit
./scripts/aw check policy
./scripts/aw check security
./scripts/aw check service-catalog
./scripts/aw check release
./scripts/aw check metrics
./scripts/aw check ops
./scripts/aw check agents
./scripts/aw rules init
RULES_DISCOVER_OUT="$(./scripts/aw rules discover)"
case "$RULES_DISCOVER_OUT" in *"engineering rules discovery"*) ;; *) echo "fail: rules discover title"; echo "$RULES_DISCOVER_OUT"; exit 1 ;; esac
case "$RULES_DISCOVER_OUT" in *"权限入口"*) ;; *) echo "fail: rules discover rows"; echo "$RULES_DISCOVER_OUT"; exit 1 ;; esac
./scripts/aw rules discover --write
grep -q '统一 API Client' docs/ENGINEERING_RULES.md || { echo "fail: rules discover write"; exit 1; }
RULES_REVIEW_OUT="$(./scripts/aw rules review)"
case "$RULES_REVIEW_OUT" in *"Engineering Rules Review"*docs/ENGINEERING_RULES.md*) ;; *) echo "fail: rules review"; echo "$RULES_REVIEW_OUT"; exit 1 ;; esac
./scripts/aw check rules

./scripts/aw memory init
./scripts/aw memory add e2e-decision "E2E decision" --type semantic --source "e2e-smoke" --confidence high --body "Remember that e2e smoke validates memory commands."
./scripts/aw memory chat e2e-chat "E2E chat summary" --summary "Chat discussed preserving conversation continuity through summarized memory." --decisions "Use aw memory chat for summarized conversation memory, not raw transcripts." --todos "Validate chat memory appears in inject output." --open "None." --related "docs/memory/README.md"
MEMORY_LIST_OUT="$(./scripts/aw memory list)"
case "$MEMORY_LIST_OUT" in *MEM-*) ;; *) echo "fail: memory list"; echo "$MEMORY_LIST_OUT"; exit 1 ;; esac
grep -Rqi 'Chat discussed preserving conversation continuity' docs/memory/entries || { echo "fail: chat memory file"; exit 1; }
MEMORY_SEARCH_OUT="$(./scripts/aw memory search e2e)"
case "$MEMORY_SEARCH_OUT" in *e2e*) ;; *) echo "fail: memory search"; echo "$MEMORY_SEARCH_OUT"; exit 1 ;; esac
MEMORY_INJECT_OUT="$(./scripts/aw memory inject e2e)"
case "$MEMORY_INJECT_OUT" in *"Agent Memory Inject"*e2e*) ;; *) echo "fail: memory inject"; echo "$MEMORY_INJECT_OUT"; exit 1 ;; esac
./scripts/aw check memory

# Minimal DSL + Plan for confirm gate
cat > /tmp/aw-e2e-dsl.md <<'EOF'
# DSL — e2e smoke

## 元数据

| 字段 | 内容 |
|------|------|
| **状态** | 草稿 |
| **关联 REQ** | — |

## 验收（可检查）

- [ ] e2e passes
EOF

./scripts/aw dsl apply --file /tmp/aw-e2e-dsl.md
DSL_LIST_OUT="$(./scripts/aw dsl list)"
case "$DSL_LIST_OUT" in *DSL_DRAFT.md*) ;; *) echo "fail: dsl list"; echo "$DSL_LIST_OUT"; exit 1 ;; esac
./scripts/aw dsl use docs/dsl/DSL_DRAFT.md
DSL_REVIEW_OUT="$(./scripts/aw dsl review docs/dsl/DSL_DRAFT.md)"
case "$DSL_REVIEW_OUT" in *"DSL Engineer Review"*允许进入\ Plan*) ;; *) echo "fail: dsl review"; echo "$DSL_REVIEW_OUT"; exit 1 ;; esac
DSL_APPROVE_PLAN_OUT="$(./scripts/aw approve dsl docs/dsl/DSL_DRAFT.md --plan --domain frontend)"
case "$DSL_APPROVE_PLAN_OUT" in *"Plan draft prompt"*ATOMIC_TASKS*"只生成 Frontend"*) ;; *) echo "fail: dsl approve --plan --domain"; echo "$DSL_APPROVE_PLAN_OUT"; exit 1 ;; esac

./scripts/aw dsl suite e2e-flow "E2E flow"
DSL_SUITE_LIST_OUT="$(./scripts/aw dsl list)"
case "$DSL_SUITE_LIST_OUT" in *docs/dsl/DSL_E2E_FLOW/INDEX.md*) ;; *) echo "fail: dsl suite list"; echo "$DSL_SUITE_LIST_OUT"; exit 1 ;; esac
./scripts/aw dsl use e2e-flow
DSL_SUITE_STATUS_OUT="$(./scripts/aw status)"
case "$DSL_SUITE_STATUS_OUT" in *docs/dsl/DSL_E2E_FLOW/INDEX.md*) ;; *) echo "fail: dsl suite status"; echo "$DSL_SUITE_STATUS_OUT"; exit 1 ;; esac
./scripts/aw check dsl
./scripts/aw dsl review docs/dsl/DSL_E2E_FLOW --write
[[ -f docs/dsl/DSL_E2E_FLOW/REVIEW.md ]] || { echo "fail: dsl suite review file"; exit 1; }
grep -q '00-requirements.md' docs/dsl/DSL_E2E_FLOW/REVIEW.md || { echo "fail: dsl suite review content"; exit 1; }
./scripts/aw approve dsl docs/dsl/DSL_E2E_FLOW/INDEX.md
DSL_SUITE_PLAN_OUT="$(./scripts/aw plan docs/dsl/DSL_E2E_FLOW/INDEX.md)"
case "$DSL_SUITE_PLAN_OUT" in *00-requirements.md*90-acceptance.md*) ;; *) echo "fail: dsl suite plan attachments"; echo "$DSL_SUITE_PLAN_OUT"; exit 1 ;; esac
./scripts/aw dsl use docs/dsl/DSL_DRAFT.md

cp docs/PROJECT_CONFIG.md /tmp/aw-e2e-project-config.md
sed 's#https://github.com/example/e2e-app#________________#' /tmp/aw-e2e-project-config.md > docs/PROJECT_CONFIG.md
PLAN_GITHUB_WARN="$(./scripts/aw plan docs/dsl/DSL_DRAFT.md 2>&1 >/dev/null || true)"
case "$PLAN_GITHUB_WARN" in *"GitHub 仓库地址未配置"*|*"GitHub 仓库地址未配置"*) ;; *) echo "fail: plan missing github url warning"; echo "$PLAN_GITHUB_WARN"; exit 1 ;; esac
./scripts/aw config init --project-kind 2 >/dev/null
PLAN_LOCAL_WARN="$(./scripts/aw plan docs/dsl/DSL_DRAFT.md 2>&1 >/dev/null || true)"
case "$PLAN_LOCAL_WARN" in *"GitHub 仓库地址未配置"*|*"项目类型未配置"*) echo "fail: local Git repository should skip github warning"; echo "$PLAN_LOCAL_WARN"; exit 1 ;; *) ;; esac
awk -F'|' 'BEGIN { OFS="|" } /\*\*构建目标\*\*/ { print "| **构建目标** | ________________ |"; next } { print }' /tmp/aw-e2e-project-config.md > docs/PROJECT_CONFIG.md
grep -Fq '| **构建目标** | ________________ |' docs/PROJECT_CONFIG.md || { echo "fail: build target placeholder not restored"; exit 1; }
PLAN_TARGET_WARN="$(./scripts/aw plan docs/dsl/DSL_DRAFT.md 2>&1 >/dev/null || true)"
case "$PLAN_TARGET_WARN" in *"build target is not confirmed"*) ;; *) echo "fail: plan missing build target warning"; echo "$PLAN_TARGET_WARN"; exit 1 ;; esac
cp /tmp/aw-e2e-project-config.md docs/PROJECT_CONFIG.md

cat > /tmp/aw-e2e-plan.md <<'EOF'
# Plan — e2e

## 元数据

| 字段 | 内容 |
|------|------|
| **状态** | 草稿 |
| **关联 DSL** | docs/dsl/DSL_DRAFT.md |

## 目标

Smoke test plan.
EOF

cat > /tmp/aw-e2e-atomic.md <<'EOF'
# Atomic tasks — e2e

| ID | 领域 | 标题 | 状态 | 依赖 | 验证 |
|----|------|------|------|------|------|
| AT-T1-001 | Fullstack | e2e task | 待办 | — | ./scripts/aw check layout |
EOF

./scripts/aw plan apply --plan-file /tmp/aw-e2e-plan.md --atomic-file /tmp/aw-e2e-atomic.md --slug E2E
PLAN_LIST_OUT="$(./scripts/aw plan list)"
case "$PLAN_LIST_OUT" in *PLAN_E2E.md*) ;; *) echo "fail: plan list"; echo "$PLAN_LIST_OUT"; exit 1 ;; esac
./scripts/aw plan use E2E
./scripts/aw approve plan docs/plans/PLAN_E2E.md
./scripts/aw check plan
./scripts/aw check config
./scripts/aw confirm docs/dsl/DSL_DRAFT.md docs/plans/PLAN_E2E.md

[[ -f ENGINEERING_INDEX.md ]] || { echo "fail: ENGINEERING_INDEX.md missing"; exit 1; }
grep -q '任务已确认' ENGINEERING_INDEX.md || grep -q '已审' ENGINEERING_INDEX.md
grep -q 'docs/FILE_INDEX.md' ENGINEERING_INDEX.md || { echo "fail: ENGINEERING_INDEX missing FILE_INDEX"; exit 1; }

[[ -f docs/.aw-workflow.json ]] || { echo "fail: .aw-workflow.json missing"; exit 1; }

if ./scripts/aw task start AT-T1-001; then
  echo "fail: task start should require requirement confirmation"
  exit 1
fi
BRIEF_OUT="$(./scripts/aw task brief AT-T1-001)"
case "$BRIEF_OUT" in *"子任务需求沟通包"*AT-T1-001*) ;; *) echo "fail: task brief"; echo "$BRIEF_OUT"; exit 1 ;; esac
./scripts/aw task confirm AT-T1-001 "已确认：e2e 范围、验收、非目标清楚"
./scripts/aw req new spoken-export "口述新增：导出按钮需要权限控制" --type 口述新增 --impact "页面按钮、后端权限" --acceptance "无权限不可见"
grep -q '需求类型' docs/requirements/INDEX.md || { echo "fail: req index missing type column"; exit 1; }
grep -q '口述新增' docs/requirements/INDEX.md || { echo "fail: spoken req type missing"; exit 1; }
grep -q '口述新增：导出按钮需要权限控制' ENGINEERING_INDEX.md || { echo "fail: engineering index not refreshed for req new"; exit 1; }
if ./scripts/aw task start AT-T1-001; then
  echo "fail: task start should require context gate"
  exit 1
fi
if ./scripts/aw paste task; then
  echo "fail: paste task should require a started/current task"
  exit 1
fi
./scripts/aw context plan --task AT-T1-001
./scripts/aw context gate --task AT-T1-001
./scripts/aw task start AT-T1-001
./scripts/aw req change AT-T1-001 "研发中追加空态验收" --impact "DSL 验收、Plan 范围、ATOMIC 当前任务" --acceptance "空数据时显示明确空态"
grep -q '研发中追加空态验收' docs/requirements/INDEX.md || { echo "fail: req change index"; exit 1; }
grep -q '研发中变更' docs/requirements/INDEX.md || { echo "fail: change req type missing"; exit 1; }
grep -q '研发中需求变更回写' docs/dsl/DSL_DRAFT.md || { echo "fail: req change dsl backwrite"; exit 1; }
grep -q '研发中需求变更回写' docs/plans/PLAN_E2E.md || { echo "fail: req change plan backwrite"; exit 1; }
grep -q '研发中需求变更回写' docs/plans/ATOMIC_TASKS_E2E.md || { echo "fail: req change atomic backwrite"; exit 1; }
if ./scripts/aw task start AT-T1-001; then
  echo "fail: task start should require re-confirmation after req change"
  exit 1
fi
./scripts/aw task brief AT-T1-001 >/dev/null
./scripts/aw task confirm AT-T1-001 "已确认：研发中变更已回写，空态验收清楚"
./scripts/aw context plan --task AT-T1-001
./scripts/aw context gate --task AT-T1-001
./scripts/aw task start AT-T1-001
./scripts/aw plan change --summary "E2E same-scope plan note" --related AT-T1-001 --dsl-update "docs/dsl/DSL_DRAFT.md" --plan-update "docs/plans/PLAN_E2E.md"
grep -q 'E2E same-scope plan note' docs/plans/ATOMIC_TASKS_E2E.md || { echo "fail: plan change note"; exit 1; }
./scripts/aw plan task-add --title "E2E additional task" --domain QA --deps AT-T1-001 --verify "./scripts/aw check layout" --related AT-T1-001
grep -q 'E2E additional task' docs/plans/ATOMIC_TASKS_E2E.md || { echo "fail: plan task-add"; exit 1; }
./scripts/aw task split AT-T1-001 --into "E2E split A; E2E split B" --domain QA --verify "./scripts/aw check layout" --related AT-T1-001
grep -q 'E2E split A' docs/plans/ATOMIC_TASKS_E2E.md || { echo "fail: task split A"; exit 1; }
grep -q 'task split' docs/audit/AGENT_TRACE.md || { echo "fail: task split audit"; exit 1; }
./scripts/aw context gate --task AT-T1-001
./scripts/aw task start AT-T1-001
TASK_PASTE_OUT="$(./scripts/aw paste task)"
case "$TASK_PASTE_OUT" in *AT-T1-001*) ;; *) echo "fail: paste task"; echo "$TASK_PASTE_OUT"; exit 1 ;; esac
./scripts/aw tp new e2e "e2e smoke TP"
TP_FILE="$(ls docs/quality/test-plans/TP-*e2e*.md 2>/dev/null | head -1)"
[[ -n "$TP_FILE" ]] || { echo "fail: tp not created"; exit 1; }
grep -q "$(basename "$TP_FILE")" ENGINEERING_INDEX.md || { echo "fail: engineering index not refreshed for tp new"; exit 1; }
./scripts/aw tp link AT-T1-001 "$TP_FILE"
./scripts/aw check tp
STATUS_OUT="$(./scripts/aw status)"
case "$STATUS_OUT" in *AT-T1-001*) ;; *) echo "fail: status current task"; echo "$STATUS_OUT"; exit 1 ;; esac
HANDOFF_OUT="$(./scripts/aw handoff "e2e handoff")"
case "$HANDOFF_OUT" in *PROJECT_HANDOFF*DSL*PLAN_E2E.md*ATOMIC_TASKS_E2E.md*"新会话启动"*) ;; *) echo "fail: handoff draft content"; echo "$HANDOFF_OUT"; exit 1 ;; esac
./scripts/aw handoff "e2e handoff" --write >/tmp/aw-e2e-handoff-write.out
grep -q 'e2e handoff' docs/handoff/PROJECT_HANDOFF.md || { echo "fail: handoff --write did not update PROJECT_HANDOFF"; exit 1; }
grep -q 'ok  handoff contains: ## 当前目标' /tmp/aw-e2e-handoff-write.out || { echo "fail: handoff --write did not run check"; cat /tmp/aw-e2e-handoff-write.out; exit 1; }
HANDOFF_CHECK_OUT="$(./scripts/aw handoff --check)"
case "$HANDOFF_CHECK_OUT" in *"ok  handoff contains: ## 当前目标"*);; *) echo "fail: handoff --check"; echo "$HANDOFF_CHECK_OUT"; exit 1 ;; esac
PASTE_OUT="$(./scripts/aw paste task)"
case "$PASTE_OUT" in *关联测试计划*) ;;
*) 
  echo "fail: paste task TP summary"
  echo "$PASTE_OUT"
  exit 1
  ;;
esac
./scripts/aw task blocked AT-T1-001
grep -q '阻塞' docs/plans/ATOMIC_TASKS_E2E.md || { echo "fail: task not marked blocked"; exit 1; }
./scripts/aw context gate --task AT-T1-001
./scripts/aw task start AT-T1-001
TASK_COMPLETE_OUT="$(./scripts/aw task complete AT-T1-001 --run-e2e)"
case "$TASK_COMPLETE_OUT" in *"Commit checkpoint"*aw\ commit\ --task\ AT-T1-001*--changelog*) ;; *) echo "fail: task complete missing changelog commit checkpoint"; echo "$TASK_COMPLETE_OUT"; exit 1 ;; esac
grep -q '已完成' docs/plans/ATOMIC_TASKS_E2E.md || { echo "fail: task not marked done"; exit 1; }
./scripts/aw commit --task AT-T1-001 --changelog "Fixed: E2E commit helper changelog entry" >/tmp/aw-e2e-commit.out
grep -q 'E2E commit helper changelog entry' "$CHANGELOG_PATH" || { echo "fail: aw commit --changelog"; exit 1; }

cat >> docs/plans/ATOMIC_TASKS_E2E.md <<'EOF'
| AT-T1-099 | QA | 故意失败任务 | 待办 |  | false |
EOF
./scripts/aw task confirm AT-T1-099 "已确认：故意失败用于验证 Bug 流水"
./scripts/aw context plan --task AT-T1-099
./scripts/aw context gate --task AT-T1-099
./scripts/aw task start AT-T1-099
if ./scripts/aw task complete AT-T1-099; then
  echo "fail: task complete should fail for false verify"
  exit 1
fi
grep -q 'AT-T1-099' docs/handoff/AI_BUG_LOG.md || { echo "fail: bug log missing failed task"; exit 1; }
grep -q '进行中' docs/plans/ATOMIC_TASKS_E2E.md || { echo "fail: failed task should remain in progress"; exit 1; }
./scripts/aw bug add "用户反馈：演示环境保存后列表未刷新" --source chat --scope AT-T1-099 --evidence "manual smoke"
grep -q '用户反馈' docs/handoff/AI_BUG_LOG.md || { echo "fail: manual bug not logged"; exit 1; }
grep -q 'AI_BUG_LOG.md' ENGINEERING_INDEX.md || { echo "fail: engineering index missing bug log"; exit 1; }
./scripts/aw bug list >/dev/null
./scripts/aw task blocked AT-T1-099
./scripts/aw policy diff >/dev/null
./scripts/aw trace check >/dev/null

./scripts/aw doctor
./scripts/aw upgrade --ci

export SKIP_DSL_GATE=1

echo ""
echo "e2e-smoke: ok"
