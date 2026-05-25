#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"

echo "== agent-workflow init =="
echo "Root: ${ROOT}"
echo "Templates: ${TEMPLATES}"

mkdir -p "${ROOT}/reference/inputs" "${ROOT}/reference/source"
aw_copy_if_missing "${TEMPLATES}/reference/README.md" "${ROOT}/reference/README.md"
aw_copy_if_missing "${TEMPLATES}/reference/manifest.yaml.example" "${ROOT}/reference/manifest.yaml.example"
if [[ ! -f "${ROOT}/reference/manifest.yaml" ]]; then
  cp "${TEMPLATES}/reference/manifest.yaml.example" "${ROOT}/reference/manifest.yaml"
  echo "  created: reference/manifest.yaml (from example)"
fi

mkdir -p "${ROOT}/docs/dsl" "${ROOT}/docs/plans" "${ROOT}/docs/requirements" \
  "${ROOT}/docs/handoff" "${ROOT}/docs/quality/test-plans" \
  "${ROOT}/docs/memory/entries" "${ROOT}/docs/memory/archive" \
  "${ROOT}/docs/audit" "${ROOT}/docs/policy" "${ROOT}/docs/security" "${ROOT}/docs/release" \
  "${ROOT}/docs/metrics" "${ROOT}/docs/ops" "${ROOT}/docs/agents" "${ROOT}/docs/reports" \
  "${ROOT}/docs/hooks" "${ROOT}/docs/contracts" "${ROOT}/docs/github" "${ROOT}/docs/score" "${ROOT}/docs/recovery" \
  "${ROOT}/docs/context/tasks"

for f in DSL_SPEC_TEMPLATE.md FRONTEND_PAGE_SPEC_TEMPLATE.md DSL_DRAFT.md \
  DSL_SUITE_INDEX.md DSL_SUITE_REQUIREMENTS.md DSL_SUITE_PAGES.md \
  DSL_SUITE_INTERACTIONS.md DSL_SUITE_EVENTS.md DSL_SUITE_BOUNDARIES.md \
  DSL_SUITE_ACCEPTANCE.md; do
  aw_copy_if_missing "${TEMPLATES}/dsl/${f}" "${ROOT}/docs/dsl/${f}"
done

for f in _TEMPLATE_PLAN.md _TEMPLATE_ATOMIC_TASKS.md; do
  aw_copy_if_missing "${TEMPLATES}/plans/${f}" "${ROOT}/docs/plans/${f}"
done

for f in _TEMPLATE.md INDEX.md README.md; do
  if [[ -f "${TEMPLATES}/quality/test-plans/${f}" ]]; then
    aw_copy_if_missing "${TEMPLATES}/quality/test-plans/${f}" "${ROOT}/docs/quality/test-plans/${f}"
  fi
done

for f in README.md INDEX.md _TEMPLATE.md; do
  if [[ -f "${TEMPLATES}/memory/${f}" ]]; then
    aw_copy_if_missing "${TEMPLATES}/memory/${f}" "${ROOT}/docs/memory/${f}"
  fi
done

if [[ ! -f "${ROOT}/docs/requirements/_TEMPLATE.md" ]]; then
  cat > "${ROOT}/docs/requirements/_TEMPLATE.md" <<'EOF'
# REQ-YYYYMMDD-NN-short-slug

## 元数据

| 字段 | 内容 |
|------|------|
| **ID** | REQ-YYYYMMDD-NN |
| **需求类型** | 口述新增 / 研发中变更 / 补充需求 / 约束规则 |
| **状态** | 草稿 |
| **来源任务** | — |
| **联动 DSL** | docs/dsl/ |
| **联动 Plan** | docs/plans/ |
| **联动 ATOMIC** | — |
EOF
  echo "  created: docs/requirements/_TEMPLATE.md"
fi

if [[ ! -f "${ROOT}/docs/requirements/INDEX.md" ]]; then
  cat > "${ROOT}/docs/requirements/INDEX.md" <<'EOF'
# 需求索引（REQ）

| ID | 标题 | 需求类型 | 状态 | 提出日期 | 备注 |
|----|------|----------|------|----------|------|
EOF
  echo "  created: docs/requirements/INDEX.md"
fi

if [[ ! -f "${ROOT}/docs/dsl/README.md" ]]; then
  cat > "${ROOT}/docs/dsl/README.md" <<'EOF'
# DSL / 页面说明

- 模板：`DSL_SPEC_TEMPLATE.md`、`FRONTEND_PAGE_SPEC_TEMPLATE.md`
- 草稿：`DSL_DRAFT.md`（审阅后改状态为 **已审**）
- 流程：`agent-workflow/PRODUCT_INPUT_WORKFLOW.md`
EOF
  echo "  created: docs/dsl/README.md"
fi

if [[ ! -f "${ROOT}/docs/plans/README.md" ]]; then
  cat > "${ROOT}/docs/plans/README.md" <<'EOF'
# 研发计划

- 模板：`_TEMPLATE_PLAN.md`、`_TEMPLATE_ATOMIC_TASKS.md`
- 前置：DSL 元数据 **状态 = 已审**
- 生成：`./scripts/draft-plan.sh docs/dsl/<file>.md`
EOF
  echo "  created: docs/plans/README.md"
fi

if [[ ! -f "${ROOT}/docs/PROJECT_CONFIG.md" ]]; then
  cat > "${ROOT}/docs/PROJECT_CONFIG.md" <<'EOF'
# 项目配置（人类填写）

| 字段 | 内容 |
|------|------|
| **项目阶段** | ________________ |
| **项目类型** | ________________ |
| **构建目标** | ________________ |
| **项目扫描** | docs/PROJECT_SCAN.md |
| **同步中心** | 未配置 |
| **前后端拓扑** | 待确认 |
| **Issue 系统** | GitHub Issues |
| **GitHub 仓库地址** | ________________ |
| **默认分支** | main |
| **语言** | ________________ |
| **包管理器** | ________________ |
| **前端栈** | ________________ |
| **UI 库** | ________________ |
| **后端栈** | ________________ |
| **数据库** | ________________ |
| **工程规范** | docs/ENGINEERING_RULES.md |

> 项目阶段：`new` = 全新项目，从 reference → DSL → Plan 开始；`existing` = 已有 / 存量项目，先盘点现状、回填一期基线，再生成增量 DSL / Plan。
> 项目类型：`github` = GitHub 仓库，必须配置 GitHub 仓库地址；`local-git` = 本地 Git 仓库，跳过 GitHub 仓库地址。
> 项目扫描：启动后必须先运行 `aw project scan`，由 Agent 依据项目内容判断全新 / 已有，再让工程师确认写入项目阶段。
> 同步中心：构建目标为 `fullstack` 且前后端分仓 / 双项目开发时，必须先用 `aw sync init <project-harness> ...` 建立同步中心，再生成共享 DSL / 协作 Plan / 本地 Plan。

## 本地验证命令

```text
lint：________________
format：________________
typecheck：________________
test：________________
build：________________
e2e：________________
```

与 `agent-workflow/CLAUDE.md` 保持一致。
EOF
  echo "  created: docs/PROJECT_CONFIG.md"
fi

if [[ ! -f "${ROOT}/docs/FILE_INDEX.md" ]]; then
  cat > "${ROOT}/docs/FILE_INDEX.md" <<'EOF'
# FILE_INDEX（项目文件索引）

> 读者：人类工程师。用途是在 AI 代写代码后，快速定位需要人工审阅、手改或重点关注的业务文件。

## 维护规则

- 新增 / 删除 / 重命名业务文件时，请同步更新对应小节的一行说明。
- 只记录业务代码、配置入口、迁移脚本、关键测试文件；不要把生成物、依赖目录、缓存文件写进来。
- 每行说明写清楚“文件职责”和“最近相关任务 / 需求 / Bug”。
- 本文件是人工导航，不是真源；真源仍是代码、DSL、Plan、REQ、测试计划和 Bug 流水。

## 前端

| 路径 | 职责 | 最近关联 |
|------|------|----------|
| | | |

## 后端

| 路径 | 职责 | 最近关联 |
|------|------|----------|
| | | |

## 数据库 / 迁移

| 路径 | 职责 | 最近关联 |
|------|------|----------|
| | | |

## 测试

| 路径 | 职责 | 最近关联 |
|------|------|----------|
| | | |

## 配置 / 启动入口

| 路径 | 职责 | 最近关联 |
|------|------|----------|
| | | |

## 删除 / 重命名记录

| 原路径 | 新路径 / 处理 | 原因 | 最近关联 |
|--------|---------------|------|----------|
| | | | |
EOF
  echo "  created: docs/FILE_INDEX.md"
fi

aw_copy_if_missing "${TEMPLATES}/SERVICE_CATALOG.md" "${ROOT}/docs/SERVICE_CATALOG.md"
aw_copy_if_missing "${TEMPLATES}/audit/AGENT_TRACE.md" "${ROOT}/docs/audit/AGENT_TRACE.md"
aw_copy_if_missing "${TEMPLATES}/policy/POLICY.yml" "${ROOT}/docs/policy/POLICY.yml"
aw_copy_if_missing "${TEMPLATES}/policy/POLICY_DECISIONS.md" "${ROOT}/docs/policy/POLICY_DECISIONS.md"
aw_copy_if_missing "${TEMPLATES}/security/SECURITY_FINDINGS.md" "${ROOT}/docs/security/SECURITY_FINDINGS.md"
aw_copy_if_missing "${TEMPLATES}/security/DEPENDENCY_REVIEW.md" "${ROOT}/docs/security/DEPENDENCY_REVIEW.md"
aw_copy_if_missing "${TEMPLATES}/release/ENVIRONMENTS.md" "${ROOT}/docs/release/ENVIRONMENTS.md"
aw_copy_if_missing "${TEMPLATES}/release/RELEASE_RECORD.md" "${ROOT}/docs/release/RELEASE_RECORD.md"
aw_copy_if_missing "${TEMPLATES}/release/FEATURE_FLAGS.md" "${ROOT}/docs/release/FEATURE_FLAGS.md"
aw_copy_if_missing "${TEMPLATES}/metrics/DELIVERY_METRICS.md" "${ROOT}/docs/metrics/DELIVERY_METRICS.md"
aw_copy_if_missing "${TEMPLATES}/ops/SLO.md" "${ROOT}/docs/ops/SLO.md"
aw_copy_if_missing "${TEMPLATES}/ops/INCIDENTS.md" "${ROOT}/docs/ops/INCIDENTS.md"
aw_copy_if_missing "${TEMPLATES}/ops/RUNBOOKS.md" "${ROOT}/docs/ops/RUNBOOKS.md"
aw_copy_if_missing "${TEMPLATES}/agents/AGENT_ROLES.md" "${ROOT}/docs/agents/AGENT_ROLES.md"
aw_copy_if_missing "${TEMPLATES}/agents/AGENT_HANDOFFS.md" "${ROOT}/docs/agents/AGENT_HANDOFFS.md"
aw_copy_if_missing "${TEMPLATES}/agents/AGENT_REVIEWS.md" "${ROOT}/docs/agents/AGENT_REVIEWS.md"
aw_copy_if_missing "${TEMPLATES}/agents/AGENT_LOCKS.md" "${ROOT}/docs/agents/AGENT_LOCKS.md"
aw_copy_if_missing "${TEMPLATES}/agents/AGENT_HEARTBEATS.md" "${ROOT}/docs/agents/AGENT_HEARTBEATS.md"
aw_copy_if_missing "${TEMPLATES}/hooks/HOOKS.md" "${ROOT}/docs/hooks/HOOKS.md"
aw_copy_if_missing "${TEMPLATES}/contracts/API_CONTRACT.openapi.yaml" "${ROOT}/docs/contracts/API_CONTRACT.openapi.yaml"
aw_copy_if_missing "${TEMPLATES}/contracts/API_CHANGELOG.md" "${ROOT}/docs/contracts/API_CHANGELOG.md"
aw_copy_if_missing "${TEMPLATES}/contracts/CONTRACT_TESTS.md" "${ROOT}/docs/contracts/CONTRACT_TESTS.md"
aw_copy_if_missing "${TEMPLATES}/contracts/MOCK_SERVER.md" "${ROOT}/docs/contracts/MOCK_SERVER.md"
aw_copy_if_missing "${TEMPLATES}/github/PR_CHECKLIST.md" "${ROOT}/docs/github/PR_CHECKLIST.md"
aw_copy_if_missing "${TEMPLATES}/github/REVIEW_GATE.md" "${ROOT}/docs/github/REVIEW_GATE.md"
aw_copy_if_missing "${TEMPLATES}/github/BRANCH_POLICY.md" "${ROOT}/docs/github/BRANCH_POLICY.md"
aw_copy_if_missing "${TEMPLATES}/score/DELIVERY_SCORE.md" "${ROOT}/docs/score/DELIVERY_SCORE.md"
aw_copy_if_missing "${TEMPLATES}/recovery/RECOVERY_PLAYBOOK.md" "${ROOT}/docs/recovery/RECOVERY_PLAYBOOK.md"
aw_copy_if_missing "${TEMPLATES}/context/CONTEXT_CONFIG.md" "${ROOT}/docs/context/CONTEXT_CONFIG.md"
aw_copy_if_missing "${TEMPLATES}/context/CODE_CONTEXT_INDEX.md" "${ROOT}/docs/context/CODE_CONTEXT_INDEX.md"
aw_copy_if_missing "${TEMPLATES}/context/CONTEXT_PLAN_TEMPLATE.md" "${ROOT}/docs/context/CONTEXT_PLAN_TEMPLATE.md"

if [[ ! -f "${ROOT}/docs/ENGINEERING_RULES.md" ]]; then
  aw_copy_if_missing "${TEMPLATES}/rules/ENGINEERING_RULES.md" "${ROOT}/docs/ENGINEERING_RULES.md"
fi

if [[ ! -f "${ROOT}/docs/handoff/PROJECT_HANDOFF.md" ]]; then
  mkdir -p "${ROOT}/docs/handoff"
  cat > "${ROOT}/docs/handoff/PROJECT_HANDOFF.md" <<'EOF'
# PROJECT_HANDOFF

## 当前目标



## 关联 DSL / Plan / REQ



## 下一步（1～3 条）



## 风险 / 待确认

- 
EOF
  echo "  created: docs/handoff/PROJECT_HANDOFF.md"
fi

if [[ ! -f "${ROOT}/docs/handoff/AI_BUG_LOG.md" ]]; then
  cat > "${ROOT}/docs/handoff/AI_BUG_LOG.md" <<'EOF'
# AI / 会话 Bug 流水

**用途：** 记录所有 Bug、测试失败、用户口述问题、审查发现与线上反馈；跨会话追溯。

| 字段 | 说明 |
|------|------|
| **来源** | `test` · `chat` · `review` · `runtime` · `prod` · `hook-*` |
| **状态** | `open` / `investigating` / `done` / `wontfix` |

---

## 流水（新在上）
EOF
  echo "  created: docs/handoff/AI_BUG_LOG.md"
fi

if [[ ! -d "${ROOT}/agent-workflow" ]] && [[ -d "${TEMPLATES}/.." ]]; then
  echo "  note: copy agent-workflow/ package into repo for offline docs, or use skill aw-delivery"
fi

if [[ -x "${SCRIPT_DIR}/generate-file-index.sh" ]]; then
  "${SCRIPT_DIR}/generate-file-index.sh" >/dev/null 2>&1 || true
fi

echo ""
echo "Done. Next:"
echo "  1. Edit reference/manifest.yaml and add files under reference/inputs/"
echo "  2. Fill docs/PROJECT_CONFIG.md and docs/ENGINEERING_RULES.md"
echo "  3. Review Engineering Harness docs: docs/audit docs/policy docs/security docs/release docs/contracts docs/github docs/hooks docs/context docs/score docs/recovery docs/SERVICE_CATALOG.md"
echo "  4. ./scripts/aw dsl"
echo "  5. Human: review DSL → aw approve dsl ... --plan"
echo "  6. ./scripts/aw confirm docs/dsl/<已审>.md docs/plans/<可执行>.md"
