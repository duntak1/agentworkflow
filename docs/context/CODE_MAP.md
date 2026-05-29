# CODE_MAP（代码地图）

> 读者：AI Agent + 人类工程师。用途是在修改代码前快速定位模块、入口、Symbol、调用/依赖关系和受影响测试，避免无目标全仓扫描。
> 生成：`./scripts/aw code-map build`。查询：`./scripts/aw code-map query "keyword"`、`./scripts/aw code-map impact "symbol"`。

## 元数据

| 字段 | 内容 |
|------|------|
| **生成时间** | 2026-05-29 17:26:24 |
| **后端** | builtin |
| **项目根目录** | /Users/mayan/Library/Mobile Documents/com~apple~CloudDocs/Project/项目/agentworkflow |
| **文件数** | 220 |
| **Symbol 数** | 1531 |
| **路由 / API 数** | 0 |
| **测试文件数** | 0 |

## 目录概览

| 目录 | 类型 | 代码文件数 | 说明 |
|------|------|------------|------|
| . | doc | 6 | inferred from file paths |
| agent-workflow | doc | 19 | inferred from file paths |
| agent-workflow/adapters | doc | 10 | inferred from file paths |
| agent-workflow/adapters/codex-context | doc | 1 | inferred from file paths |
| agent-workflow/adapters/cursor-hooks | doc | 1 | inferred from file paths |
| agent-workflow/meta | doc | 2 | inferred from file paths |
| agent-workflow/templates/agents | doc | 5 | inferred from file paths |
| agent-workflow/templates/contracts | api | 1 | inferred from file paths |
| agent-workflow/templates/contracts | doc | 3 | inferred from file paths |
| agent-workflow/templates/dsl | doc | 6 | inferred from file paths |
| agent-workflow/templates/policy | code | 1 | inferred from file paths |
| agent-workflow/templates/policy | doc | 1 | inferred from file paths |
| agent-workflow/templates/recovery | doc | 1 | inferred from file paths |
| agent-workflow/templates/reference | doc | 1 | inferred from file paths |
| agent-workflow/templates/rules | doc | 1 | inferred from file paths |
| assets/social | code | 1 | inferred from file paths |
| docs | doc | 5 | inferred from file paths |
| docs/agents | doc | 5 | inferred from file paths |
| docs/audit | doc | 1 | inferred from file paths |
| docs/context | doc | 3 | inferred from file paths |
| docs/contracts | api | 1 | inferred from file paths |
| docs/contracts | doc | 3 | inferred from file paths |
| docs/dsl | doc | 3 | inferred from file paths |
| docs/github | doc | 3 | inferred from file paths |
| docs/handoff | doc | 8 | inferred from file paths |
| docs/hooks | doc | 1 | inferred from file paths |
| docs/memory | doc | 3 | inferred from file paths |
| docs/metrics | doc | 1 | inferred from file paths |
| docs/ops | doc | 3 | inferred from file paths |
| docs/plans | doc | 3 | inferred from file paths |
| docs/policy | code | 1 | inferred from file paths |
| docs/policy | doc | 1 | inferred from file paths |
| docs/product | doc | 2 | inferred from file paths |
| docs/product/tasks | doc | 2 | inferred from file paths |
| docs/quality | doc | 1 | inferred from file paths |
| docs/quality/test-plans | test | 3 | inferred from file paths |
| docs/recovery | doc | 1 | inferred from file paths |
| docs/release | doc | 3 | inferred from file paths |
| docs/requirements | doc | 3 | inferred from file paths |
| docs/score | doc | 1 | inferred from file paths |
| docs/security | doc | 2 | inferred from file paths |
| docs/vcs | doc | 3 | inferred from file paths |
| docs/workflow | doc | 1 | inferred from file paths |
| reference | doc | 1 | inferred from file paths |
| scripts | cli | 87 | inferred from file paths |
| scripts | test | 2 | inferred from file paths |
| skill | doc | 3 | inferred from file paths |

## 入口文件

| 类型 | 文件 | 说明 |
|------|------|------|
| doc | README.md | entry/config candidate |
| doc | CLAUDE.md | entry/config candidate |
| doc | AGENTS.md | entry/config candidate |
| cli | scripts/aw-demo.sh | entry/config candidate |
| cli | scripts/aw-doctor.sh | entry/config candidate |
| cli | scripts/aw-upgrade.sh | entry/config candidate |
| cli | scripts/aw-report.sh | entry/config candidate |
| cli | scripts/aw-compact.sh | entry/config candidate |
| cli | scripts/aw-status.sh | entry/config candidate |
| cli | scripts/aw-rules.sh | entry/config candidate |
| cli | scripts/aw-bug.sh | entry/config candidate |
| cli | scripts/aw-next.sh | entry/config candidate |
| cli | scripts/aw-dsl-suite.sh | entry/config candidate |
| cli | scripts/aw-verify.sh | entry/config candidate |
| cli | scripts/aw-atomic.sh | entry/config candidate |
| cli | scripts/aw-security.sh | entry/config candidate |
| cli | scripts/aw-dsl-select.sh | entry/config candidate |
| cli | scripts/aw-dashboard.sh | entry/config candidate |
| cli | scripts/aw-audit.sh | entry/config candidate |
| cli | scripts/aw-release.sh | entry/config candidate |
| cli | scripts/aw-changelog.sh | entry/config candidate |
| cli | scripts/aw-code-map.sh | entry/config candidate |
| cli | scripts/aw-metrics.sh | entry/config candidate |
| cli | scripts/aw-trace.sh | entry/config candidate |
| cli | scripts/aw-approve.sh | entry/config candidate |
| cli | scripts/aw-plan-apply.sh | entry/config candidate |
| cli | scripts/aw-gate.sh | entry/config candidate |
| cli | scripts/aw-policy.sh | entry/config candidate |
| cli | scripts/aw-project.sh | entry/config candidate |
| cli | scripts/aw-recover.sh | entry/config candidate |
| cli | scripts/aw-commit.sh | entry/config candidate |
| cli | scripts/aw-confirm.sh | entry/config candidate |
| cli | scripts/aw-ops.sh | entry/config candidate |
| cli | scripts/aw-score.sh | entry/config candidate |
| cli | scripts/aw-plan-select.sh | entry/config candidate |
| cli | scripts/aw-agents.sh | entry/config candidate |
| cli | scripts/aw-vcs.sh | entry/config candidate |
| cli | scripts/aw-install.sh | entry/config candidate |
| cli | scripts/aw-watch.sh | entry/config candidate |
| cli | scripts/aw-remove.sh | entry/config candidate |
| cli | scripts/aw-plan-change.sh | entry/config candidate |
| cli | scripts/aw-github-pr.sh | entry/config candidate |
| cli | scripts/aw-task.sh | entry/config candidate |
| cli | scripts/aw-req.sh | entry/config candidate |
| cli | scripts/aw-ci.sh | entry/config candidate |
| cli | scripts/aw-contract.sh | entry/config candidate |
| cli | scripts/aw-config.sh | entry/config candidate |
| cli | scripts/aw-capabilities.sh | entry/config candidate |
| cli | scripts/aw-sync.sh | entry/config candidate |
| cli | scripts/aw-memory.sh | entry/config candidate |
| cli | scripts/aw-service-catalog.sh | entry/config candidate |
| cli | scripts/aw-pm.sh | entry/config candidate |
| cli | scripts/aw-context.sh | entry/config candidate |
| cli | scripts/aw-setup.sh | entry/config candidate |
| cli | scripts/aw-dsl-apply.sh | entry/config candidate |
| cli | scripts/aw-dsl-review.sh | entry/config candidate |
| cli | scripts/aw-tp.sh | entry/config candidate |
| doc | skill/SKILL.md | entry/config candidate |
| doc | agent-workflow/INVOCATION.md | entry/config candidate |

## 模块地图

| 模块 | 入口 / 关键文件 | 核心 Symbol | 路由 / API | 相关测试 | 说明 |
|------|-----------------|-------------|------------|----------|------|
| . | SECURITY.md | doc | 待查询 | 待查询 | 6 files |
| agent-workflow/AGENTS.md | agent-workflow/AGENTS.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/AGENT_RULES.md | agent-workflow/AGENT_RULES.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/AICODING_WORKFLOW.md | agent-workflow/AICODING_WORKFLOW.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/BOOTSTRAP.md | agent-workflow/BOOTSTRAP.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/CHANGELOG.md | agent-workflow/CHANGELOG.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/CLAUDE.md | agent-workflow/CLAUDE.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/CROSS_PROJECT_SYNC.md | agent-workflow/CROSS_PROJECT_SYNC.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/INDEX.md | agent-workflow/INDEX.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/INVOCATION.en.md | agent-workflow/INVOCATION.en.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/INVOCATION.md | agent-workflow/INVOCATION.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/PRODUCT_INPUT_WORKFLOW.md | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/PROMPTS.md | agent-workflow/PROMPTS.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/README.md | agent-workflow/README.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/README_AGENT_DOCS.md | agent-workflow/README_AGENT_DOCS.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/REPOSITORY.md | agent-workflow/REPOSITORY.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/REPO_LANDING_CHECKLIST.md | agent-workflow/REPO_LANDING_CHECKLIST.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/SECURITY.md | agent-workflow/SECURITY.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/WINDOWS.md | agent-workflow/WINDOWS.md | doc | 待查询 | 待查询 | 1 files |
| agent-workflow/adapters | agent-workflow/adapters/claude-code.md | doc | 待查询 | 待查询 | 12 files |
| agent-workflow/meta | agent-workflow/meta/PRE_COMMIT_AND_HOOKS.md | doc | 待查询 | 待查询 | 2 files |
| agent-workflow/templates | agent-workflow/templates/policy/POLICY.yml | code,doc,api | 待查询 | 待查询 | 20 files |
| assets/social | assets/social/agentworkflow-skills-poster.html | code | 待查询 | 待查询 | 1 files |
| docs/ENGINEERING_RULES.md | docs/ENGINEERING_RULES.md | doc | 待查询 | 待查询 | 1 files |
| docs/FILE_INDEX.md | docs/FILE_INDEX.md | doc | 待查询 | 待查询 | 1 files |
| docs/PROJECT_CONFIG.md | docs/PROJECT_CONFIG.md | doc | 待查询 | 待查询 | 1 files |
| docs/README.md | docs/README.md | doc | 待查询 | 待查询 | 1 files |
| docs/SERVICE_CATALOG.md | docs/SERVICE_CATALOG.md | doc | 待查询 | 待查询 | 1 files |
| docs/agents | docs/agents/AGENT_ROLES.md | doc | 待查询 | 待查询 | 5 files |
| docs/audit | docs/audit/AGENT_TRACE.md | doc | 待查询 | 待查询 | 1 files |
| docs/context | docs/context/CONTEXT_CONFIG.md | doc | 待查询 | 待查询 | 3 files |
| docs/contracts | docs/contracts/MOCK_SERVER.md | doc,api | 待查询 | 待查询 | 4 files |
| docs/dsl | docs/dsl/DSL_SPEC_TEMPLATE.md | doc | 待查询 | 待查询 | 3 files |
| docs/github | docs/github/REVIEW_GATE.md | doc | 待查询 | 待查询 | 3 files |
| docs/handoff | docs/handoff/PROJECT_HANDOFF.md | doc | 待查询 | 待查询 | 8 files |
| docs/hooks | docs/hooks/HOOKS.md | doc | 待查询 | 待查询 | 1 files |
| docs/memory | docs/memory/INDEX.md | doc | 待查询 | 待查询 | 3 files |
| docs/metrics | docs/metrics/DELIVERY_METRICS.md | doc | 待查询 | 待查询 | 1 files |
| docs/ops | docs/ops/RUNBOOKS.md | doc | 待查询 | 待查询 | 3 files |
| docs/plans | docs/plans/README.md | doc | 待查询 | 待查询 | 3 files |
| docs/policy | docs/policy/POLICY.yml | code,doc | 待查询 | 待查询 | 2 files |
| docs/product | docs/product/ENGINEERING_HARNESS_PRD.md | doc | 待查询 | 待查询 | 4 files |
| docs/quality | docs/quality/README.md | doc,test | 待查询 | 待查询 | 4 files |
| docs/recovery | docs/recovery/RECOVERY_PLAYBOOK.md | doc | 待查询 | 待查询 | 1 files |
| docs/release | docs/release/FEATURE_FLAGS.md | doc | 待查询 | 待查询 | 3 files |
| docs/requirements | docs/requirements/INDEX.md | doc | 待查询 | 待查询 | 3 files |
| docs/score | docs/score/DELIVERY_SCORE.md | doc | 待查询 | 待查询 | 1 files |
| docs/security | docs/security/DEPENDENCY_REVIEW.md | doc | 待查询 | 待查询 | 2 files |
| docs/vcs | docs/vcs/REVIEW_GATE.md | doc | 待查询 | 待查询 | 3 files |
| docs/workflow | docs/workflow/README.md | doc | 待查询 | 待查询 | 1 files |
| reference/README.md | reference/README.md | doc | 待查询 | 待查询 | 1 files |
| scripts/README.md | scripts/README.md | cli | 待查询 | 待查询 | 1 files |
| scripts/_aw-bug-lib.sh | scripts/_aw-bug-lib.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/_aw-lib.sh | scripts/_aw-lib.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/_aw-task-lib.sh | scripts/_aw-task-lib.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/_aw-verify-lib.sh | scripts/_aw-verify-lib.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-agents.sh | scripts/aw-agents.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-approve.sh | scripts/aw-approve.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-atomic.sh | scripts/aw-atomic.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-audit.sh | scripts/aw-audit.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-bug.sh | scripts/aw-bug.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-capabilities.sh | scripts/aw-capabilities.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-changelog.sh | scripts/aw-changelog.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-ci.sh | scripts/aw-ci.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-code-map.sh | scripts/aw-code-map.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-commit.sh | scripts/aw-commit.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-compact.sh | scripts/aw-compact.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-config.sh | scripts/aw-config.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-confirm.sh | scripts/aw-confirm.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-context.sh | scripts/aw-context.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-contract.sh | scripts/aw-contract.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-dashboard.sh | scripts/aw-dashboard.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-demo.sh | scripts/aw-demo.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-doctor.sh | scripts/aw-doctor.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-dsl-apply.sh | scripts/aw-dsl-apply.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-dsl-review.sh | scripts/aw-dsl-review.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-dsl-select.sh | scripts/aw-dsl-select.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-dsl-suite.sh | scripts/aw-dsl-suite.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-gate.sh | scripts/aw-gate.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-github-pr.sh | scripts/aw-github-pr.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-install.sh | scripts/aw-install.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-memory.sh | scripts/aw-memory.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-metrics.sh | scripts/aw-metrics.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-next.sh | scripts/aw-next.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-ops.sh | scripts/aw-ops.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-plan-apply.sh | scripts/aw-plan-apply.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-plan-change.sh | scripts/aw-plan-change.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-plan-select.sh | scripts/aw-plan-select.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-pm.sh | scripts/aw-pm.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-policy.sh | scripts/aw-policy.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-project.sh | scripts/aw-project.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-recover.sh | scripts/aw-recover.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-release.sh | scripts/aw-release.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-remove.sh | scripts/aw-remove.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-report.sh | scripts/aw-report.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-req.sh | scripts/aw-req.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-rules.sh | scripts/aw-rules.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-score.sh | scripts/aw-score.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-security.sh | scripts/aw-security.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-service-catalog.sh | scripts/aw-service-catalog.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-setup.sh | scripts/aw-setup.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-status.sh | scripts/aw-status.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-sync.sh | scripts/aw-sync.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-task.sh | scripts/aw-task.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-tp.sh | scripts/aw-tp.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-trace.sh | scripts/aw-trace.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-upgrade.sh | scripts/aw-upgrade.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-vcs.sh | scripts/aw-vcs.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-verify.sh | scripts/aw-verify.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/aw-watch.sh | scripts/aw-watch.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/build-skill-archive.sh | scripts/build-skill-archive.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-aw-all.sh | scripts/check-aw-all.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-aw-layout.sh | scripts/check-aw-layout.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-docs-commands.sh | scripts/check-docs-commands.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-dsl-business-gate.sh | scripts/check-dsl-business-gate.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-dsl.sh | scripts/check-dsl.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-file-index-sync.sh | scripts/check-file-index-sync.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-memory.sh | scripts/check-memory.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-plan.sh | scripts/check-plan.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-plugin-metadata.sh | scripts/check-plugin-metadata.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-project-config.sh | scripts/check-project-config.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-req-index.sh | scripts/check-req-index.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-skill-package.sh | scripts/check-skill-package.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-skill-source.sh | scripts/check-skill-source.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/check-test-plan-index.sh | scripts/check-test-plan-index.sh | test | 待查询 | 待查询 | 1 files |
| scripts/commit-gate.sh | scripts/commit-gate.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/draft-dsl.sh | scripts/draft-dsl.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/draft-handoff.sh | scripts/draft-handoff.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/draft-plan.sh | scripts/draft-plan.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/e2e-smoke.sh | scripts/e2e-smoke.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/generate-engineering-index.sh | scripts/generate-engineering-index.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/generate-file-index.sh | scripts/generate-file-index.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/init-project.sh | scripts/init-project.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/install-aw-adapters.sh | scripts/install-aw-adapters.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/install-cursor-skill.sh | scripts/install-cursor-skill.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/install-git-hooks.sh | scripts/install-git-hooks.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/new-req.sh | scripts/new-req.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/new-test-plan.sh | scripts/new-test-plan.sh | test | 待查询 | 待查询 | 1 files |
| scripts/pre-commit-verify.sh | scripts/pre-commit-verify.sh | cli | 待查询 | 待查询 | 1 files |
| scripts/sync-skill.sh | scripts/sync-skill.sh | cli | 待查询 | 待查询 | 1 files |
| skill/QUICKSTART.md | skill/QUICKSTART.md | doc | 待查询 | 待查询 | 1 files |
| skill/SKILL.md | skill/SKILL.md | doc | 待查询 | 待查询 | 1 files |
| skill/reference.md | skill/reference.md | doc | 待查询 | 待查询 | 1 files |

## Symbol 索引

| Symbol | 类型 | 文件 | 行号 | 说明 |
|--------|------|------|------|------|
| Security | heading | SECURITY.md | 1 | markdown section |
| agent-workflow | heading | README.md | 1 | markdown section |
| 为什么需要 | heading | README.md | 7 | markdown section |
| 解决方案 | heading | README.md | 18 | markdown section |
| Token 省用原则 | heading | README.md | 64 | markdown section |
| 快速开始 | heading | README.md | 70 | markdown section |
| 代码托管平台：1=GitHub，2=本地 Git，3=GitLab，4=Bitbucket，5=Gitee，6=GitCode，7=Gitea，8=Forgejo，9=GitLab CE，10=Gerrit，11=云效 Codeup | heading | README.md | 96 | markdown section |
| 支持矩阵 | heading | README.md | 134 | markdown section |
| 可验证范围 | heading | README.md | 147 | markdown section |
| Cursor Skill（可选） | heading | README.md | 154 | markdown section |
| Codex Plugin Metadata | heading | README.md | 169 | markdown section |
| Handoff vs Memory | heading | README.md | 173 | markdown section |
| 文档 | heading | README.md | 180 | markdown section |
| License | heading | README.md | 190 | markdown section |
| Reference（人类参考材料区） | heading | reference/README.md | 1 | markdown section |
| 放什么 | heading | reference/README.md | 5 | markdown section |
| 不放什么 | heading | reference/README.md | 13 | markdown section |
| 操作步骤 | heading | reference/README.md | 18 | markdown section |
| Git | heading | reference/README.md | 25 | markdown section |
| CLAUDE.md（入口） | heading | CLAUDE.md | 1 | markdown section |
| AGENTS.md（入口） | heading | AGENTS.md | 1 | markdown section |
| SERVICE_CATALOG（服务 / 模块目录） | heading | docs/SERVICE_CATALOG.md | 1 | markdown section |
| 维护规则 | heading | docs/SERVICE_CATALOG.md | 5 | markdown section |
| 服务 / 模块 | heading | docs/SERVICE_CATALOG.md | 11 | markdown section |
| Demonstrate agent-workflow end to end in a temporary repository. | heading | scripts/aw-demo.sh | 2 | markdown section |
| DSL — aw demo | heading | scripts/aw-demo.sh | 50 | markdown section |
| 元数据 | heading | scripts/aw-demo.sh | 52 | markdown section |
| 验收（可检查） | heading | scripts/aw-demo.sh | 59 | markdown section |
| Plan — aw demo | heading | scripts/aw-demo.sh | 68 | markdown section |
| 元数据 | heading | scripts/aw-demo.sh | 70 | markdown section |
| 目标 | heading | scripts/aw-demo.sh | 77 | markdown section |
| Atomic tasks — aw demo | heading | scripts/aw-demo.sh | 83 | markdown section |
| Diagnose agent-workflow installation and next actions. | heading | scripts/aw-doctor.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-doctor.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-doctor.sh | 8 | markdown section |
| ok | shell function | scripts/aw-doctor.sh | 15 | shell declaration |
| warn | shell function | scripts/aw-doctor.sh | 16 | shell declaration |
| fail | shell function | scripts/aw-doctor.sh | 17 | shell declaration |
| exists | shell function | scripts/aw-doctor.sh | 19 | shell declaration |
| shellcheck source=_aw-lib.sh | heading | scripts/draft-plan.sh | 5 | markdown section |
| usage | shell function | scripts/draft-plan.sh | 13 | shell declaration |
| normalize_domain | shell function | scripts/draft-plan.sh | 21 | shell declaration |
| Refresh agent-workflow package/scripts in the current repo. | heading | scripts/aw-upgrade.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-upgrade.sh | 6 | markdown section |
| usage | shell function | scripts/aw-upgrade.sh | 12 | shell declaration |
| Generate human-readable Engineering Harness reports. | heading | scripts/aw-report.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-report.sh | 6 | markdown section |
| usage | shell function | scripts/aw-report.sh | 14 | shell declaration |
| json_field | shell function | scripts/aw-report.sh | 28 | shell declaration |
| last_matching_lines | shell function | scripts/aw-report.sh | 33 | shell declaration |
| section_or_empty | shell function | scripts/aw-report.sh | 40 | shell declaration |
| run_capture | shell function | scripts/aw-report.sh | 52 | shell declaration |
| write_report | shell function | scripts/aw-report.sh | 56 | shell declaration |
| latest_report | shell function | scripts/aw-report.sh | 66 | shell declaration |
| check_report_file | shell function | scripts/aw-report.sh | 73 | shell declaration |
| check_reports | shell function | scripts/aw-report.sh | 105 | shell declaration |
| generate_report | shell function | scripts/aw-report.sh | 141 | shell declaration |
| Engineering Report — ${kind} | heading | scripts/aw-report.sh | 163 | markdown section |
| Workflow State | heading | scripts/aw-report.sh | 169 | markdown section |
| Metrics Summary | heading | scripts/aw-report.sh | 183 | markdown section |
| Release Gate Snapshot | heading | scripts/aw-report.sh | 191 | markdown section |
| Traceability Snapshot | heading | scripts/aw-report.sh | 197 | markdown section |
| Service Discovery Snapshot | heading | scripts/aw-report.sh | 203 | markdown section |
| Engineer Checklist | heading | scripts/aw-report.sh | 209 | markdown section |
| One-shot context compaction for Codex/new-session continuity. | heading | scripts/aw-compact.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-compact.sh | 6 | markdown section |
| usage | shell function | scripts/aw-compact.sh | 23 | shell declaration |
| Print workflow state and suggested next command. | heading | scripts/aw-status.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-status.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-status.sh | 8 | markdown section |
| read_status | shell function | scripts/aw-status.sh | 28 | shell declaration |
| json_escape | shell function | scripts/aw-status.sh | 117 | shell declaration |
| Engineering rules helper: init/review/check. | heading | scripts/aw-rules.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-rules.sh | 6 | markdown section |
| usage | shell function | scripts/aw-rules.sh | 15 | shell declaration |
| ensure_rules | shell function | scripts/aw-rules.sh | 26 | shell declaration |
| scan_rule_files | shell function | scripts/aw-rules.sh | 34 | shell declaration |
| scan_rule_text | shell function | scripts/aw-rules.sh | 42 | shell declaration |
| first_match | shell function | scripts/aw-rules.sh | 51 | shell declaration |
| first_text_file | shell function | scripts/aw-rules.sh | 56 | shell declaration |
| discover_rules_rows | shell function | scripts/aw-rules.sh | 61 | shell declaration |
| replace_key_files_table | shell function | scripts/aw-rules.sh | 84 | shell declaration |
| discover_rules | shell function | scripts/aw-rules.sh | 115 | shell declaration |
| check_rules | shell function | scripts/aw-rules.sh | 131 | shell declaration |
| review_rules | shell function | scripts/aw-rules.sh | 207 | shell declaration |
| Engineering Rules Review | heading | scripts/aw-rules.sh | 210 | markdown section |
| 必读 | heading | scripts/aw-rules.sh | 212 | markdown section |
| 工程师确认项 | heading | scripts/aw-rules.sh | 218 | markdown section |
| 通过后 | heading | scripts/aw-rules.sh | 236 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/check-req-index.sh | 5 | markdown section |
| fail | shell function | scripts/check-req-index.sh | 13 | shell declaration |
| ok | shell function | scripts/check-req-index.sh | 14 | shell declaration |
| extract_meta_field | shell function | scripts/check-req-index.sh | 16 | shell declaration |
| check_linked_path | shell function | scripts/check-req-index.sh | 24 | shell declaration |
| Validate docs/memory layout and entries. | heading | scripts/check-memory.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/check-memory.sh | 6 | markdown section |
| need | shell function | scripts/check-memory.sh | 20 | shell declaration |
| Bug ledger commands. | heading | scripts/aw-bug.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-bug.sh | 6 | markdown section |
| shellcheck source=_aw-bug-lib.sh | heading | scripts/aw-bug.sh | 8 | markdown section |
| usage | shell function | scripts/aw-bug.sh | 14 | shell declaration |
| shellcheck source=_aw-lib.sh | heading | scripts/draft-dsl.sh | 5 | markdown section |
| Validate Codex plugin and marketplace metadata. | heading | scripts/check-plugin-metadata.sh | 2 | markdown section |
| need_file | shell function | scripts/check-plugin-metadata.sh | 19 | shell declaration |
| json_ok | shell function | scripts/check-plugin-metadata.sh | 29 | shell declaration |
| json_value | shell function | scripts/check-plugin-metadata.sh | 43 | shell declaration |
| shellcheck source=_aw-lib.sh | heading | scripts/check-dsl.sh | 5 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/check-dsl.sh | 7 | markdown section |
| warn | shell function | scripts/check-dsl.sh | 15 | shell declaration |
| ok | shell function | scripts/check-dsl.sh | 16 | shell declaration |
| fail | shell function | scripts/check-dsl.sh | 17 | shell declaration |
| check_linked_path | shell function | scripts/check-dsl.sh | 26 | shell declaration |
| check_reverse_req_link | shell function | scripts/check-dsl.sh | 37 | shell declaration |
| check_reverse_plan_link | shell function | scripts/check-dsl.sh | 50 | shell declaration |
| check_file | shell function | scripts/check-dsl.sh | 63 | shell declaration |
| check_suite | shell function | scripts/check-dsl.sh | 98 | shell declaration |
| Print next AT-T* task (with coding gates). | heading | scripts/aw-next.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-next.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-next.sh | 8 | markdown section |
| Create a multi-file DSL suite under docs/dsl/DSL_<slug>/. | heading | scripts/aw-dsl-suite.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-dsl-suite.sh | 6 | markdown section |
| usage | shell function | scripts/aw-dsl-suite.sh | 14 | shell declaration |
| render | shell function | scripts/aw-dsl-suite.sh | 32 | shell declaration |
| Run verification commands from PROJECT_CONFIG and/or AT-T Verify column. | heading | scripts/aw-verify.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-verify.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-verify.sh | 8 | markdown section |
| shellcheck source=_aw-verify-lib.sh | heading | scripts/aw-verify.sh | 10 | markdown section |
| audit_verify | shell function | scripts/aw-verify.sh | 19 | shell declaration |
| aw_resolve_verify_cmd | shell function | scripts/aw-verify.sh | 42 | shell declaration |
| run_shell_verify | shell function | scripts/aw-verify.sh | 51 | shell declaration |
| run_tp_verify | shell function | scripts/aw-verify.sh | 63 | shell declaration |
| run_verify_spec | shell function | scripts/aw-verify.sh | 87 | shell declaration |
| Pre-commit verification (agent-workflow repos). | heading | scripts/pre-commit-verify.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/pre-commit-verify.sh | 6 | markdown section |
| CHANGELOG gate when policy paths staged | heading | scripts/pre-commit-verify.sh | 26 | markdown section |
| Optional full layout check (fast) | heading | scripts/pre-commit-verify.sh | 39 | markdown section |
| Frontend / maven when staged (optional projects) | heading | scripts/pre-commit-verify.sh | 44 | markdown section |
| Shared helpers for docs/handoff/AI_BUG_LOG.md. | heading | scripts/_aw-bug-lib.sh | 2 | markdown section |
| aw_bug_log_path | shell function | scripts/_aw-bug-lib.sh | 4 | shell declaration |
| aw_bug_ensure_log | shell function | scripts/_aw-bug-lib.sh | 10 | shell declaration |
| AI / 会话 Bug 流水 | heading | scripts/_aw-bug-lib.sh | 16 | markdown section |
| 流水（新在上） | heading | scripts/_aw-bug-lib.sh | 27 | markdown section |
| aw_bug_append | shell function | scripts/_aw-bug-lib.sh | 32 | shell declaration |
| run | shell function | scripts/check-aw-all.sh | 8 | shell declaration |
| Validate skill directory layout (run after sync-skill). | heading | scripts/check-skill-package.sh | 2 | markdown section |
| need | shell function | scripts/check-skill-package.sh | 17 | shell declaration |
| List / select active ATOMIC_TASKS_*.md (multi-plan repos) | heading | scripts/aw-atomic.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-atomic.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-atomic.sh | 8 | markdown section |
| usage | shell function | scripts/aw-atomic.sh | 20 | shell declaration |
| resolve_atomic_path | shell function | scripts/aw-atomic.sh | 29 | shell declaration |
| Security findings and dependency review helper. | heading | scripts/aw-security.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-security.sh | 6 | markdown section |
| usage | shell function | scripts/aw-security.sh | 17 | shell declaration |
| ensure_security | shell function | scripts/aw-security.sh | 30 | shell declaration |
| insert_after_header | shell function | scripts/aw-security.sh | 36 | shell declaration |
| detect_security_tools | shell function | scripts/aw-security.sh | 49 | shell declaration |
| run_or_suggest | shell function | scripts/aw-security.sh | 60 | shell declaration |
| Create REQ-YYYYMMDD-NN-slug.md and update INDEX.md | heading | scripts/new-req.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/new-req.sh | 6 | markdown section |
| usage | shell function | scripts/new-req.sh | 14 | shell declaration |
| next_seq | shell function | scripts/new-req.sh | 29 | shell declaration |
| Update INDEX | heading | scripts/new-req.sh | 58 | markdown section |
| 需求索引（REQ） | heading | scripts/new-req.sh | 61 | markdown section |
| 需求索引（REQ） | heading | scripts/new-req.sh | 71 | markdown section |
| Generate docs/FILE_INDEX.md for human engineers to locate project code files. | heading | scripts/generate-file-index.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/generate-file-index.sh | 6 | markdown section |
| category_of | shell function | scripts/generate-file-index.sh | 12 | shell declaration |
| desc_of | shell function | scripts/generate-file-index.sh | 33 | shell declaration |
| include_file | shell function | scripts/generate-file-index.sh | 195 | shell declaration |
| list_files | shell function | scripts/generate-file-index.sh | 208 | shell declaration |
| emit_table | shell function | scripts/generate-file-index.sh | 237 | shell declaration |
| maintain_hint | shell function | scripts/generate-file-index.sh | 253 | shell declaration |
| List / select active DSL file. | heading | scripts/aw-dsl-select.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-dsl-select.sh | 6 | markdown section |
| usage | shell function | scripts/aw-dsl-select.sh | 16 | shell declaration |
| resolve_dsl_path | shell function | scripts/aw-dsl-select.sh | 26 | shell declaration |
| shellcheck source=_aw-lib.sh | heading | scripts/check-aw-layout.sh | 5 | markdown section |
| check | shell function | scripts/check-aw-layout.sh | 11 | shell declaration |
| Run pre-commit checks before commit (optional wrapper). | heading | scripts/commit-gate.sh | 2 | markdown section |
| Read-only terminal dashboard for agent-workflow. | heading | scripts/aw-dashboard.sh | 2 | markdown section |
| Agent execution audit log. | heading | scripts/aw-audit.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-audit.sh | 6 | markdown section |
| usage | shell function | scripts/aw-audit.sh | 15 | shell declaration |
| ensure_audit | shell function | scripts/aw-audit.sh | 29 | shell declaration |
| Validate PLAN_*.md and matching ATOMIC_TASKS_*.md | heading | scripts/check-plan.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/check-plan.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/check-plan.sh | 8 | markdown section |
| shellcheck source=_aw-verify-lib.sh | heading | scripts/check-plan.sh | 10 | markdown section |
| warn | shell function | scripts/check-plan.sh | 18 | shell declaration |
| fail | shell function | scripts/check-plan.sh | 19 | shell declaration |
| ok | shell function | scripts/check-plan.sh | 20 | shell declaration |
| extract_meta_path | shell function | scripts/check-plan.sh | 29 | shell declaration |
| check_plan | shell function | scripts/check-plan.sh | 37 | shell declaration |
| Release/environment record helper. | heading | scripts/aw-release.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-release.sh | 6 | markdown section |
| usage | shell function | scripts/aw-release.sh | 18 | shell declaration |
| ensure_release | shell function | scripts/aw-release.sh | 32 | shell declaration |
| insert_after_header | shell function | scripts/aw-release.sh | 39 | shell declaration |
| Changelog helper: add/check [Unreleased] entries for traceable commits. | heading | scripts/aw-changelog.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-changelog.sh | 6 | markdown section |
| usage | shell function | scripts/aw-changelog.sh | 13 | shell declaration |
| changelog_path | shell function | scripts/aw-changelog.sh | 26 | shell declaration |
| ensure_changelog | shell function | scripts/aw-changelog.sh | 36 | shell declaration |
| Changelog | heading | scripts/aw-changelog.sh | 41 | markdown section |
| [Unreleased] | heading | scripts/aw-changelog.sh | 43 | markdown section |
| Added | heading | scripts/aw-changelog.sh | 45 | markdown section |
| Changed | heading | scripts/aw-changelog.sh | 47 | markdown section |
| Fixed | heading | scripts/aw-changelog.sh | 49 | markdown section |
| Removed | heading | scripts/aw-changelog.sh | 51 | markdown section |
| normalize_type | shell function | scripts/aw-changelog.sh | 78 | shell declaration |
| add_entry | shell function | scripts/aw-changelog.sh | 88 | shell declaration |
| Code Map helper: build/query a lightweight project graph before reading code. | heading | scripts/aw-code-map.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-code-map.sh | 6 | markdown section |
| usage | shell function | scripts/aw-code-map.sh | 17 | shell declaration |
| ensure_code_map | shell function | scripts/aw-code-map.sh | 31 | shell declaration |
| rel | shell function | scripts/aw-code-map.sh | 37 | shell declaration |
| list_code_files | shell function | scripts/aw-code-map.sh | 56 | shell declaration |
| file_kind | shell function | scripts/aw-code-map.sh | 76 | shell declaration |
| module_name | shell function | scripts/aw-code-map.sh | 91 | shell declaration |
| extract_symbols | shell function | scripts/aw-code-map.sh | 100 | shell declaration |
| extract_routes | shell function | scripts/aw-code-map.sh | 121 | shell declaration |
| emit | function | scripts/aw-code-map.sh | 126 | function declaration |
| extract_imports | shell function | scripts/aw-code-map.sh | 134 | shell declaration |
| Delivery metrics helper (DORA / Flow). | heading | scripts/aw-metrics.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-metrics.sh | 6 | markdown section |
| usage | shell function | scripts/aw-metrics.sh | 16 | shell declaration |
| ensure_metrics | shell function | scripts/aw-metrics.sh | 28 | shell declaration |
| insert_row | shell function | scripts/aw-metrics.sh | 33 | shell declaration |
| trim | function | scripts/aw-metrics.sh | 95 | function declaration |
| shellcheck source=_aw-lib.sh | heading | scripts/init-project.sh | 5 | markdown section |
| REQ-YYYYMMDD-NN-short-slug | heading | scripts/init-project.sh | 56 | markdown section |
| 元数据 | heading | scripts/init-project.sh | 58 | markdown section |
| 需求索引（REQ） | heading | scripts/init-project.sh | 75 | markdown section |
| DSL / 页面说明 | heading | scripts/init-project.sh | 85 | markdown section |
| 研发计划 | heading | scripts/init-project.sh | 96 | markdown section |
| 项目配置（人类填写） | heading | scripts/init-project.sh | 107 | markdown section |
| 本地验证命令 | heading | scripts/init-project.sh | 135 | markdown section |
| FILE_INDEX（项目文件索引） | heading | scripts/init-project.sh | 153 | markdown section |
| 维护规则 | heading | scripts/init-project.sh | 157 | markdown section |
| 前端 | heading | scripts/init-project.sh | 164 | markdown section |
| 后端 | heading | scripts/init-project.sh | 170 | markdown section |
| 数据库 / 迁移 | heading | scripts/init-project.sh | 176 | markdown section |
| 测试 | heading | scripts/init-project.sh | 182 | markdown section |
| 配置 / 启动入口 | heading | scripts/init-project.sh | 188 | markdown section |
| 删除 / 重命名记录 | heading | scripts/init-project.sh | 194 | markdown section |
| PROJECT_HANDOFF | heading | scripts/init-project.sh | 243 | markdown section |
| 当前目标 | heading | scripts/init-project.sh | 245 | markdown section |
| 关联 DSL / Plan / REQ | heading | scripts/init-project.sh | 249 | markdown section |
| 下一步（1～3 条） | heading | scripts/init-project.sh | 253 | markdown section |
| 风险 / 待确认 | heading | scripts/init-project.sh | 257 | markdown section |
| AI / 会话 Bug 流水 | heading | scripts/init-project.sh | 266 | markdown section |
| 流水（新在上） | heading | scripts/init-project.sh | 277 | markdown section |
| Block staging business code paths when active DSL is not 已审. | heading | scripts/check-dsl-business-gate.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/check-dsl-business-gate.sh | 6 | markdown section |
| Traceability checks across REQ, DSL, Plan, AT-T, TP, Bug, Changelog, and Harness records. | heading | scripts/aw-trace.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-trace.sh | 6 | markdown section |
| usage | shell function | scripts/aw-trace.sh | 13 | shell declaration |
| ok | shell function | scripts/aw-trace.sh | 26 | shell declaration |
| warn | shell function | scripts/aw-trace.sh | 27 | shell declaration |
| fail | shell function | scripts/aw-trace.sh | 28 | shell declaration |
| extract_meta_field | shell function | scripts/aw-trace.sh | 30 | shell declaration |
| check_path_ref | shell function | scripts/aw-trace.sh | 37 | shell declaration |
| current_plan_files | shell function | scripts/aw-trace.sh | 47 | shell declaration |
| Set DSL → 已审 or Plan → 可执行 in metadata table. | heading | scripts/aw-approve.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-approve.sh | 6 | markdown section |
| usage | shell function | scripts/aw-approve.sh | 16 | shell declaration |
| normalize_domain | shell function | scripts/aw-approve.sh | 22 | shell declaration |
| resolve_path | shell function | scripts/aw-approve.sh | 64 | shell declaration |
| aw_set_metadata_field | shell function | scripts/aw-approve.sh | 91 | shell declaration |
| pm_guidance_enabled | shell function | scripts/aw-approve.sh | 107 | shell declaration |
| print_pm_after_dsl_guidance | shell function | scripts/aw-approve.sh | 116 | shell declaration |
| print_pm_after_plan_guidance | shell function | scripts/aw-approve.sh | 125 | shell declaration |
| Install agent-workflow Cursor skill from a git URL or local path. | heading | scripts/install-cursor-skill.sh | 2 | markdown section |
| usage | shell function | scripts/install-cursor-skill.sh | 10 | shell declaration |
| cleanup | shell function | scripts/install-cursor-skill.sh | 27 | shell declaration |
| Install tool-specific entry pointers (optional). Truth stays in agent-workflow/. | heading | scripts/install-aw-adapters.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/install-aw-adapters.sh | 6 | markdown section |
| usage | shell function | scripts/install-aw-adapters.sh | 21 | shell declaration |
| write_if_missing | shell function | scripts/install-aw-adapters.sh | 71 | shell declaration |
| Write generated Plan and ATOMIC_TASKS markdown files into docs/plans. | heading | scripts/aw-plan-apply.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-plan-apply.sh | 6 | markdown section |
| usage | shell function | scripts/aw-plan-apply.sh | 15 | shell declaration |
| Scripts（agent-workflow · 工具无关） | heading | scripts/README.md | 1 | markdown section |
| 环境变量 | heading | scripts/README.md | 68 | markdown section |
| 快速开始 | heading | scripts/README.md | 75 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/draft-handoff.sh | 5 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/draft-handoff.sh | 7 | markdown section |
| usage | shell function | scripts/draft-handoff.sh | 14 | shell declaration |
| rel_or_dash | shell function | scripts/draft-handoff.sh | 52 | shell declaration |
| status_or_dash | shell function | scripts/draft-handoff.sh | 57 | shell declaration |
| project_field_or_dash | shell function | scripts/draft-handoff.sh | 62 | shell declaration |
| generate_handoff | shell function | scripts/draft-handoff.sh | 128 | shell declaration |
| PROJECT_HANDOFF | heading | scripts/draft-handoff.sh | 130 | markdown section |
| 当前目标 | heading | scripts/draft-handoff.sh | 132 | markdown section |
| 当前状态 | heading | scripts/draft-handoff.sh | 136 | markdown section |
| 项目配置 | heading | scripts/draft-handoff.sh | 147 | markdown section |
| 验证命令 | heading | scripts/draft-handoff.sh | 158 | markdown section |
| 近期 REQ（最近 5 条） | heading | scripts/draft-handoff.sh | 164 | markdown section |
| 近期 Bug / 测试失败（最近 5 条） | heading | scripts/draft-handoff.sh | 168 | markdown section |
| 下一步（1～3 条） | heading | scripts/draft-handoff.sh | 172 | markdown section |
| 风险 / 待确认 | heading | scripts/draft-handoff.sh | 177 | markdown section |
| 新会话启动 | heading | scripts/draft-handoff.sh | 181 | markdown section |
| 维护说明 | heading | scripts/draft-handoff.sh | 190 | markdown section |
| check_handoff | shell function | scripts/draft-handoff.sh | 201 | shell declaration |
| Automatic gate runner for critical agent-workflow lifecycle points. | heading | scripts/aw-gate.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-gate.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-gate.sh | 8 | markdown section |
| usage | shell function | scripts/aw-gate.sh | 15 | shell declaration |
| ensure_gate_docs | shell function | scripts/aw-gate.sh | 30 | shell declaration |
| run_or_mark | shell function | scripts/aw-gate.sh | 37 | shell declaration |
| Minimal policy-as-code helper. | heading | scripts/aw-policy.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-policy.sh | 6 | markdown section |
| usage | shell function | scripts/aw-policy.sh | 17 | shell declaration |
| ensure_policy | shell function | scripts/aw-policy.sh | 31 | shell declaration |
| changed_files | shell function | scripts/aw-policy.sh | 37 | shell declaration |
| policy_diff_gate | shell function | scripts/aw-policy.sh | 50 | shell declaration |
| Project intake scanner: infer new/existing stage and split-repo sync readiness before planning. | heading | scripts/aw-project.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-project.sh | 6 | markdown section |
| usage | shell function | scripts/aw-project.sh | 14 | shell declaration |
| count_files | shell function | scripts/aw-project.sh | 26 | shell declaration |
| count_code_files | shell function | scripts/aw-project.sh | 41 | shell declaration |
| exists_any | shell function | scripts/aw-project.sh | 56 | shell declaration |
| list_hits | shell function | scripts/aw-project.sh | 64 | shell declaration |
| scan_project | shell function | scripts/aw-project.sh | 76 | shell declaration |
| Project Scan | heading | scripts/aw-project.sh | 108 | markdown section |
| 强制下一步 | heading | scripts/aw-project.sh | 126 | markdown section |
| Recovery playbooks for broken context, stale plans, sync drift, failed tasks, and rollback. | heading | scripts/aw-recover.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-recover.sh | 6 | markdown section |
| usage | shell function | scripts/aw-recover.sh | 16 | shell declaration |
| ensure_recovery | shell function | scripts/aw-recover.sh | 31 | shell declaration |
| Pre-commit helper: verify + suggest Conventional Commit with AT-T id (does not commit by default) | heading | scripts/aw-commit.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-commit.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-commit.sh | 8 | markdown section |
| audit_commit | shell function | scripts/aw-commit.sh | 19 | shell declaration |
| Confirm task (DSL 已审 + Plan 可执行) and regenerate ENGINEERING_INDEX.md | heading | scripts/aw-confirm.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-confirm.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-confirm.sh | 8 | markdown section |
| resolve_path | shell function | scripts/aw-confirm.sh | 37 | shell declaration |
| SLO / incident / runbook helper. | heading | scripts/aw-ops.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-ops.sh | 6 | markdown section |
| usage | shell function | scripts/aw-ops.sh | 18 | shell declaration |
| ensure_ops | shell function | scripts/aw-ops.sh | 33 | shell declaration |
| insert_after_table | shell function | scripts/aw-ops.sh | 40 | shell declaration |
| trim | function | scripts/aw-ops.sh | 140 | function declaration |
| trim | function | scripts/aw-ops.sh | 200 | function declaration |
| Delivery scorecard helper. | heading | scripts/aw-score.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-score.sh | 6 | markdown section |
| usage | shell function | scripts/aw-score.sh | 16 | shell declaration |
| ensure_score | shell function | scripts/aw-score.sh | 27 | shell declaration |
| score_item | shell function | scripts/aw-score.sh | 32 | shell declaration |
| insert_row | shell function | scripts/aw-score.sh | 41 | shell declaration |
| List / select active Plan file. | heading | scripts/aw-plan-select.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-plan-select.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-plan-select.sh | 8 | markdown section |
| usage | shell function | scripts/aw-plan-select.sh | 18 | shell declaration |
| resolve_plan_path | shell function | scripts/aw-plan-select.sh | 27 | shell declaration |
| Multi-agent collaboration protocol helper. | heading | scripts/aw-agents.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-agents.sh | 6 | markdown section |
| usage | shell function | scripts/aw-agents.sh | 20 | shell declaration |
| ensure_agents | shell function | scripts/aw-agents.sh | 38 | shell declaration |
| insert_after_header | shell function | scripts/aw-agents.sh | 47 | shell declaration |
| trim | function | scripts/aw-agents.sh | 325 | function declaration |
| norm | function | scripts/aw-agents.sh | 326 | function declaration |
| Check that core CLI commands are documented in Skill reference and Invocation. | heading | scripts/check-docs-commands.sh | 2 | markdown section |
| check_doc | shell function | scripts/check-docs-commands.sh | 9 | shell declaration |
| Sync repo → ~/.cursor/skills/agent-workflow (and legacy aw-delivery) | heading | scripts/sync-skill.sh | 2 | markdown section |
| Files copied into skill package/ (installed to target repo as agent-workflow/) | heading | scripts/sync-skill.sh | 13 | markdown section |
| sync_one | shell function | scripts/sync-skill.sh | 36 | shell declaration |
| write_alias_skill | shell function | scripts/sync-skill.sh | 67 | shell declaration |
| Optional: project skill in source repo (for contributors) | heading | scripts/sync-skill.sh | 78 | markdown section |
| End-to-end smoke: skill bundle → aw install → init → gates → confirm. | heading | scripts/e2e-smoke.sh | 2 | markdown section |
| No git init required — aw_repo_root falls back to cwd | heading | scripts/e2e-smoke.sh | 26 | markdown section |
| Minimal DSL + Plan for confirm gate | heading | scripts/e2e-smoke.sh | 257 | markdown section |
| DSL — e2e smoke | heading | scripts/e2e-smoke.sh | 259 | markdown section |
| 元数据 | heading | scripts/e2e-smoke.sh | 261 | markdown section |
| 验收（可检查） | heading | scripts/e2e-smoke.sh | 268 | markdown section |
| Plan — e2e | heading | scripts/e2e-smoke.sh | 311 | markdown section |
| 元数据 | heading | scripts/e2e-smoke.sh | 313 | markdown section |
| 目标 | heading | scripts/e2e-smoke.sh | 320 | markdown section |
| Atomic tasks — e2e | heading | scripts/e2e-smoke.sh | 326 | markdown section |
| Provider-neutral VCS branch / PR-MR-CR lifecycle helper. | heading | scripts/aw-vcs.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-vcs.sh | 6 | markdown section |
| usage | shell function | scripts/aw-vcs.sh | 18 | shell declaration |
| provider_label | shell function | scripts/aw-vcs.sh | 36 | shell declaration |
| ensure_vcs | shell function | scripts/aw-vcs.sh | 52 | shell declaration |
| insert_row | shell function | scripts/aw-vcs.sh | 68 | shell declaration |
| draft_body | shell function | scripts/aw-vcs.sh | 79 | shell declaration |
| ${title} | heading | scripts/aw-vcs.sh | 87 | markdown section |
| Trace | heading | scripts/aw-vcs.sh | 91 | markdown section |
| Gate Checklist | heading | scripts/aw-vcs.sh | 100 | markdown section |
| Changed Files | heading | scripts/aw-vcs.sh | 109 | markdown section |
| Rollback | heading | scripts/aw-vcs.sh | 115 | markdown section |
| Install agent-workflow package into target repo (or current repo). | heading | scripts/aw-install.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-install.sh | 6 | markdown section |
| copy_tree | shell function | scripts/aw-install.sh | 59 | shell declaration |
| Ensure templates exist (older package/ may lack templates/) | heading | scripts/aw-install.sh | 70 | markdown section |
| stub_if_missing | shell function | scripts/aw-install.sh | 99 | shell declaration |
| Lightweight automation watcher helpers. | heading | scripts/aw-watch.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-watch.sh | 6 | markdown section |
| usage | shell function | scripts/aw-watch.sh | 13 | shell declaration |
| run_index_once | shell function | scripts/aw-watch.sh | 24 | shell declaration |
| Preview or remove generated agent-workflow integration files. | heading | scripts/aw-remove.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-remove.sh | 6 | markdown section |
| usage | shell function | scripts/aw-remove.sh | 16 | shell declaration |
| Development-time Plan/ATOMIC changes: append tasks or split an existing task. | heading | scripts/aw-plan-change.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-plan-change.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-plan-change.sh | 8 | markdown section |
| usage | shell function | scripts/aw-plan-change.sh | 15 | shell declaration |
| atomic_path | shell function | scripts/aw-plan-change.sh | 30 | shell declaration |
| plan_path | shell function | scripts/aw-plan-change.sh | 39 | shell declaration |
| next_task_id | shell function | scripts/aw-plan-change.sh | 46 | shell declaration |
| append_task_row | shell function | scripts/aw-plan-change.sh | 55 | shell declaration |
| append_change_note | shell function | scripts/aw-plan-change.sh | 74 | shell declaration |
| audit_plan_change | shell function | scripts/aw-plan-change.sh | 87 | shell declaration |
| reset_requirement_confirmation_if_task | shell function | scripts/aw-plan-change.sh | 94 | shell declaration |
| Compatibility wrapper for provider-neutral VCS lifecycle helper. | heading | scripts/aw-github-pr.sh | 2 | markdown section |
| AT-T* task lifecycle: show / brief / confirm / start / complete / done | heading | scripts/aw-task.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-task.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-task.sh | 8 | markdown section |
| shellcheck source=_aw-verify-lib.sh | heading | scripts/aw-task.sh | 10 | markdown section |
| shellcheck source=_aw-bug-lib.sh | heading | scripts/aw-task.sh | 12 | markdown section |
| usage | shell function | scripts/aw-task.sh | 22 | shell declaration |
| append_bug_log | shell function | scripts/aw-task.sh | 41 | shell declaration |
| audit_task | shell function | scripts/aw-task.sh | 46 | shell declaration |
| sync_auto_enabled | shell function | scripts/aw-task.sh | 53 | shell declaration |
| sync_role_for_pm | shell function | scripts/aw-task.sh | 59 | shell declaration |
| sync_before_task_start | shell function | scripts/aw-task.sh | 70 | shell declaration |
| sync_after_task_complete | shell function | scripts/aw-task.sh | 89 | shell declaration |
| sync_after_task_blocked | shell function | scripts/aw-task.sh | 104 | shell declaration |
| print_commit_prompt | shell function | scripts/aw-task.sh | 120 | shell declaration |
| checkpoint_file | shell function | scripts/aw-task.sh | 136 | shell declaration |
| checkpoint_mark | shell function | scripts/aw-task.sh | 140 | shell declaration |
| checkpoint_require_resolved | shell function | scripts/aw-task.sh | 154 | shell declaration |
| print_task_paste | shell function | scripts/aw-task.sh | 165 | shell declaration |
| 当前任务 | heading | scripts/aw-task.sh | 175 | markdown section |
| 必读（@ 路径，勿读 ENGINEERING_INDEX.md） | heading | scripts/aw-task.sh | 183 | markdown section |
| 阶段 A（先输出再写码） | heading | scripts/aw-task.sh | 192 | markdown section |
| 阶段 C–D | heading | scripts/aw-task.sh | 197 | markdown section |
| 阶段 E | heading | scripts/aw-task.sh | 200 | markdown section |
| 闸门 | heading | scripts/aw-task.sh | 206 | markdown section |
| print_task_brief | shell function | scripts/aw-task.sh | 226 | shell declaration |
| 当前候选任务 | heading | scripts/aw-task.sh | 236 | markdown section |
| 需求真源 | heading | scripts/aw-task.sh | 244 | markdown section |
| 开始前必须沟通清楚 | heading | scripts/aw-task.sh | 250 | markdown section |
| Agent 规则 | heading | scripts/aw-task.sh | 258 | markdown section |
| Requirement commands: new / change | heading | scripts/aw-req.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-req.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-req.sh | 8 | markdown section |
| usage | shell function | scripts/aw-req.sh | 15 | shell declaration |
| slugify | shell function | scripts/aw-req.sh | 26 | shell declaration |
| next_req_id | shell function | scripts/aw-req.sh | 30 | shell declaration |
| append_section | shell function | scripts/aw-req.sh | 40 | shell declaration |
| clear_requirement_confirm | shell function | scripts/aw-req.sh | 50 | shell declaration |
| ensure_req_index | shell function | scripts/aw-req.sh | 59 | shell declaration |
| 需求索引（REQ） | heading | scripts/aw-req.sh | 63 | markdown section |
| append_req_index_row | shell function | scripts/aw-req.sh | 71 | shell declaration |
| write_req_file | shell function | scripts/aw-req.sh | 84 | shell declaration |
| ${req_base} | heading | scripts/aw-req.sh | 87 | markdown section |
| 元数据 | heading | scripts/aw-req.sh | 89 | markdown section |
| 标题 | heading | scripts/aw-req.sh | 102 | markdown section |
| 需求摘要 | heading | scripts/aw-req.sh | 106 | markdown section |
| 影响范围 | heading | scripts/aw-req.sh | 110 | markdown section |
| 验收更新 | heading | scripts/aw-req.sh | 114 | markdown section |
| 回写要求 | heading | scripts/aw-req.sh | 196 | markdown section |
| Gate: business code file additions/deletions/renames require docs/FILE_INDEX.md refresh. | heading | scripts/check-file-index-sync.sh | 2 | markdown section |
| is_business_file | shell function | scripts/check-file-index-sync.sh | 7 | shell declaration |
| Install CI workflow templates into the target repository. | heading | scripts/aw-ci.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-ci.sh | 6 | markdown section |
| usage | shell function | scripts/aw-ci.sh | 14 | shell declaration |
| Frontend/backend API contract helper. | heading | scripts/aw-contract.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-contract.sh | 6 | markdown section |
| usage | shell function | scripts/aw-contract.sh | 19 | shell declaration |
| ensure_contracts | shell function | scripts/aw-contract.sh | 34 | shell declaration |
| insert_row | shell function | scripts/aw-contract.sh | 42 | shell declaration |
| Shared helpers for agent-workflow scripts. | heading | scripts/_aw-lib.sh | 2 | markdown section |
| aw_repo_root | shell function | scripts/_aw-lib.sh | 4 | shell declaration |
| Cursor skill root (~/.cursor/skills/agent-workflow) when scripts run from skill bundle | heading | scripts/_aw-lib.sh | 12 | markdown section |
| aw_skill_root | shell function | scripts/_aw-lib.sh | 13 | shell declaration |
| Policy docs: target repo agent-workflow/ or skill package/ | heading | scripts/_aw-lib.sh | 27 | markdown section |
| aw_policy_dir | shell function | scripts/_aw-lib.sh | 28 | shell declaration |
| aw_templates_dir | shell function | scripts/_aw-lib.sh | 44 | shell declaration |
| aw_copy_if_missing | shell function | scripts/_aw-lib.sh | 70 | shell declaration |
| aw_refresh_engineering_index | shell function | scripts/_aw-lib.sh | 81 | shell declaration |
| aw_project_config_field | shell function | scripts/_aw-lib.sh | 105 | shell declaration |
| aw_detect_git_origin_url | shell function | scripts/_aw-lib.sh | 119 | shell declaration |
| aw_project_scan_file | shell function | scripts/_aw-lib.sh | 123 | shell declaration |
| aw_project_scan_stage | shell function | scripts/_aw-lib.sh | 127 | shell declaration |
| aw_sync_configured | shell function | scripts/_aw-lib.sh | 134 | shell declaration |
| aw_sync_center_decision | shell function | scripts/_aw-lib.sh | 145 | shell declaration |
| aw_print_sync_center_guidance | shell function | scripts/_aw-lib.sh | 157 | shell declaration |
| aw_print_project_scan_guidance | shell function | scripts/_aw-lib.sh | 165 | shell declaration |
| aw_project_kind | shell function | scripts/_aw-lib.sh | 173 | shell declaration |
| aw_project_kind_requires_remote | shell function | scripts/_aw-lib.sh | 193 | shell declaration |
| aw_remote_repo_url_configured | shell function | scripts/_aw-lib.sh | 198 | shell declaration |
| aw_project_stage | shell function | scripts/_aw-lib.sh | 205 | shell declaration |
| aw_build_target | shell function | scripts/_aw-lib.sh | 216 | shell declaration |
| aw_build_target_label | shell function | scripts/_aw-lib.sh | 228 | shell declaration |
| aw_github_url_configured | shell function | scripts/_aw-lib.sh | 237 | shell declaration |
| aw_print_project_stage_guidance | shell function | scripts/_aw-lib.sh | 243 | shell declaration |
| aw_warn_project_stage_before_planning | shell function | scripts/_aw-lib.sh | 251 | shell declaration |
| aw_print_build_target_guidance | shell function | scripts/_aw-lib.sh | 261 | shell declaration |
| aw_warn_build_target_before_planning | shell function | scripts/_aw-lib.sh | 268 | shell declaration |
| aw_require_planning_intake_ready | shell function | scripts/_aw-lib.sh | 278 | shell declaration |
| aw_print_project_kind_guidance | shell function | scripts/_aw-lib.sh | 336 | shell declaration |
| aw_print_remote_repo_url_guidance | shell function | scripts/_aw-lib.sh | 357 | shell declaration |
| aw_print_github_url_guidance | shell function | scripts/_aw-lib.sh | 368 | shell declaration |
| aw_warn_github_url_before_planning | shell function | scripts/_aw-lib.sh | 372 | shell declaration |
| aw_require_github_url_before_coding | shell function | scripts/_aw-lib.sh | 393 | shell declaration |
| aw_detect_dsl_path | shell function | scripts/_aw-lib.sh | 411 | shell declaration |
| Detect unfilled placeholders in docs/PROJECT_CONFIG.md | heading | scripts/check-project-config.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/check-project-config.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/check-project-config.sh | 8 | markdown section |
| warn | shell function | scripts/check-project-config.sh | 16 | shell declaration |
| ok | shell function | scripts/check-project-config.sh | 17 | shell declaration |
| Stack hints | heading | scripts/check-project-config.sh | 195 | markdown section |
| PROJECT_CONFIG helper. | heading | scripts/aw-config.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-config.sh | 6 | markdown section |
| usage | shell function | scripts/aw-config.sh | 14 | shell declaration |
| detect_npm_script | shell function | scripts/aw-config.sh | 50 | shell declaration |
| detect_git_remote_url | shell function | scripts/aw-config.sh | 63 | shell declaration |
| replace_field | shell function | scripts/aw-config.sh | 67 | shell declaration |
| replace_cmd | shell function | scripts/aw-config.sh | 82 | shell declaration |
| Print installed agent-workflow capabilities. | heading | scripts/aw-capabilities.sh | 2 | markdown section |
| Generate ENGINEERING_INDEX.md from repo scan + task confirmation metadata. | heading | scripts/generate-engineering-index.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/generate-engineering-index.sh | 6 | markdown section |
| [[ -n "$var" ]] breaks when var contains '/' (table rows); use length test. | heading | scripts/generate-engineering-index.sh | 12 | markdown section |
| has_text | shell function | scripts/generate-engineering-index.sh | 13 | shell declaration |
| --- resolve DSL --- | heading | scripts/generate-engineering-index.sh | 40 | markdown section |
| read_metadata_status | shell function | scripts/generate-engineering-index.sh | 62 | shell declaration |
| --- resolve Plan from DSL or glob --- | heading | scripts/generate-engineering-index.sh | 79 | markdown section |
| row_if_exists | shell function | scripts/generate-engineering-index.sh | 95 | shell declaration |
| emit_glob_rows | shell function | scripts/generate-engineering-index.sh | 104 | shell declaration |
| dsl_label | shell function | scripts/generate-engineering-index.sh | 119 | shell declaration |
| plan_label | shell function | scripts/generate-engineering-index.sh | 120 | shell declaration |
| req_label | shell function | scripts/generate-engineering-index.sh | 121 | shell declaration |
| tp_label | shell function | scripts/generate-engineering-index.sh | 122 | shell declaration |
| append_ci | shell function | scripts/generate-engineering-index.sh | 154 | shell declaration |
| append_app | shell function | scripts/generate-engineering-index.sh | 171 | shell declaration |
| Verify spec parsing (source from aw-verify.sh, check-plan.sh) | heading | scripts/_aw-verify-lib.sh | 2 | markdown section |
| Split AT-T Verify cell: shell commands and TP:path refs (semicolon-separated) | heading | scripts/_aw-verify-lib.sh | 4 | markdown section |
| aw_verify_specs_from_cell | shell function | scripts/_aw-verify-lib.sh | 5 | shell declaration |
| aw_resolve_tp_path | shell function | scripts/_aw-verify-lib.sh | 16 | shell declaration |
| aw_is_tp_spec | shell function | scripts/_aw-verify-lib.sh | 41 | shell declaration |
| shellcheck source=_aw-lib.sh | heading | scripts/check-test-plan-index.sh | 5 | markdown section |
| Cross-project synchronization for frontend/backend agents via a shared harness directory. | heading | scripts/aw-sync.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-sync.sh | 6 | markdown section |
| usage | shell function | scripts/aw-sync.sh | 14 | shell declaration |
| now_utc | shell function | scripts/aw-sync.sh | 41 | shell declaration |
| sanitize_name | shell function | scripts/aw-sync.sh | 45 | shell declaration |
| trim_cell | shell function | scripts/aw-sync.sh | 49 | shell declaration |
| rel_to_abs | shell function | scripts/aw-sync.sh | 53 | shell declaration |
| cfg_value | shell function | scripts/aw-sync.sh | 61 | shell declaration |
| sync_harness | shell function | scripts/aw-sync.sh | 74 | shell declaration |
| sync_project | shell function | scripts/aw-sync.sh | 81 | shell declaration |
| sync_agent | shell function | scripts/aw-sync.sh | 88 | shell declaration |
| sync_role | shell function | scripts/aw-sync.sh | 92 | shell declaration |
| ensure_configured | shell function | scripts/aw-sync.sh | 96 | shell declaration |
| copy_if_exists | shell function | scripts/aw-sync.sh | 114 | shell declaration |
| sync_events_file | shell function | scripts/aw-sync.sh | 126 | shell declaration |
| ensure_sync_events | shell function | scripts/aw-sync.sh | 130 | shell declaration |
| Sync Events | heading | scripts/aw-sync.sh | 136 | markdown section |
| append_sync_event | shell function | scripts/aw-sync.sh | 144 | shell declaration |
| write_manifest | shell function | scripts/aw-sync.sh | 160 | shell declaration |
| Sync Manifest | heading | scripts/aw-sync.sh | 163 | markdown section |
| 说明 | heading | scripts/aw-sync.sh | 174 | markdown section |
| 读取规则 | heading | scripts/aw-sync.sh | 178 | markdown section |
| write_task_board | shell function | scripts/aw-sync.sh | 185 | shell declaration |
| Shared Frontend / Backend Task Board | heading | scripts/aw-sync.sh | 190 | markdown section |
| 使用规则 | heading | scripts/aw-sync.sh | 197 | markdown section |
| 任务矩阵 | heading | scripts/aw-sync.sh | 204 | markdown section |
| 开始任务前检查 | heading | scripts/aw-sync.sh | 242 | markdown section |
| init_sync | shell function | scripts/aw-sync.sh | 251 | shell declaration |
| Shared DSL Baseline | heading | scripts/aw-sync.sh | 273 | markdown section |
| Shared Collaboration Plan | heading | scripts/aw-sync.sh | 282 | markdown section |
| Shared Contracts | heading | scripts/aw-sync.sh | 293 | markdown section |
| Sync Config | heading | scripts/aw-sync.sh | 300 | markdown section |
| 边界 | heading | scripts/aw-sync.sh | 310 | markdown section |
| Cross-project Sync | heading | scripts/aw-sync.sh | 318 | markdown section |
| push_sync | shell function | scripts/aw-sync.sh | 348 | shell declaration |
| pull_sync | shell function | scripts/aw-sync.sh | 390 | shell declaration |
| gate_sync | shell function | scripts/aw-sync.sh | 430 | shell declaration |
| status_sync | shell function | scripts/aw-sync.sh | 466 | shell declaration |
| baseline_sync | shell function | scripts/aw-sync.sh | 489 | shell declaration |
| board_sync | shell function | scripts/aw-sync.sh | 505 | shell declaration |
| print_harness_git_guidance | shell function | scripts/aw-sync.sh | 517 | shell declaration |
| event_sync | shell function | scripts/aw-sync.sh | 532 | shell declaration |
| change_sync | shell function | scripts/aw-sync.sh | 644 | shell declaration |
| inbox_sync | shell function | scripts/aw-sync.sh | 686 | shell declaration |
| check_sync | shell function | scripts/aw-sync.sh | 733 | shell declaration |
| File-based agent memory helpers. | heading | scripts/aw-memory.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-memory.sh | 6 | markdown section |
| usage | shell function | scripts/aw-memory.sh | 17 | shell declaration |
| memory_init | shell function | scripts/aw-memory.sh | 32 | shell declaration |
| Agent Memory | heading | scripts/aw-memory.sh | 39 | markdown section |
| Memory Index | heading | scripts/aw-memory.sh | 51 | markdown section |
| slugify | shell function | scripts/aw-memory.sh | 66 | shell declaration |
| detect_secret | shell function | scripts/aw-memory.sh | 70 | shell declaration |
| next_seq | shell function | scripts/aw-memory.sh | 77 | shell declaration |
| resolve_memory_file | shell function | scripts/aw-memory.sh | 88 | shell declaration |
| append_index_row | shell function | scripts/aw-memory.sh | 108 | shell declaration |
| ${id}-${slug} | heading | scripts/aw-memory.sh | 163 | markdown section |
| Metadata | heading | scripts/aw-memory.sh | 165 | markdown section |
| Memory | heading | scripts/aw-memory.sh | 177 | markdown section |
| Evidence | heading | scripts/aw-memory.sh | 181 | markdown section |
| Reuse Notes | heading | scripts/aw-memory.sh | 185 | markdown section |
| ${id}-${slug} | heading | scripts/aw-memory.sh | 234 | markdown section |
| Metadata | heading | scripts/aw-memory.sh | 236 | markdown section |
| Memory | heading | scripts/aw-memory.sh | 248 | markdown section |
| Chat Decisions | heading | scripts/aw-memory.sh | 252 | markdown section |
| Follow-ups | heading | scripts/aw-memory.sh | 256 | markdown section |
| Open Questions | heading | scripts/aw-memory.sh | 260 | markdown section |
| Related | heading | scripts/aw-memory.sh | 264 | markdown section |
| Evidence | heading | scripts/aw-memory.sh | 268 | markdown section |
| Reuse Notes | heading | scripts/aw-memory.sh | 272 | markdown section |
| Task / workflow helpers (source from aw-task.sh, aw-next.sh, aw-verify.sh). | heading | scripts/_aw-task-lib.sh | 2 | markdown section |
| aw_workflow_json_path | shell function | scripts/_aw-task-lib.sh | 4 | shell declaration |
| aw_task_requirement_confirm_path | shell function | scripts/_aw-task-lib.sh | 10 | shell declaration |
| aw_read_metadata_status | shell function | scripts/_aw-task-lib.sh | 16 | shell declaration |
| aw_resolve_dsl_file | shell function | scripts/_aw-task-lib.sh | 27 | shell declaration |
| aw_resolve_plan_file | shell function | scripts/_aw-task-lib.sh | 59 | shell declaration |
| aw_resolve_atomic_tasks_file | shell function | scripts/_aw-task-lib.sh | 83 | shell declaration |
| aw_write_workflow_json | shell function | scripts/_aw-task-lib.sh | 116 | shell declaration |
| aw_gate_coding_ready | shell function | scripts/_aw-task-lib.sh | 141 | shell declaration |
| aw_trim | shell function | scripts/_aw-task-lib.sh | 179 | shell declaration |
| aw_task_status_of | shell function | scripts/_aw-task-lib.sh | 181 | shell declaration |
| Print next eligible AT-T: id\tdomain\ttitle\tstatus\tdeps\tverify | heading | scripts/_aw-task-lib.sh | 188 | markdown section |
| aw_task_find_next | shell function | scripts/_aw-task-lib.sh | 189 | shell declaration |
| aw_task_get_row | shell function | scripts/_aw-task-lib.sh | 219 | shell declaration |
| trim | function | scripts/_aw-task-lib.sh | 222 | function declaration |
| aw_task_set_status | shell function | scripts/_aw-task-lib.sh | 237 | shell declaration |
| trim | function | scripts/_aw-task-lib.sh | 242 | function declaration |
| aw_task_set_verify | shell function | scripts/_aw-task-lib.sh | 258 | shell declaration |
| trim | function | scripts/_aw-task-lib.sh | 263 | function declaration |
| aw_extract_meta_field | shell function | scripts/_aw-task-lib.sh | 279 | shell declaration |
| aw_task_set_current | shell function | scripts/_aw-task-lib.sh | 287 | shell declaration |
| aw_task_current_id | shell function | scripts/_aw-task-lib.sh | 304 | shell declaration |
| aw_task_status | shell function | scripts/_aw-task-lib.sh | 311 | shell declaration |
| aw_task_require_started | shell function | scripts/_aw-task-lib.sh | 323 | shell declaration |
| aw_task_requirement_confirmed | shell function | scripts/_aw-task-lib.sh | 341 | shell declaration |
| aw_task_requirement_confirm_summary | shell function | scripts/_aw-task-lib.sh | 349 | shell declaration |
| aw_task_confirmation_summary_valid | shell function | scripts/_aw-task-lib.sh | 357 | shell declaration |
| aw_task_require_requirement_confirmed | shell function | scripts/_aw-task-lib.sh | 370 | shell declaration |
| aw_task_mark_requirement_confirmed | shell function | scripts/_aw-task-lib.sh | 391 | shell declaration |
| aw_parse_project_config_cmd | shell function | scripts/_aw-task-lib.sh | 405 | shell declaration |
| Service/module catalog helper. | heading | scripts/aw-service-catalog.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-service-catalog.sh | 6 | markdown section |
| usage | shell function | scripts/aw-service-catalog.sh | 15 | shell declaration |
| ensure_catalog | shell function | scripts/aw-service-catalog.sh | 27 | shell declaration |
| detect_type_for_path | shell function | scripts/aw-service-catalog.sh | 32 | shell declaration |
| scan_text | shell function | scripts/aw-service-catalog.sh | 43 | shell declaration |
| scan_files | shell function | scripts/aw-service-catalog.sh | 52 | shell declaration |
| summarize_scan | shell function | scripts/aw-service-catalog.sh | 60 | shell declaration |
| detect_entry_summary | shell function | scripts/aw-service-catalog.sh | 70 | shell declaration |
| detect_api_summary | shell function | scripts/aw-service-catalog.sh | 76 | shell declaration |
| detect_data_summary | shell function | scripts/aw-service-catalog.sh | 80 | shell declaration |
| detect_deps_summary | shell function | scripts/aw-service-catalog.sh | 84 | shell declaration |
| detect_run_summary | shell function | scripts/aw-service-catalog.sh | 90 | shell declaration |
| detect_observability_summary | shell function | scripts/aw-service-catalog.sh | 101 | shell declaration |
| discover_candidates | shell function | scripts/aw-service-catalog.sh | 105 | shell declaration |
| append_catalog_row | shell function | scripts/aw-service-catalog.sh | 132 | shell declaration |
| PM Agent lifecycle orchestration for sync-center based product delivery. | heading | scripts/aw-pm.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-pm.sh | 6 | markdown section |
| now_utc | shell function | scripts/aw-pm.sh | 15 | shell declaration |
| sanitize_name | shell function | scripts/aw-pm.sh | 19 | shell declaration |
| usage | shell function | scripts/aw-pm.sh | 23 | shell declaration |
| pm_start | shell function | scripts/aw-pm.sh | 47 | shell declaration |
| cfg_harness_path | shell function | scripts/aw-pm.sh | 69 | shell declaration |
| abs_path | shell function | scripts/aw-pm.sh | 80 | shell declaration |
| pm_harness | shell function | scripts/aw-pm.sh | 88 | shell declaration |
| copy_pm_template | shell function | scripts/aw-pm.sh | 100 | shell declaration |
| ensure_pm_tree | shell function | scripts/aw-pm.sh | 113 | shell declaration |
| pm_init | shell function | scripts/aw-pm.sh | 221 | shell declaration |
| PM Sync Center | heading | scripts/aw-pm.sh | 239 | markdown section |
| 使用方式 | heading | scripts/aw-pm.sh | 249 | markdown section |
| count_files | shell function | scripts/aw-pm.sh | 264 | shell declaration |
| pm_intake_check | shell function | scripts/aw-pm.sh | 270 | shell declaration |
| PM Intake Check | heading | scripts/aw-pm.sh | 292 | markdown section |
| 建议补充 | heading | scripts/aw-pm.sh | 305 | markdown section |
| 下一步 | heading | scripts/aw-pm.sh | 311 | markdown section |
| task_counts_for_role | shell function | scripts/aw-pm.sh | 325 | shell declaration |
| pm_dashboard | shell function | scripts/aw-pm.sh | 335 | shell declaration |
| PROJECT_DASHBOARD | heading | scripts/aw-pm.sh | 357 | markdown section |
| 当前建议 | heading | scripts/aw-pm.sh | 371 | markdown section |
| PROGRESS_BOARD | heading | scripts/aw-pm.sh | 379 | markdown section |
| assignments_file | shell function | scripts/aw-pm.sh | 398 | shell declaration |
| pm_assignments | shell function | scripts/aw-pm.sh | 408 | shell declaration |
| pm_lifecycle | shell function | scripts/aw-pm.sh | 435 | shell declaration |
| pm_gate | shell function | scripts/aw-pm.sh | 454 | shell declaration |
| need_file | shell function | scripts/aw-pm.sh | 466 | shell declaration |
| check_placeholder | shell function | scripts/aw-pm.sh | 486 | shell declaration |
| pm_check | shell function | scripts/aw-pm.sh | 514 | shell declaration |
| pm_design_init | shell function | scripts/aw-pm.sh | 556 | shell declaration |
| append_design_index | shell function | scripts/aw-pm.sh | 563 | shell declaration |
| pm_design_import | shell function | scripts/aw-pm.sh | 573 | shell declaration |
| ${req} 关联设计稿 | heading | scripts/aw-pm.sh | 595 | markdown section |
| pm_design_link | shell function | scripts/aw-pm.sh | 610 | shell declaration |
| ${req} 关联设计稿 | heading | scripts/aw-pm.sh | 628 | markdown section |
| pm_design_change | shell function | scripts/aw-pm.sh | 640 | shell declaration |
| pm_change | shell function | scripts/aw-pm.sh | 661 | shell declaration |
| ${id} ${title} | heading | scripts/aw-pm.sh | 679 | markdown section |
| PM 处理流程 | heading | scripts/aw-pm.sh | 689 | markdown section |
| pm_plan | shell function | scripts/aw-pm.sh | 704 | shell declaration |
| GLOBAL_PLAN | heading | scripts/aw-pm.sh | 751 | markdown section |
| 来源 DSL | heading | scripts/aw-pm.sh | 759 | markdown section |
| 三端边界 | heading | scripts/aw-pm.sh | 763 | markdown section |
| PM 审核清单 | heading | scripts/aw-pm.sh | 769 | markdown section |
| FRONTEND_PLAN | heading | scripts/aw-pm.sh | 781 | markdown section |
| 前台前端范围 | heading | scripts/aw-pm.sh | 788 | markdown section |
| 任务拆分建议 | heading | scripts/aw-pm.sh | 794 | markdown section |
| ADMIN_FRONTEND_PLAN | heading | scripts/aw-pm.sh | 802 | markdown section |
| 后台管理前端范围 | heading | scripts/aw-pm.sh | 809 | markdown section |
| 任务拆分建议 | heading | scripts/aw-pm.sh | 815 | markdown section |
| BACKEND_PLAN | heading | scripts/aw-pm.sh | 823 | markdown section |
| 后端范围 | heading | scripts/aw-pm.sh | 830 | markdown section |
| 任务拆分建议 | heading | scripts/aw-pm.sh | 836 | markdown section |
| ATOMIC_TASKS | heading | scripts/aw-pm.sh | 844 | markdown section |
| pm_dispatch | shell function | scripts/aw-pm.sh | 870 | shell declaration |
| TASK_BOARD | heading | scripts/aw-pm.sh | 893 | markdown section |
| FRONTEND_ASSIGNMENTS | heading | scripts/aw-pm.sh | 899 | markdown section |
| ADMIN_ASSIGNMENTS | heading | scripts/aw-pm.sh | 905 | markdown section |
| BACKEND_ASSIGNMENTS | heading | scripts/aw-pm.sh | 911 | markdown section |
| Context Intelligence helper: prevent wasteful full-repo reads by creating task-level context plans. | heading | scripts/aw-context.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-context.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-context.sh | 8 | markdown section |
| usage | shell function | scripts/aw-context.sh | 21 | shell declaration |
| ensure_context | shell function | scripts/aw-context.sh | 38 | shell declaration |
| ctx_plan_path | shell function | scripts/aw-context.sh | 45 | shell declaration |
| ctx_rel | shell function | scripts/aw-context.sh | 50 | shell declaration |
| ctx_field | shell function | scripts/aw-context.sh | 55 | shell declaration |
| ctx_codegraph_available | shell function | scripts/aw-context.sh | 69 | shell declaration |
| ctx_is_blocked_path | shell function | scripts/aw-context.sh | 73 | shell declaration |
| ctx_candidate_files_for_task | shell function | scripts/aw-context.sh | 86 | shell declaration |
| ctx_insert_after_section | shell function | scripts/aw-context.sh | 116 | shell declaration |
| ctx_task_query | shell function | scripts/aw-context.sh | 131 | shell declaration |
| ctx_allowed_files | shell function | scripts/aw-context.sh | 147 | shell declaration |
| ctx_update_section_table | shell function | scripts/aw-context.sh | 155 | shell declaration |
| One-shot setup for a target repo. | heading | scripts/aw-setup.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-setup.sh | 6 | markdown section |
| usage | shell function | scripts/aw-setup.sh | 14 | shell declaration |
| Build dist/agent-workflow-skill-<version>.tar.gz for release. | heading | scripts/build-skill-archive.sh | 2 | markdown section |
| Include install helper at archive root | heading | scripts/build-skill-archive.sh | 28 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/new-test-plan.sh | 5 | markdown section |
| Test Plan Index (TP) | heading | scripts/new-test-plan.sh | 43 | markdown section |
| Write a generated DSL markdown file to the configured docs/dsl path. | heading | scripts/aw-dsl-apply.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-dsl-apply.sh | 6 | markdown section |
| usage | shell function | scripts/aw-dsl-apply.sh | 14 | shell declaration |
| Print or write an engineer review package for a DSL file or DSL suite. | heading | scripts/aw-dsl-review.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-dsl-review.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-dsl-review.sh | 8 | markdown section |
| usage | shell function | scripts/aw-dsl-review.sh | 16 | shell declaration |
| resolve_target | shell function | scripts/aw-dsl-review.sh | 53 | shell declaration |
| Validate skill/ source in repo (no sync required). | heading | scripts/check-skill-source.sh | 2 | markdown section |
| need | shell function | scripts/check-skill-source.sh | 10 | shell declaration |
| Test plan helpers: list / show / link to AT-T* | heading | scripts/aw-tp.sh | 2 | markdown section |
| shellcheck source=_aw-lib.sh | heading | scripts/aw-tp.sh | 6 | markdown section |
| shellcheck source=_aw-task-lib.sh | heading | scripts/aw-tp.sh | 8 | markdown section |
| shellcheck source=_aw-verify-lib.sh | heading | scripts/aw-tp.sh | 10 | markdown section |
| usage | shell function | scripts/aw-tp.sh | 18 | shell declaration |
| resolve_tp_file | shell function | scripts/aw-tp.sh | 29 | shell declaration |
| update_verify_with_tp | shell function | scripts/aw-tp.sh | 42 | shell declaration |
| agent-workflow（运行时精简版） | heading | skill/SKILL.md | 13 | markdown section |
| Runtime Rule | heading | skill/SKILL.md | 19 | markdown section |
| Startup | heading | skill/SKILL.md | 29 | markdown section |
| Token Budget | heading | skill/SKILL.md | 45 | markdown section |
| Required Gates | heading | skill/SKILL.md | 82 | markdown section |
| Context Continuity | heading | skill/SKILL.md | 97 | markdown section |
| DSL / Plan / PM | heading | skill/SKILL.md | 117 | markdown section |
| Cross-Project Sync | heading | skill/SKILL.md | 125 | markdown section |
| Engineering Principles | heading | skill/SKILL.md | 136 | markdown section |
| File / Bug / Git Rules | heading | skill/SKILL.md | 148 | markdown section |
| Pencil | heading | skill/SKILL.md | 156 | markdown section |
| agent-workflow — 10 分钟上手（任意 AI 工具） | heading | skill/QUICKSTART.md | 1 | markdown section |
| 1. 装入工作流包 | heading | skill/QUICKSTART.md | 3 | markdown section |
| 2. 选择你的工具（已 `--adapters` 可跳过） | heading | skill/QUICKSTART.md | 33 | markdown section |
| 3. 阶段 0 → 研发 | heading | skill/QUICKSTART.md | 47 | markdown section |
| n: 1=GitHub，2=本地 Git，3=GitLab，4=Bitbucket，5=Gitee，6=GitCode，7=Gitea，8=Forgejo，9=GitLab CE，10=Gerrit，11=云效 Codeup；2 不需要 --repo-url | heading | skill/QUICKSTART.md | 56 | markdown section |
| 若 build-target=3 且前后端分仓 / 双项目：先 aw sync init <project-harness> ...，再拆 Plan | heading | skill/QUICKSTART.md | 58 | markdown section |
| 4. 换 IDE 时 | heading | skill/QUICKSTART.md | 124 | markdown section |
| 5. 诊断 / 升级 / 移除 | heading | skill/QUICKSTART.md | 128 | markdown section |
| agent-workflow — 参考 | heading | skill/reference.md | 1 | markdown section |
| 工具无关原则 | heading | skill/reference.md | 3 | markdown section |
| 启动入口 | heading | skill/reference.md | 9 | markdown section |
| 编码原则 | heading | skill/reference.md | 22 | markdown section |
| 闭环管理 | heading | skill/reference.md | 39 | markdown section |
| 适配器安装 | heading | skill/reference.md | 50 | markdown section |
| Skill 安装 | heading | skill/reference.md | 68 | markdown section |
| 本地源码 | heading | skill/reference.md | 71 | markdown section |
| 远程仓库 | heading | skill/reference.md | 74 | markdown section |
| 指定 tag/branch | heading | skill/reference.md | 77 | markdown section |
| 常用检查 | heading | skill/reference.md | 87 | markdown section |
| Handoff vs Memory | heading | skill/reference.md | 103 | markdown section |
| CLI 速查 | heading | skill/reference.md | 122 | markdown section |
| 流程与闸门 | heading | skill/reference.md | 248 | markdown section |
| 发布与安装 agent-workflow Skill | heading | PUBLISH.md | 1 | markdown section |
| 产物是什么 | heading | PUBLISH.md | 3 | markdown section |
| 本机安装（开发者） | heading | PUBLISH.md | 11 | markdown section |
| 可选：AW_SYNC_PROJECT_SKILL=0 跳过写入 .cursor/skills/ | heading | PUBLISH.md | 16 | markdown section |
| 或 | heading | PUBLISH.md | 23 | markdown section |
| 用户安装（无需 clone 全仓） | heading | PUBLISH.md | 27 | markdown section |
| 方式 A：本地路径 | heading | PUBLISH.md | 30 | markdown section |
| 方式 B：远程仓库（直接传 URL） | heading | PUBLISH.md | 33 | markdown section |
| 方式 C：远程仓库（环境变量，适合 README/CI） | heading | PUBLISH.md | 36 | markdown section |
| 可选：指定分支或 tag | heading | PUBLISH.md | 40 | markdown section |
| 接入业务项目（任意 IDE） | heading | PUBLISH.md | 44 | markdown section |
| 项目级 Skill（团队共享） | heading | PUBLISH.md | 58 | markdown section |
| 或 | heading | PUBLISH.md | 66 | markdown section |
| 发版 checklist | heading | PUBLISH.md | 70 | markdown section |
| GitHub Actions 模板 | heading | PUBLISH.md | 78 | markdown section |
| 从 Release  tarball 安装 | heading | PUBLISH.md | 97 | markdown section |
| 解压得到 ~/.cursor/skills/agent-workflow/ | heading | PUBLISH.md | 102 | markdown section |
| 别名 | heading | PUBLISH.md | 105 | markdown section |
| AGENT_RULES.md（入口） | heading | AGENT_RULES.md | 1 | markdown section |
| 质量与交付闭环 | heading | docs/quality/README.md | 1 | markdown section |
| 交付闭环（摘要） | heading | docs/quality/README.md | 9 | markdown section |
| Engineering Harness PRD | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 1 | markdown section |
| 1. 产品定位 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 3 | markdown section |
| 2. 背景与问题 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 11 | markdown section |
| 3. 产品目标 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 25 | markdown section |
| 3.1 核心目标 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 27 | markdown section |
| 3.2 非目标 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 36 | markdown section |
| 4. 目标用户 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 43 | markdown section |
| 5. 核心对象模型 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 53 | markdown section |
| 6. 核心流程 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 76 | markdown section |
| 6.1 项目初始化 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 78 | markdown section |
| 6.2 Reference 到 DSL | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 86 | markdown section |
| 6.3 DSL 到 Plan | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 94 | markdown section |
| 6.4 研发执行 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 101 | markdown section |
| 6.5 前后端同步 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 112 | markdown section |
| 6.6 GitHub PR 闭环 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 120 | markdown section |
| 7. 功能模块 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 129 | markdown section |
| 7.1 Dashboard | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 131 | markdown section |
| 7.2 DSL Review | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 144 | markdown section |
| 7.3 Plan Board | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 151 | markdown section |
| 7.4 Contract Center | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 158 | markdown section |
| 7.5 Context Intelligence | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 167 | markdown section |
| 7.6 Agent Coordination | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 181 | markdown section |
| 7.7 GitHub PR / CI / Release | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 190 | markdown section |
| 7.8 Score & Recovery | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 200 | markdown section |
| 8. 技术方案建议 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 205 | markdown section |
| 8.1 V1 技术栈 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 207 | markdown section |
| 8.2 架构 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 224 | markdown section |
| 9. 数据存储策略 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 238 | markdown section |
| 10. MVP 范围 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 247 | markdown section |
| V0.1 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 249 | markdown section |
| V0.2 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 256 | markdown section |
| V0.3 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 263 | markdown section |
| V0.4 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 270 | markdown section |
| 11. 成功指标 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 276 | markdown section |
| 12. 风险 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 289 | markdown section |
| 13. 与 agent-workflow Skill 的关系 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 297 | markdown section |
| 14. 第一版开发建议 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 309 | markdown section |
| 16. Context Intelligence 详细需求 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 323 | markdown section |
| 16.1 背景 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 325 | markdown section |
| 16.2 核心规则 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 337 | markdown section |
| 16.3 Context Plan 数据结构 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 346 | markdown section |
| 16.4 CodeGraph 适配 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 362 | markdown section |
| 16.5 UI 需求 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 380 | markdown section |
| 16.6 CLI 对应 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 389 | markdown section |
| 16.7 验收标准 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 407 | markdown section |
| 17. 自动化增强需求 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 415 | markdown section |
| 17.1 Context 自动补全 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 417 | markdown section |
| 17.2 Affected Verify | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 424 | markdown section |
| 17.3 Contract Diff 自动记录 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 430 | markdown section |
| 17.4 PR 自动填充 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 436 | markdown section |
| 17.5 Watch Index | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 442 | markdown section |
| 15. 参考资料包 | heading | docs/product/ENGINEERING_HARNESS_PRD.md | 448 | markdown section |
| PM Agent 产品全生命周期管理 PRD | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 1 | markdown section |
| 1. 背景 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 3 | markdown section |
| 2. 产品目标 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 13 | markdown section |
| 3. 非目标 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 26 | markdown section |
| 4. 角色与职责 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 34 | markdown section |
| 5. 同步中心目录 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 45 | markdown section |
| 6. PM 向导式流程 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 165 | markdown section |
| 7. 参考资料和资料体检 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 198 | markdown section |
| 8. Pencil 设计稿治理 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 239 | markdown section |
| 关联设计稿 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 267 | markdown section |
| 9. DSL 和 Plan 生成 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 284 | markdown section |
| 10. 三端任务派发与同步 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 321 | markdown section |
| 11. 前后端对接 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 383 | markdown section |
| 12. 新增需求和需求变更 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 415 | markdown section |
| 13. 产品全生命周期 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 449 | markdown section |
| 14. 看板 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 485 | markdown section |
| 15. 自动化与确认边界 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 521 | markdown section |
| 16. 建议 CLI | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 548 | markdown section |
| 17. 强约束 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 589 | markdown section |
| 18. 验收标准 | heading | docs/product/PM_AGENT_LIFECYCLE_PRD.md | 606 | markdown section |
| 研发计划 — PM Agent 产品全生命周期管理 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_PLAN.md | 1 | markdown section |
| 元数据 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_PLAN.md | 3 | markdown section |
| 目标 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_PLAN.md | 13 | markdown section |
| 不在范围内 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_PLAN.md | 17 | markdown section |
| 阶段与里程碑 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_PLAN.md | 25 | markdown section |
| 核心交付物 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_PLAN.md | 38 | markdown section |
| 验收 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_PLAN.md | 50 | markdown section |
| 风险与依赖 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_PLAN.md | 61 | markdown section |
| 原子任务词典 — PM Agent 产品全生命周期管理 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_TASKS.md | 1 | markdown section |
| 元数据 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_TASKS.md | 5 | markdown section |
| 任务表 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_TASKS.md | 12 | markdown section |
| 执行顺序建议 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_TASKS.md | 40 | markdown section |
| AI 执行协议 | heading | docs/product/tasks/PM_AGENT_LIFECYCLE_TASKS.md | 47 | markdown section |
| `docs/` 目录说明 | heading | docs/README.md | 1 | markdown section |
| DELIVERY_SCORE | heading | docs/score/DELIVERY_SCORE.md | 1 | markdown section |
| Agent Trace（AI 执行审计） | heading | docs/audit/AGENT_TRACE.md | 1 | markdown section |
| 维护规则 | heading | docs/audit/AGENT_TRACE.md | 5 | markdown section |
| 流水（新在上） | heading | docs/audit/AGENT_TRACE.md | 11 | markdown section |
| VCS_REVIEW_GATE | heading | docs/vcs/REVIEW_GATE.md | 1 | markdown section |
| BRANCH_POLICY | heading | docs/vcs/BRANCH_POLICY.md | 1 | markdown section |
| 分支规范 | heading | docs/vcs/BRANCH_POLICY.md | 3 | markdown section |
| Gate | heading | docs/vcs/BRANCH_POLICY.md | 12 | markdown section |
| VCS_REVIEW_CHECKLIST | heading | docs/vcs/PR_CHECKLIST.md | 1 | markdown section |
| 工程师 Review Checklist | heading | docs/vcs/PR_CHECKLIST.md | 17 | markdown section |
| CONTEXT_CONFIG | heading | docs/context/CONTEXT_CONFIG.md | 1 | markdown section |
| Backend 说明 | heading | docs/context/CONTEXT_CONFIG.md | 16 | markdown section |
| 硬规则 | heading | docs/context/CONTEXT_CONFIG.md | 23 | markdown section |
| CODE_MAP（代码地图） | heading | docs/context/CODE_MAP.md | 1 | markdown section |
| 元数据 | heading | docs/context/CODE_MAP.md | 6 | markdown section |
| 目录概览 | heading | docs/context/CODE_MAP.md | 18 | markdown section |
| 入口文件 | heading | docs/context/CODE_MAP.md | 61 | markdown section |
| 模块地图 | heading | docs/context/CODE_MAP.md | 124 | markdown section |
| Symbol 索引 | heading | docs/context/CODE_MAP.md | 251 | markdown section |
| 路由 / API 索引 | heading | docs/context/CODE_MAP.md | 256 | markdown section |
| 测试映射 | heading | docs/context/CODE_MAP.md | 261 | markdown section |
| 依赖线索 | heading | docs/context/CODE_MAP.md | 267 | markdown section |
| Token 读取规则 | heading | docs/context/CODE_MAP.md | 272 | markdown section |
| CODE_CONTEXT_INDEX（AI 代码上下文索引） | heading | docs/context/CODE_CONTEXT_INDEX.md | 1 | markdown section |
| 模块索引 | heading | docs/context/CODE_CONTEXT_INDEX.md | 6 | markdown section |
| 前端入口映射 | heading | docs/context/CODE_CONTEXT_INDEX.md | 12 | markdown section |
| 后端入口映射 | heading | docs/context/CODE_CONTEXT_INDEX.md | 18 | markdown section |
| 受影响测试映射 | heading | docs/context/CODE_CONTEXT_INDEX.md | 24 | markdown section |
| Memory Index | heading | docs/memory/INDEX.md | 1 | markdown section |
| Agent Memory | heading | docs/memory/README.md | 1 | markdown section |
| 目录 | heading | docs/memory/README.md | 5 | markdown section |
| 规则 | heading | docs/memory/README.md | 13 | markdown section |
| 与 Handoff 的边界 | heading | docs/memory/README.md | 21 | markdown section |
| 聊天记忆 | heading | docs/memory/README.md | 28 | markdown section |
| MEM-YYYYMMDD-NN-short-slug | heading | docs/memory/_TEMPLATE.md | 1 | markdown section |
| Metadata | heading | docs/memory/_TEMPLATE.md | 3 | markdown section |
| Memory | heading | docs/memory/_TEMPLATE.md | 15 | markdown section |
| Evidence | heading | docs/memory/_TEMPLATE.md | 19 | markdown section |
| Reuse Notes | heading | docs/memory/_TEMPLATE.md | 23 | markdown section |
| 需求索引（REQ） | heading | docs/requirements/INDEX.md | 1 | markdown section |
| 状态说明 | heading | docs/requirements/INDEX.md | 11 | markdown section |
| 需求类型 | heading | docs/requirements/INDEX.md | 20 | markdown section |
| 需求记录（Requirements） | heading | docs/requirements/README.md | 1 | markdown section |
| 编号与文件命名 | heading | docs/requirements/README.md | 7 | markdown section |
| 索引 | heading | docs/requirements/README.md | 18 | markdown section |
| 与 Issue / PR 的关系 | heading | docs/requirements/README.md | 24 | markdown section |
| 自动化（脚本） | heading | docs/requirements/README.md | 34 | markdown section |
| 谁更新 | heading | docs/requirements/README.md | 43 | markdown section |
| REQ-YYYYMMDD-NN-short-slug | heading | docs/requirements/_TEMPLATE.md | 1 | markdown section |
| 元数据 | heading | docs/requirements/_TEMPLATE.md | 3 | markdown section |
| 原始诉求（尽量保留用户措辞摘要） | heading | docs/requirements/_TEMPLATE.md | 20 | markdown section |
| 范围 | heading | docs/requirements/_TEMPLATE.md | 26 | markdown section |
| 包含 | heading | docs/requirements/_TEMPLATE.md | 28 | markdown section |
| 不包含 | heading | docs/requirements/_TEMPLATE.md | 32 | markdown section |
| 验收标准（可检查） | heading | docs/requirements/_TEMPLATE.md | 38 | markdown section |
| 实现与痕迹 | heading | docs/requirements/_TEMPLATE.md | 44 | markdown section |
| 备注 | heading | docs/requirements/_TEMPLATE.md | 54 | markdown section |
| 变更记录 | heading | docs/requirements/_TEMPLATE.md | 60 | markdown section |
| 研发计划 | heading | docs/plans/README.md | 1 | markdown section |
| 研发计划 — <功能/里程碑> | heading | docs/plans/_TEMPLATE_PLAN.md | 1 | markdown section |
| 元数据 | heading | docs/plans/_TEMPLATE_PLAN.md | 3 | markdown section |
| 目标（一句话） | heading | docs/plans/_TEMPLATE_PLAN.md | 14 | markdown section |
| 不在范围内 | heading | docs/plans/_TEMPLATE_PLAN.md | 20 | markdown section |
| 阶段与里程碑 | heading | docs/plans/_TEMPLATE_PLAN.md | 26 | markdown section |
| 验收（与 DSL 对齐） | heading | docs/plans/_TEMPLATE_PLAN.md | 35 | markdown section |
| 风险与依赖 | heading | docs/plans/_TEMPLATE_PLAN.md | 41 | markdown section |
| 原子任务词典 — <项目> | heading | docs/plans/_TEMPLATE_ATOMIC_TASKS.md | 1 | markdown section |
| 元数据 | heading | docs/plans/_TEMPLATE_ATOMIC_TASKS.md | 5 | markdown section |
| 任务表 | heading | docs/plans/_TEMPLATE_ATOMIC_TASKS.md | 14 | markdown section |
| AI 执行协议（摘要） | heading | docs/plans/_TEMPLATE_ATOMIC_TASKS.md | 26 | markdown section |
| Dependency Review（依赖准入） | heading | docs/security/DEPENDENCY_REVIEW.md | 1 | markdown section |
| 维护规则 | heading | docs/security/DEPENDENCY_REVIEW.md | 5 | markdown section |
| 依赖记录（新在上） | heading | docs/security/DEPENDENCY_REVIEW.md | 11 | markdown section |
| Security Findings（安全发现） | heading | docs/security/SECURITY_FINDINGS.md | 1 | markdown section |
| 流水（新在上） | heading | docs/security/SECURITY_FINDINGS.md | 5 | markdown section |
| MOCK_SERVER | heading | docs/contracts/MOCK_SERVER.md | 1 | markdown section |
| Mock 策略 | heading | docs/contracts/MOCK_SERVER.md | 3 | markdown section |
| 规则 | heading | docs/contracts/MOCK_SERVER.md | 13 | markdown section |
| CONTRACT_TESTS | heading | docs/contracts/CONTRACT_TESTS.md | 1 | markdown section |
| API_CHANGELOG | heading | docs/contracts/API_CHANGELOG.md | 1 | markdown section |
| Agent Roles（多 Agent 协作角色） | heading | docs/agents/AGENT_ROLES.md | 1 | markdown section |
| 角色矩阵 | heading | docs/agents/AGENT_ROLES.md | 5 | markdown section |
| 协作规则 | heading | docs/agents/AGENT_ROLES.md | 15 | markdown section |
| Agent Reviews（Agent 评审记录） | heading | docs/agents/AGENT_REVIEWS.md | 1 | markdown section |
| 评审流水（新在上） | heading | docs/agents/AGENT_REVIEWS.md | 5 | markdown section |
| AGENT_LOCKS | heading | docs/agents/AGENT_LOCKS.md | 1 | markdown section |
| AGENT_HEARTBEATS | heading | docs/agents/AGENT_HEARTBEATS.md | 1 | markdown section |
| Agent Handoffs（Agent 交接记录） | heading | docs/agents/AGENT_HANDOFFS.md | 1 | markdown section |
| 交接流水（新在上） | heading | docs/agents/AGENT_HANDOFFS.md | 5 | markdown section |
| Changelog | heading | agent-workflow/CHANGELOG.md | 1 | markdown section |
| [1.5.0] - 2026-05-29 | heading | agent-workflow/CHANGELOG.md | 3 | markdown section |
| Added | heading | agent-workflow/CHANGELOG.md | 5 | markdown section |
| Changed | heading | agent-workflow/CHANGELOG.md | 9 | markdown section |
| [1.1.0] - 2026-05-19 | heading | agent-workflow/CHANGELOG.md | 13 | markdown section |
| Added | heading | agent-workflow/CHANGELOG.md | 15 | markdown section |
| [Unreleased] | heading | agent-workflow/CHANGELOG.md | 20 | markdown section |
| Added | heading | agent-workflow/CHANGELOG.md | 22 | markdown section |
| Changed | heading | agent-workflow/CHANGELOG.md | 62 | markdown section |
| Delivery Metrics（DORA / Flow） | heading | docs/metrics/DELIVERY_METRICS.md | 1 | markdown section |
| 指标说明 | heading | docs/metrics/DELIVERY_METRICS.md | 5 | markdown section |
| 流水（新在上） | heading | docs/metrics/DELIVERY_METRICS.md | 14 | markdown section |
| RECOVERY_PLAYBOOK | heading | docs/recovery/RECOVERY_PLAYBOOK.md | 1 | markdown section |
| 恢复场景 | heading | docs/recovery/RECOVERY_PLAYBOOK.md | 3 | markdown section |
| 原则 | heading | docs/recovery/RECOVERY_PLAYBOOK.md | 14 | markdown section |
| Feature Flags（渐进发布 / 开关） | heading | docs/release/FEATURE_FLAGS.md | 1 | markdown section |
| Release Record（发布记录） | heading | docs/release/RELEASE_RECORD.md | 1 | markdown section |
| 发布流水（新在上） | heading | docs/release/RELEASE_RECORD.md | 5 | markdown section |
| Environments（环境说明） | heading | docs/release/ENVIRONMENTS.md | 1 | markdown section |
| 书面用例索引（TP） | heading | docs/quality/test-plans/INDEX.md | 1 | markdown section |
| 状态说明（建议） | heading | docs/quality/test-plans/INDEX.md | 11 | markdown section |
| 功能测试用例（书面） | heading | docs/quality/test-plans/README.md | 1 | markdown section |
| TP-YYYYMMDD-NN-short-slug | heading | docs/quality/test-plans/_TEMPLATE.md | 1 | markdown section |
| 元数据 | heading | docs/quality/test-plans/_TEMPLATE.md | 3 | markdown section |
| 前置条件 | heading | docs/quality/test-plans/_TEMPLATE.md | 15 | markdown section |
| 主路径 | heading | docs/quality/test-plans/_TEMPLATE.md | 21 | markdown section |
| 分支与边界 | heading | docs/quality/test-plans/_TEMPLATE.md | 27 | markdown section |
| 权限 / 角色 | heading | docs/quality/test-plans/_TEMPLATE.md | 33 | markdown section |
| 错误与恢复 | heading | docs/quality/test-plans/_TEMPLATE.md | 39 | markdown section |
| 回归要点 | heading | docs/quality/test-plans/_TEMPLATE.md | 45 | markdown section |
| 执行记录 | heading | docs/quality/test-plans/_TEMPLATE.md | 51 | markdown section |
| 安全策略（仓库根摘要） | heading | agent-workflow/SECURITY.md | 1 | markdown section |
| 报告漏洞 | heading | agent-workflow/SECURITY.md | 5 | markdown section |
| 范围与期望 | heading | agent-workflow/SECURITY.md | 11 | markdown section |
| 密钥与敏感数据 | heading | agent-workflow/SECURITY.md | 16 | markdown section |
| Invocation Guide (Tool-Agnostic) | heading | agent-workflow/INVOCATION.en.md | 1 | markdown section |
| Flow | heading | agent-workflow/INVOCATION.en.md | 5 | markdown section |
| Closed-Loop Management | heading | agent-workflow/INVOCATION.en.md | 22 | markdown section |
| CLI | heading | agent-workflow/INVOCATION.en.md | 35 | markdown section |
| or: ./scripts/aw config init --project-kind 2 | heading | agent-workflow/INVOCATION.en.md | 42 | markdown section |
| Gates | heading | agent-workflow/INVOCATION.en.md | 63 | markdown section |
| New Session Resume | heading | agent-workflow/INVOCATION.en.md | 75 | markdown section |
| Context Continuity | heading | agent-workflow/INVOCATION.en.md | 95 | markdown section |
| or directly: | heading | agent-workflow/INVOCATION.en.md | 123 | markdown section |
| Useful Commands | heading | agent-workflow/INVOCATION.en.md | 132 | markdown section |
| AI 辅助编码工作流（Karpathy Guidelines 落地版） | heading | agent-workflow/AICODING_WORKFLOW.md | 1 | markdown section |
| 与产品 DSL（`docs/dsl/`）的分工 | heading | agent-workflow/AICODING_WORKFLOW.md | 13 | markdown section |
| 端到端时间线（人类 + AI，推荐顺序） | heading | agent-workflow/AICODING_WORKFLOW.md | 21 | markdown section |
| 总览：一条主线 | heading | agent-workflow/AICODING_WORKFLOW.md | 42 | markdown section |
| 阶段 A — 想清楚再写（Think Before Coding） | heading | agent-workflow/AICODING_WORKFLOW.md | 50 | markdown section |
| 阶段 B — 目标驱动（Goal-Driven Execution） | heading | agent-workflow/AICODING_WORKFLOW.md | 70 | markdown section |
| 阶段 C — 先简单后复杂（Simplicity First） | heading | agent-workflow/AICODING_WORKFLOW.md | 104 | markdown section |
| 阶段 D — 手术式改动（Surgical Changes） | heading | agent-workflow/AICODING_WORKFLOW.md | 120 | markdown section |
| 阶段 E — 验证闭环（Loop Until Verified） | heading | agent-workflow/AICODING_WORKFLOW.md | 134 | markdown section |
| Token / 上下文预算（真实写代码时） | heading | agent-workflow/AICODING_WORKFLOW.md | 160 | markdown section |
| 文档怎么引用（分层，避免每条消息堆全文） | heading | agent-workflow/AICODING_WORKFLOW.md | 164 | markdown section |
| 对话里少烧 token 的习惯 | heading | agent-workflow/AICODING_WORKFLOW.md | 174 | markdown section |
| 与「全面测试」怎么兼得 | heading | agent-workflow/AICODING_WORKFLOW.md | 183 | markdown section |
| 会话交接与需求存档（跨上下文） | heading | agent-workflow/AICODING_WORKFLOW.md | 189 | markdown section |
| 单人迭代模板（日常） | heading | agent-workflow/AICODING_WORKFLOW.md | 210 | markdown section |
| 相关文档 | heading | agent-workflow/AICODING_WORKFLOW.md | 227 | markdown section |
| 变更记录 | heading | agent-workflow/AICODING_WORKFLOW.md | 246 | markdown section |
| CLAUDE.md（详版 · 项目栈与禁令） | heading | agent-workflow/CLAUDE.md | 1 | markdown section |
| 技术栈（模板 — init 后覆盖） | heading | agent-workflow/CLAUDE.md | 8 | markdown section |
| 构建与测试命令（必须填真实命令） | heading | agent-workflow/CLAUDE.md | 19 | markdown section |
| 禁令（默认） | heading | agent-workflow/CLAUDE.md | 31 | markdown section |
| SOP 摘要 | heading | agent-workflow/CLAUDE.md | 41 | markdown section |
| 对话触发语 | heading | agent-workflow/CLAUDE.md | 52 | markdown section |
| 跨项目前后端同步教程 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 1 | markdown section |
| DSL / Plan 前置流程 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 17 | markdown section |
| 核心概念 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 43 | markdown section |
| 共享 DSL / 协作 Plan | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 87 | markdown section |
| 重要边界 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 133 | markdown section |
| 第一次配置 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 150 | markdown section |
| 1. 前端项目配置 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 152 | markdown section |
| 2. 后端项目配置 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 170 | markdown section |
| 每天开始任务前 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 181 | markdown section |
| 完成任务后发布快照 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 223 | markdown section |
| 接口变更怎么处理 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 259 | markdown section |
| 阻塞怎么处理 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 305 | markdown section |
| 两个 Codex 会话怎么说 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 330 | markdown section |
| 推荐执行节奏 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 352 | markdown section |
| 通用跨端事件 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 386 | markdown section |
| 常见问题 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 432 | markdown section |
| 是否需要一个真正的 Git 仓库做 project-harness？ | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 434 | markdown section |
| pull 会不会把后端 DSL 覆盖到前端？ | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 440 | markdown section |
| push 会不会推代码？ | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 446 | markdown section |
| API contract 放哪里？ | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 450 | markdown section |
| 单仓库前后端还需要 aw sync 吗？ | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 461 | markdown section |
| 最小可跑示例 | heading | agent-workflow/CROSS_PROJECT_SYNC.md | 471 | markdown section |
| Runbooks（运维手册） | heading | docs/ops/RUNBOOKS.md | 1 | markdown section |
| SLO（服务等级目标） | heading | docs/ops/SLO.md | 1 | markdown section |
| Incidents（事故 / 严重故障） | heading | docs/ops/INCIDENTS.md | 1 | markdown section |
| 事故流水（新在上） | heading | docs/ops/INCIDENTS.md | 5 | markdown section |
| FILE_INDEX（项目代码文件索引） | heading | docs/FILE_INDEX.md | 1 | markdown section |
| 维护规则 | heading | docs/FILE_INDEX.md | 5 | markdown section |
| 前端业务代码 | heading | docs/FILE_INDEX.md | 13 | markdown section |
| 后端业务代码 | heading | docs/FILE_INDEX.md | 19 | markdown section |
| 共享 / 通用代码 | heading | docs/FILE_INDEX.md | 25 | markdown section |
| 测试代码 | heading | docs/FILE_INDEX.md | 31 | markdown section |
| 运行配置 / 构建配置 | heading | docs/FILE_INDEX.md | 37 | markdown section |
| CLI / 脚本代码 | heading | docs/FILE_INDEX.md | 43 | markdown section |
| Skill / 插件包 | heading | docs/FILE_INDEX.md | 130 | markdown section |
| 工作流包文档 | heading | docs/FILE_INDEX.md | 139 | markdown section |
| 模板文件 | heading | docs/FILE_INDEX.md | 167 | markdown section |
| IDE / Agent 适配 | heading | docs/FILE_INDEX.md | 227 | markdown section |
| 项目工作流文档 | heading | docs/FILE_INDEX.md | 244 | markdown section |
| CI / Git Hooks | heading | docs/FILE_INDEX.md | 292 | markdown section |
| 仓库入口 / 配置 | heading | docs/FILE_INDEX.md | 298 | markdown section |
| 参考材料入口 | heading | docs/FILE_INDEX.md | 314 | markdown section |
| 其他项目文件 | heading | docs/FILE_INDEX.md | 321 | markdown section |
| agent-workflow policy-as-code（最小门禁） | heading | docs/policy/POLICY.yml | 1 | markdown section |
| Policy Decisions（策略例外与审批记录） | heading | docs/policy/POLICY_DECISIONS.md | 1 | markdown section |
| 记录规则 | heading | docs/policy/POLICY_DECISIONS.md | 5 | markdown section |
| 流水（新在上） | heading | docs/policy/POLICY_DECISIONS.md | 11 | markdown section |
| DSL — <产品/域名称> | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 1 | markdown section |
| 元数据 | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 3 | markdown section |
| 背景与定位 | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 16 | markdown section |
| 用户与场景 | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 22 | markdown section |
| 概念模型 | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 28 | markdown section |
| 不在范围内 | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 34 | markdown section |
| 成功标准 | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 40 | markdown section |
| 路由与信息架构（若有前端） | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 46 | markdown section |
| 主屏业务组件（摘要） | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 53 | markdown section |
| OV-ID 叠加层总表 | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 60 | markdown section |
| 验收（可检查） | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 68 | markdown section |
| notes / 待确认 | heading | docs/dsl/DSL_SPEC_TEMPLATE.md | 75 | markdown section |
| 页面规格 — <路由 path> | heading | docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 1 | markdown section |
| 元数据 | heading | docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 5 | markdown section |
| 布局与区块 | heading | docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 15 | markdown section |
| 主交互与跳转 | heading | docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 21 | markdown section |
| 权限 / 条件展示 | heading | docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 27 | markdown section |
| 响应式（文字描述，不写 CSS） | heading | docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 33 | markdown section |
| OV-ID（本页触发） | heading | docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 40 | markdown section |
| §BP 数据接入（若适用） | heading | docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 47 | markdown section |
| 验收锚点 | heading | docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 56 | markdown section |
| notes / 待确认 | heading | docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 62 | markdown section |
| DSL / 页面说明 | heading | docs/dsl/README.md | 1 | markdown section |
| 模板（本目录） | heading | docs/dsl/README.md | 5 | markdown section |
| 命令 | heading | docs/dsl/README.md | 14 | markdown section |
| 项目配置（人类填写） | heading | docs/PROJECT_CONFIG.md | 1 | markdown section |
| 本地验证命令 | heading | docs/PROJECT_CONFIG.md | 29 | markdown section |
| agent-workflow（通用 AI 交付工作流包） | heading | agent-workflow/README.md | 1 | markdown section |
| 五分钟上手 | heading | agent-workflow/README.md | 9 | markdown section |
| 在目标仓库根目录 | heading | agent-workflow/README.md | 12 | markdown section |
| 文档地图 | heading | agent-workflow/README.md | 27 | markdown section |
| 复用到其他仓库 | heading | agent-workflow/README.md | 45 | markdown section |
| 可选：Cursor Skill | heading | agent-workflow/README.md | 49 | markdown section |
| 仓库说明 / 团队真源（通用模板） | heading | agent-workflow/REPOSITORY.md | 1 | markdown section |
| 团队真源（首次立项务必填写） | heading | agent-workflow/REPOSITORY.md | 8 | markdown section |
| 文档导航 | heading | agent-workflow/REPOSITORY.md | 29 | markdown section |
| 脚本 | heading | agent-workflow/REPOSITORY.md | 46 | markdown section |
| 对话触发语 | heading | agent-workflow/REPOSITORY.md | 52 | markdown section |
| 调用说明（工具无关 · 真源） | heading | agent-workflow/INVOCATION.md | 1 | markdown section |
| 一句话流程 | heading | agent-workflow/INVOCATION.md | 13 | markdown section |
| 闭环管理目标 | heading | agent-workflow/INVOCATION.md | 19 | markdown section |
| Token 预算与分层读取 | heading | agent-workflow/INVOCATION.md | 34 | markdown section |
| 统一 CLI（推荐） | heading | agent-workflow/INVOCATION.md | 52 | markdown section |
| 2=本地 Git，无需远程仓库地址；3=GitLab，4=Bitbucket，5=Gitee，6=GitCode，7=Gitea，8=Forgejo，9=GitLab CE，10=Gerrit，11=云效 Codeup | heading | agent-workflow/INVOCATION.md | 69 | markdown section |
| 对话触发语（各工具通用） | heading | agent-workflow/INVOCATION.md | 86 | markdown section |
| Handoff 与 Memory 边界 | heading | agent-workflow/INVOCATION.md | 206 | markdown section |
| Agent 必读（按阶段） | heading | agent-workflow/INVOCATION.md | 248 | markdown section |
| 硬闸门（所有工具） | heading | agent-workflow/INVOCATION.md | 263 | markdown section |
| 新会话粘贴块（复制到任意 Chat） | heading | agent-workflow/INVOCATION.md | 275 | markdown section |
| IDE 适配（一览） | heading | agent-workflow/INVOCATION.md | 289 | markdown section |
| 与 Cursor Skill 的关系 | heading | agent-workflow/INVOCATION.md | 304 | markdown section |
| Windows Support | heading | agent-workflow/WINDOWS.md | 1 | markdown section |
| 协作与工作流 | heading | docs/workflow/README.md | 1 | markdown section |
| 关键命令 | heading | docs/workflow/README.md | 7 | markdown section |
| 项目交接快照 | heading | docs/handoff/PROJECT_HANDOFF.md | 1 | markdown section |
| 当前目标 | heading | docs/handoff/PROJECT_HANDOFF.md | 5 | markdown section |
| 硬约束（真源） | heading | docs/handoff/PROJECT_HANDOFF.md | 9 | markdown section |
| 关联 REQ | heading | docs/handoff/PROJECT_HANDOFF.md | 15 | markdown section |
| Cursor：上下文将满时自动交接（Hooks） | heading | docs/handoff/CURSOR_CONTEXT_HOOK.md | 1 | markdown section |
| 默认阈值（安装 hooks 后） | heading | docs/handoff/CURSOR_CONTEXT_HOOK.md | 17 | markdown section |
| 限制说明 | heading | docs/handoff/CURSOR_CONTEXT_HOOK.md | 26 | markdown section |
| 变更记录 | heading | docs/handoff/CURSOR_CONTEXT_HOOK.md | 36 | markdown section |
| 新会话首条消息 · 粘贴模板（通用） | heading | docs/handoff/NEW_CHAT_PASTE_TEMPLATE.md | 1 | markdown section |
| 维护核对 | heading | docs/handoff/NEW_CHAT_PASTE_TEMPLATE.md | 9 | markdown section |
| 新会话首条消息（整段复制） | heading | docs/handoff/NEW_CHAT_PASTE_TEMPLATE.md | 20 | markdown section |
| Engineering Harness 增强任务清单 | heading | docs/handoff/ENGINEERING_HARNESS_TASKS.md | 1 | markdown section |
| P0：先补强 AI 执行可控性 | heading | docs/handoff/ENGINEERING_HARNESS_TASKS.md | 5 | markdown section |
| P1：补齐交付控制面 | heading | docs/handoff/ENGINEERING_HARNESS_TASKS.md | 13 | markdown section |
| P2：形成可度量平台基础 | heading | docs/handoff/ENGINEERING_HARNESS_TASKS.md | 21 | markdown section |
| P3：形成治理闭环 | heading | docs/handoff/ENGINEERING_HARNESS_TASKS.md | 29 | markdown section |
| 执行顺序 | heading | docs/handoff/ENGINEERING_HARNESS_TASKS.md | 39 | markdown section |
| 会话交接（Handoff） | heading | docs/handoff/README.md | 1 | markdown section |
| AI / 会话 Bug 流水 | heading | docs/handoff/AI_BUG_LOG.md | 1 | markdown section |
| 流水（新在上） | heading | docs/handoff/AI_BUG_LOG.md | 16 | markdown section |
| agent-workflow / Skill 交接路线图 | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 1 | markdown section |
| 1. 项目目标（一句话） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 9 | markdown section |
| 2. 仓库结构（真源） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 17 | markdown section |
| 3. 端到端流程（当前可跑通） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 40 | markdown section |
| 4. CLI 命令清单（已实现） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 70 | markdown section |
| 4.1 安装与初始化 | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 72 | markdown section |
| 4.2 阶段 0（产品输入） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 87 | markdown section |
| 4.3 研发执行环（P0） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 106 | markdown section |
| 4.4 校验聚合 | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 117 | markdown section |
| 4.5 Skill 发布 | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 124 | markdown section |
| 5. 已删除 / 已瘦身（勿恢复 unless 明确要求） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 137 | markdown section |
| 6. 已知缺口与 Bug 修复史（避免重复踩坑） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 146 | markdown section |
| 7. 未做 / 待做（按优先级） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 159 | markdown section |
| P3 — 高价值（已推进） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 161 | markdown section |
| P4 — 体验与质量 | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 171 | markdown section |
| P5 — 自动化与生态 | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 182 | markdown section |
| P6 — 产品化与发布收口 | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 191 | markdown section |
| P7 — 生态增强 | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 200 | markdown section |
| 明确不做（除非用户改需求） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 213 | markdown section |
| 8. 给下一个 AI 的「第一条任务」建议 | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 221 | markdown section |
| 9. 测试清单（每次改 scripts 必跑） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 238 | markdown section |
| 若在业务仓验证： | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 245 | markdown section |
| 10. 关键文件索引（改哪里） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 254 | markdown section |
| 11. Skill 合格标准（自检表） | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 270 | markdown section |
| 12. 版本里程碑建议 | heading | docs/handoff/AGENTWORKFLOW_ROADMAP.md | 281 | markdown section |
| 上下文压缩指南（类比 Claude Code compact） | heading | docs/handoff/HANDOFF_GUIDE.md | 1 | markdown section |
| 何时更新 `PROJECT_HANDOFF.md` | heading | docs/handoff/HANDOFF_GUIDE.md | 7 | markdown section |
| 与 `docs/memory/` 的边界 | heading | docs/handoff/HANDOFF_GUIDE.md | 18 | markdown section |
| 压缩检查清单（按需删减，优先短的） | heading | docs/handoff/HANDOFF_GUIDE.md | 35 | markdown section |
| 可复制骨架（粘贴进 `PROJECT_HANDOFF.md` 再改） | heading | docs/handoff/HANDOFF_GUIDE.md | 64 | markdown section |
| 当前目标（1～3 句） | heading | docs/handoff/HANDOFF_GUIDE.md | 67 | markdown section |
| 硬约束 | heading | docs/handoff/HANDOFF_GUIDE.md | 70 | markdown section |
| 已拍板决策 | heading | docs/handoff/HANDOFF_GUIDE.md | 74 | markdown section |
| 仓库地图（本轮 delta） | heading | docs/handoff/HANDOFF_GUIDE.md | 77 | markdown section |
| 未完成（Next） | heading | docs/handoff/HANDOFF_GUIDE.md | 80 | markdown section |
| 阻塞 / 待确认 | heading | docs/handoff/HANDOFF_GUIDE.md | 83 | markdown section |
| 关联需求 | heading | docs/handoff/HANDOFF_GUIDE.md | 86 | markdown section |
| 刻意不写 | heading | docs/handoff/HANDOFF_GUIDE.md | 89 | markdown section |
| 给下一轮 AI 省 Token | heading | docs/handoff/HANDOFF_GUIDE.md | 93 | markdown section |
| 长度建议 | heading | docs/handoff/HANDOFF_GUIDE.md | 103 | markdown section |
| 与新对话的固定开场（可复制） | heading | docs/handoff/HANDOFF_GUIDE.md | 109 | markdown section |
| 通用最短版（任意模块） | heading | docs/handoff/HANDOFF_GUIDE.md | 111 | markdown section |
| 本仓库 Vue 查房前端（推荐详稿） | heading | docs/handoff/HANDOFF_GUIDE.md | 121 | markdown section |
| 半自动草稿 | heading | docs/handoff/HANDOFF_GUIDE.md | 128 | markdown section |
| Codex：一键工程化压缩 | heading | docs/handoff/HANDOFF_GUIDE.md | 149 | markdown section |
| Cursor：将近占满时自动提醒 | heading | docs/handoff/HANDOFF_GUIDE.md | 167 | markdown section |
| 变更记录 | heading | docs/handoff/HANDOFF_GUIDE.md | 173 | markdown section |
| 产品输入工作流（阶段 0） | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 1 | markdown section |
| 目录约定（init 后） | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 9 | markdown section |
| 状态闸门 | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 23 | markdown section |
| 步骤 | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 36 | markdown section |
| 0.1 初始化（每个仓库一次） | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 38 | markdown section |
| 0.2 人类放置 Reference | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 47 | markdown section |
| 0.3 生成 DSL 草案 | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 52 | markdown section |
| 0.4 工程师审 DSL | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 60 | markdown section |
| 0.5 生成 Plan | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 69 | markdown section |
| 0.6 任务确认 → 工程师索引 | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 77 | markdown section |
| 0.7 进入研发 | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 90 | markdown section |
| 路径选择（A / B / C） | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 96 | markdown section |
| 与 DSL / 视觉的分工 | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 108 | markdown section |
| 相关文档 | heading | agent-workflow/PRODUCT_INPUT_WORKFLOW.md | 116 | markdown section |
| 版本、变更日志、Git 与缺陷测试闭环（约束） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 1 | markdown section |
| 0. 交付闭环定义 | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 11 | markdown section |
| 1. 日志存档（变更可追溯） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 26 | markdown section |
| [Unreleased] | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 39 | markdown section |
| Added | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 41 | markdown section |
| Changed | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 42 | markdown section |
| Fixed | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 43 | markdown section |
| Removed | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 44 | markdown section |
| [1.2.0] - 2026-05-09 | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 46 | markdown section |
| 2. CHANGELOG 何时必须更新（触发规则） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 52 | markdown section |
| 2.1 分支与发布默认策略（可与团队约定微调） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 67 | markdown section |
| 3. 版本号（必须一致、可指向） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 80 | markdown section |
| 4. Git 提交（强制环节） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 92 | markdown section |
| 5. 库表变更与发布顺序（与 `CLAUDE.md` 对齐） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 101 | markdown section |
| 6. Hotfix 与回滚（收窄流程） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 111 | markdown section |
| 7. 人工评审与 UAT | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 127 | markdown section |
| 8. CI 与门禁（诚实约定） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 134 | markdown section |
| 9. Monorepo / 多包 | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 141 | markdown section |
| 10. 记录 Bug（Issue 模板） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 148 | markdown section |
| 11. 真实环境与正式用例（功能交付默认强制） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 165 | markdown section |
| 11.1 什么叫「简易沙盒」（不足以单独作为交付证据） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 169 | markdown section |
| 11.2 每个完成的功能必须同时具备 | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 177 | markdown section |
| 11.3 Bug 修复 | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 191 | markdown section |
| 12. Bug → 测试 → 修复 → 复测 | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 197 | markdown section |
| 13. 「先写失败测试」与真实验收的例外 | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 209 | markdown section |
| 14. 复测清单（合并 / 发布前） | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 223 | markdown section |
| 15. 与 AI 协作时的用法 | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 236 | markdown section |
| 变更记录 | heading | agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md | 247 | markdown section |
| README_AGENT_DOCS.md（仓库根入口） | heading | agent-workflow/README_AGENT_DOCS.md | 1 | markdown section |
| AGENT_RULES（精简 · 可复制到 .cursor/rules） | heading | agent-workflow/AGENT_RULES.md | 1 | markdown section |
| 流程闸门 | heading | agent-workflow/AGENT_RULES.md | 5 | markdown section |
| DSL vs 实现 | heading | agent-workflow/AGENT_RULES.md | 20 | markdown section |
| 路径 | heading | agent-workflow/AGENT_RULES.md | 25 | markdown section |
| Bug / 测试 | heading | agent-workflow/AGENT_RULES.md | 33 | markdown section |
| 闭环口径 | heading | agent-workflow/AGENT_RULES.md | 40 | markdown section |
| Engineering Harness 扩展 | heading | agent-workflow/AGENT_RULES.md | 47 | markdown section |
| Token | heading | agent-workflow/AGENT_RULES.md | 61 | markdown section |
| 触发语 | heading | agent-workflow/AGENT_RULES.md | 66 | markdown section |
| 仓库落地自检清单 | heading | agent-workflow/REPO_LANDING_CHECKLIST.md | 1 | markdown section |
| 一次性配置 | heading | agent-workflow/REPO_LANDING_CHECKLIST.md | 7 | markdown section |
| 合并与发布门禁 | heading | agent-workflow/REPO_LANDING_CHECKLIST.md | 21 | markdown section |
| 产品输入（阶段 0） | heading | agent-workflow/REPO_LANDING_CHECKLIST.md | 29 | markdown section |
| 质量习惯（抽样） | heading | agent-workflow/REPO_LANDING_CHECKLIST.md | 36 | markdown section |
| 变更记录 | heading | agent-workflow/REPO_LANDING_CHECKLIST.md | 46 | markdown section |
| `agent-workflow/` 文件索引 | heading | agent-workflow/INDEX.md | 1 | markdown section |
| 提交前自动校验与记录（Git Hooks） | heading | agent-workflow/meta/PRE_COMMIT_AND_HOOKS.md | 1 | markdown section |
| 一次性安装（每名开发者、每个克隆） | heading | agent-workflow/meta/PRE_COMMIT_AND_HOOKS.md | 7 | markdown section |
| pre-commit 做什么 | heading | agent-workflow/meta/PRE_COMMIT_AND_HOOKS.md | 19 | markdown section |
| 与 `commit-gate` / `git-safe-commit` 的关系 | heading | agent-workflow/meta/PRE_COMMIT_AND_HOOKS.md | 42 | markdown section |
| post-commit 做什么 | heading | agent-workflow/meta/PRE_COMMIT_AND_HOOKS.md | 51 | markdown section |
| 诚实边界 | heading | agent-workflow/meta/PRE_COMMIT_AND_HOOKS.md | 57 | markdown section |
| 变更记录 | heading | agent-workflow/meta/PRE_COMMIT_AND_HOOKS.md | 68 | markdown section |
| Agent 约定文档 — 如何使用（工具无关） | heading | agent-workflow/meta/README_AGENT_DOCS.md | 1 | markdown section |
| 各工具常见挂载方式（按需选用） | heading | agent-workflow/meta/README_AGENT_DOCS.md | 19 | markdown section |
| 同步原则 | heading | agent-workflow/meta/README_AGENT_DOCS.md | 31 | markdown section |
| HOOKS（自动 Gate / 自动化触发） | heading | docs/hooks/HOOKS.md | 1 | markdown section |
| Hook 策略 | heading | docs/hooks/HOOKS.md | 5 | markdown section |
| 自动刷新 | heading | docs/hooks/HOOKS.md | 15 | markdown section |
| 例外记录 | heading | docs/hooks/HOOKS.md | 21 | markdown section |
| REVIEW_GATE | heading | docs/github/REVIEW_GATE.md | 1 | markdown section |
| BRANCH_POLICY | heading | docs/github/BRANCH_POLICY.md | 1 | markdown section |
| 分支规范 | heading | docs/github/BRANCH_POLICY.md | 3 | markdown section |
| Gate | heading | docs/github/BRANCH_POLICY.md | 12 | markdown section |
| PR_CHECKLIST | heading | docs/github/PR_CHECKLIST.md | 1 | markdown section |
| 工程师 Review Checklist | heading | docs/github/PR_CHECKLIST.md | 17 | markdown section |
| 工程规范（人类维护 · Agent 必读） | heading | docs/ENGINEERING_RULES.md | 1 | markdown section |
| 优先级 | heading | docs/ENGINEERING_RULES.md | 5 | markdown section |
| 项目概述 | heading | docs/ENGINEERING_RULES.md | 11 | markdown section |
| 技术栈 | heading | docs/ENGINEERING_RULES.md | 15 | markdown section |
| 团队固定前端栈 | heading | docs/ENGINEERING_RULES.md | 17 | markdown section |
| 团队固定后端栈 | heading | docs/ENGINEERING_RULES.md | 25 | markdown section |
| 前端 | heading | docs/ENGINEERING_RULES.md | 53 | markdown section |
| 后端 | heading | docs/ENGINEERING_RULES.md | 63 | markdown section |
| 构建与部署 | heading | docs/ENGINEERING_RULES.md | 73 | markdown section |
| 代码规范 | heading | docs/ENGINEERING_RULES.md | 79 | markdown section |
| 通用 | heading | docs/ENGINEERING_RULES.md | 81 | markdown section |
| 前端 | heading | docs/ENGINEERING_RULES.md | 96 | markdown section |
| 后端 | heading | docs/ENGINEERING_RULES.md | 112 | markdown section |
| 前端模块规范（企业后台） | heading | docs/ENGINEERING_RULES.md | 128 | markdown section |
| 标准目录 | heading | docs/ENGINEERING_RULES.md | 130 | markdown section |
| 团队前端标准目录 | heading | docs/ENGINEERING_RULES.md | 147 | markdown section |
| 标准后台页面能力 | heading | docs/ENGINEERING_RULES.md | 181 | markdown section |
| 前端命名建议 | heading | docs/ENGINEERING_RULES.md | 190 | markdown section |
| 前端拆分边界 | heading | docs/ENGINEERING_RULES.md | 197 | markdown section |
| 后端模块规范（Spring / Cloud / Boot） | heading | docs/ENGINEERING_RULES.md | 206 | markdown section |
| 推荐输出顺序 | heading | docs/ENGINEERING_RULES.md | 208 | markdown section |
| 团队后端标准结构 | heading | docs/ENGINEERING_RULES.md | 221 | markdown section |
| Spring 技术栈参考 | heading | docs/ENGINEERING_RULES.md | 241 | markdown section |
| 数据库字段建议 | heading | docs/ENGINEERING_RULES.md | 250 | markdown section |
| 安全底线 | heading | docs/ENGINEERING_RULES.md | 257 | markdown section |
| 依赖准入 | heading | docs/ENGINEERING_RULES.md | 270 | markdown section |
| 数据库约定 | heading | docs/ENGINEERING_RULES.md | 278 | markdown section |
| 常见任务 SOP | heading | docs/ENGINEERING_RULES.md | 285 | markdown section |
| 新增前端页面 | heading | docs/ENGINEERING_RULES.md | 287 | markdown section |
| 新增后端接口 | heading | docs/ENGINEERING_RULES.md | 295 | markdown section |
| 数据库变更 | heading | docs/ENGINEERING_RULES.md | 304 | markdown section |
| 后台 CRUD 模块 | heading | docs/ENGINEERING_RULES.md | 311 | markdown section |
| 登录认证 | heading | docs/ENGINEERING_RULES.md | 319 | markdown section |
| 文件上传下载 | heading | docs/ENGINEERING_RULES.md | 327 | markdown section |
| Git 提交 | heading | docs/ENGINEERING_RULES.md | 335 | markdown section |
| 提交前流程 | heading | docs/ENGINEERING_RULES.md | 337 | markdown section |
| 阶段性提交提醒 | heading | docs/ENGINEERING_RULES.md | 347 | markdown section |
| 提交信息格式 | heading | docs/ENGINEERING_RULES.md | 353 | markdown section |
| 禁止项 | heading | docs/ENGINEERING_RULES.md | 363 | markdown section |
| 关键文件 | heading | docs/ENGINEERING_RULES.md | 369 | markdown section |
| 待确认 | heading | docs/ENGINEERING_RULES.md | 383 | markdown section |
| AGENTS.md（Codex / 多 Agent 路由） | heading | agent-workflow/AGENTS.md | 1 | markdown section |
| 快速路由 | heading | agent-workflow/AGENTS.md | 9 | markdown section |
| 研发硬闸门 | heading | agent-workflow/AGENTS.md | 21 | markdown section |
| 工具适配（可选） | heading | agent-workflow/AGENTS.md | 35 | markdown section |
| 复用到其他仓库（工具无关） | heading | agent-workflow/BOOTSTRAP.md | 1 | markdown section |
| 方式 A：拷贝文档包 + 脚本（推荐 · 任意 AI 工具） | heading | agent-workflow/BOOTSTRAP.md | 3 | markdown section |
| 方式 B：仅对话 + 粘贴（无 IDE 规则） | heading | agent-workflow/BOOTSTRAP.md | 16 | markdown section |
| 不要依赖单一 IDE | heading | agent-workflow/BOOTSTRAP.md | 22 | markdown section |
| init 后目录 | heading | agent-workflow/BOOTSTRAP.md | 27 | markdown section |
| 不要拷贝 | heading | agent-workflow/BOOTSTRAP.md | 38 | markdown section |
| 提示词大全（agent-workflow 包内） | heading | agent-workflow/PROMPTS.md | 1 | markdown section |
| 基础模板 | heading | agent-workflow/PROMPTS.md | 5 | markdown section |
| 启动分流：先判断全新项目还是已有项目 | heading | agent-workflow/PROMPTS.md | 12 | markdown section |
| 全新项目接入 | heading | agent-workflow/PROMPTS.md | 36 | markdown section |
| 非全新项目接入：先盘点现状 | heading | agent-workflow/PROMPTS.md | 52 | markdown section |
| 非全新项目：一期基线回填 | heading | agent-workflow/PROMPTS.md | 77 | markdown section |
| 生成 DSL | heading | agent-workflow/PROMPTS.md | 103 | markdown section |
| 非全新项目：增量 DSL | heading | agent-workflow/PROMPTS.md | 114 | markdown section |
| 生成 Plan | heading | agent-workflow/PROMPTS.md | 135 | markdown section |
| 前后端双项目：DSL/Plan 前置引导 | heading | agent-workflow/PROMPTS.md | 147 | markdown section |
| 前后端双项目：同步中心建设 | heading | agent-workflow/PROMPTS.md | 172 | markdown section |
| 前后端双项目：DSL 已审后拆 Plan | heading | agent-workflow/PROMPTS.md | 196 | markdown section |
| 非全新项目：增量 Plan | heading | agent-workflow/PROMPTS.md | 226 | markdown section |
| 仅前端项目 | heading | agent-workflow/PROMPTS.md | 243 | markdown section |
| 仅后端项目 | heading | agent-workflow/PROMPTS.md | 259 | markdown section |
| 同电脑前后端两个项目 | heading | agent-workflow/PROMPTS.md | 275 | markdown section |
| 不同电脑前后端两个项目 | heading | agent-workflow/PROMPTS.md | 309 | markdown section |
| 变更、Bug、收尾 | heading | agent-workflow/PROMPTS.md | 333 | markdown section |
| Claude Code | heading | agent-workflow/adapters/claude-code.md | 1 | markdown section |
| 挂载 | heading | agent-workflow/adapters/claude-code.md | 3 | markdown section |
| 触发 | heading | agent-workflow/adapters/claude-code.md | 8 | markdown section |
| 脚本 | heading | agent-workflow/adapters/claude-code.md | 12 | markdown section |
| Cline（VS Code 扩展） | heading | agent-workflow/adapters/cline.md | 1 | markdown section |
| 挂载 | heading | agent-workflow/adapters/cline.md | 3 | markdown section |
| 触发 | heading | agent-workflow/adapters/cline.md | 7 | markdown section |
| 说明 | heading | agent-workflow/adapters/cline.md | 11 | markdown section |
| Windsurf（Cascade） | heading | agent-workflow/adapters/windsurf.md | 1 | markdown section |
| 挂载 | heading | agent-workflow/adapters/windsurf.md | 3 | markdown section |
| 触发 | heading | agent-workflow/adapters/windsurf.md | 7 | markdown section |
| 脚本 | heading | agent-workflow/adapters/windsurf.md | 11 | markdown section |
| Continue（VS Code / JetBrains 等） | heading | agent-workflow/adapters/continue.md | 1 | markdown section |
| 挂载 | heading | agent-workflow/adapters/continue.md | 3 | markdown section |
| 触发 | heading | agent-workflow/adapters/continue.md | 8 | markdown section |
| 限制 | heading | agent-workflow/adapters/continue.md | 12 | markdown section |
| Cursor Hooks（可选安装） | heading | agent-workflow/adapters/cursor-hooks/README.md | 1 | markdown section |
| 安装步骤（概要） | heading | agent-workflow/adapters/cursor-hooks/README.md | 5 | markdown section |
| 与本包的关系 | heading | agent-workflow/adapters/cursor-hooks/README.md | 12 | markdown section |
| OpenAI Codex | heading | agent-workflow/adapters/codex.md | 1 | markdown section |
| 挂载 | heading | agent-workflow/adapters/codex.md | 3 | markdown section |
| 触发 | heading | agent-workflow/adapters/codex.md | 9 | markdown section |
| 参考 | heading | agent-workflow/adapters/codex.md | 13 | markdown section |
| 工具适配层（可选） | heading | agent-workflow/adapters/README.md | 1 | markdown section |
| 一键安装（业务仓库根） | heading | agent-workflow/adapters/README.md | 7 | markdown section |
| 或按需：--claude --codex --copilot --cursor --windsurf --cline --continue | heading | agent-workflow/adapters/README.md | 11 | markdown section |
| 支持矩阵 | heading | agent-workflow/adapters/README.md | 16 | markdown section |
| 原则 | heading | agent-workflow/adapters/README.md | 31 | markdown section |
| Cursor Skill（可选） | heading | agent-workflow/adapters/README.md | 37 | markdown section |
| Cursor（可选 · 非唯一入口） | heading | agent-workflow/adapters/cursor.md | 1 | markdown section |
| 项目规则（推荐） | heading | agent-workflow/adapters/cursor.md | 5 | markdown section |
| → .cursor/rules/agent-workflow.mdc | heading | agent-workflow/adapters/cursor.md | 9 | markdown section |
| 个人 Skill（可选） | heading | agent-workflow/adapters/cursor.md | 12 | markdown section |
| 触发 | heading | agent-workflow/adapters/cursor.md | 20 | markdown section |
| VS Code（通用 · 含 Copilot 扩展） | heading | agent-workflow/adapters/vscode.md | 1 | markdown section |
| 通用对话（无专用规则文件） | heading | agent-workflow/adapters/generic-chat.md | 1 | markdown section |
| 步骤 | heading | agent-workflow/adapters/generic-chat.md | 5 | markdown section |
| 限制 | heading | agent-workflow/adapters/generic-chat.md | 13 | markdown section |
| GitHub Copilot | heading | agent-workflow/adapters/copilot.md | 1 | markdown section |
| 挂载 | heading | agent-workflow/adapters/copilot.md | 3 | markdown section |
| 项目 Agent 指令 | heading | agent-workflow/adapters/copilot.md | 8 | markdown section |
| 触发 | heading | agent-workflow/adapters/copilot.md | 20 | markdown section |
| Codex Context Continuity | heading | agent-workflow/adapters/codex-context/README.md | 1 | markdown section |
| 新 Codex 会话启动 | heading | agent-workflow/adapters/codex-context/README.md | 5 | markdown section |
| 旧会话结束前 | heading | agent-workflow/adapters/codex-context/README.md | 25 | markdown section |
| 与 Codex 原生能力的边界 | heading | agent-workflow/adapters/codex-context/README.md | 48 | markdown section |
| agent-workflow policy-as-code（最小门禁） | heading | agent-workflow/templates/policy/POLICY.yml | 1 | markdown section |
| Policy Decisions（策略例外与审批记录） | heading | agent-workflow/templates/policy/POLICY_DECISIONS.md | 1 | markdown section |
| 记录规则 | heading | agent-workflow/templates/policy/POLICY_DECISIONS.md | 5 | markdown section |
| 流水（新在上） | heading | agent-workflow/templates/policy/POLICY_DECISIONS.md | 11 | markdown section |
| Agent Reviews（Agent 评审记录） | heading | agent-workflow/templates/agents/AGENT_REVIEWS.md | 1 | markdown section |
| 评审流水（新在上） | heading | agent-workflow/templates/agents/AGENT_REVIEWS.md | 5 | markdown section |
| AGENT_LOCKS | heading | agent-workflow/templates/agents/AGENT_LOCKS.md | 1 | markdown section |
| AGENT_HEARTBEATS | heading | agent-workflow/templates/agents/AGENT_HEARTBEATS.md | 1 | markdown section |
| Agent Handoffs（Agent 交接记录） | heading | agent-workflow/templates/agents/AGENT_HANDOFFS.md | 1 | markdown section |
| 交接流水（新在上） | heading | agent-workflow/templates/agents/AGENT_HANDOFFS.md | 5 | markdown section |
| Agent Roles（多 Agent 协作角色） | heading | agent-workflow/templates/agents/AGENT_ROLES.md | 1 | markdown section |
| 角色矩阵 | heading | agent-workflow/templates/agents/AGENT_ROLES.md | 5 | markdown section |
| 协作规则 | heading | agent-workflow/templates/agents/AGENT_ROLES.md | 15 | markdown section |
| Reference（人类参考材料区） | heading | agent-workflow/templates/reference/README.md | 1 | markdown section |
| 放什么 | heading | agent-workflow/templates/reference/README.md | 5 | markdown section |
| 不放什么 | heading | agent-workflow/templates/reference/README.md | 13 | markdown section |
| 操作步骤 | heading | agent-workflow/templates/reference/README.md | 18 | markdown section |
| Git | heading | agent-workflow/templates/reference/README.md | 25 | markdown section |
| MOCK_SERVER | heading | agent-workflow/templates/contracts/MOCK_SERVER.md | 1 | markdown section |
| Mock 策略 | heading | agent-workflow/templates/contracts/MOCK_SERVER.md | 3 | markdown section |
| 规则 | heading | agent-workflow/templates/contracts/MOCK_SERVER.md | 13 | markdown section |
| CONTRACT_TESTS | heading | agent-workflow/templates/contracts/CONTRACT_TESTS.md | 1 | markdown section |
| API_CHANGELOG | heading | agent-workflow/templates/contracts/API_CHANGELOG.md | 1 | markdown section |
| 工程规范（人类维护 · Agent 必读） | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 1 | markdown section |
| 优先级 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 5 | markdown section |
| 项目概述 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 11 | markdown section |
| 技术栈 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 15 | markdown section |
| 团队固定前端栈 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 17 | markdown section |
| 团队固定后端栈 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 25 | markdown section |
| 前端 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 53 | markdown section |
| 后端 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 63 | markdown section |
| 构建与部署 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 73 | markdown section |
| 代码规范 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 79 | markdown section |
| 通用 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 81 | markdown section |
| 前端 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 100 | markdown section |
| 后端 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 116 | markdown section |
| 前端模块规范（企业后台） | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 132 | markdown section |
| 标准目录 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 134 | markdown section |
| 团队前端标准目录 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 151 | markdown section |
| 标准后台页面能力 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 185 | markdown section |
| 前端命名建议 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 194 | markdown section |
| 前端拆分边界 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 201 | markdown section |
| 后端模块规范（Spring / Cloud / Boot） | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 210 | markdown section |
| 推荐输出顺序 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 212 | markdown section |
| 团队后端标准结构 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 225 | markdown section |
| Spring 技术栈参考 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 245 | markdown section |
| 数据库字段建议 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 254 | markdown section |
| 安全底线 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 261 | markdown section |
| 依赖准入 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 274 | markdown section |
| 数据库约定 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 282 | markdown section |
| 常见任务 SOP | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 289 | markdown section |
| 新增前端页面 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 291 | markdown section |
| 新增后端接口 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 299 | markdown section |
| 数据库变更 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 308 | markdown section |
| 后台 CRUD 模块 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 315 | markdown section |
| 登录认证 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 323 | markdown section |
| 文件上传下载 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 331 | markdown section |
| Git 提交 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 339 | markdown section |
| 提交前流程 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 341 | markdown section |
| 阶段性提交提醒 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 351 | markdown section |
| 提交信息格式 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 357 | markdown section |
| 禁止项 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 367 | markdown section |
| 关键文件 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 373 | markdown section |
| 待确认 | heading | agent-workflow/templates/rules/ENGINEERING_RULES.md | 387 | markdown section |
| RECOVERY_PLAYBOOK | heading | agent-workflow/templates/recovery/RECOVERY_PLAYBOOK.md | 1 | markdown section |
| 恢复场景 | heading | agent-workflow/templates/recovery/RECOVERY_PLAYBOOK.md | 3 | markdown section |
| 原则 | heading | agent-workflow/templates/recovery/RECOVERY_PLAYBOOK.md | 14 | markdown section |
| 90 Acceptance — <name> | heading | agent-workflow/templates/dsl/DSL_SUITE_ACCEPTANCE.md | 1 | markdown section |
| 验收（可检查） | heading | agent-workflow/templates/dsl/DSL_SUITE_ACCEPTANCE.md | 3 | markdown section |
| 测试锚点 | heading | agent-workflow/templates/dsl/DSL_SUITE_ACCEPTANCE.md | 8 | markdown section |
| 待确认 | heading | agent-workflow/templates/dsl/DSL_SUITE_ACCEPTANCE.md | 13 | markdown section |
| DSL Suite — <name> | heading | agent-workflow/templates/dsl/DSL_SUITE_INDEX.md | 1 | markdown section |
| 元数据 | heading | agent-workflow/templates/dsl/DSL_SUITE_INDEX.md | 3 | markdown section |
| 文件结构 | heading | agent-workflow/templates/dsl/DSL_SUITE_INDEX.md | 15 | markdown section |
| 验收（可检查） | heading | agent-workflow/templates/dsl/DSL_SUITE_INDEX.md | 26 | markdown section |
| notes / 待确认 | heading | agent-workflow/templates/dsl/DSL_SUITE_INDEX.md | 32 | markdown section |
| DSL — <产品/域名称> | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 1 | markdown section |
| 元数据 | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 3 | markdown section |
| 背景与定位 | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 16 | markdown section |
| 用户与场景 | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 22 | markdown section |
| 概念模型 | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 28 | markdown section |
| 不在范围内 | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 34 | markdown section |
| 成功标准 | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 40 | markdown section |
| 路由与信息架构（若有前端） | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 46 | markdown section |
| 主屏业务组件（摘要） | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 53 | markdown section |
| OV-ID 叠加层总表 | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 60 | markdown section |
| 验收（可检查） | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 68 | markdown section |
| notes / 待确认 | heading | agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md | 75 | markdown section |
| 页面规格 — <路由 path> | heading | agent-workflow/templates/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 1 | markdown section |
| 元数据 | heading | agent-workflow/templates/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 5 | markdown section |
| 布局与区块 | heading | agent-workflow/templates/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 15 | markdown section |
| 主交互与跳转 | heading | agent-workflow/templates/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 21 | markdown section |
| 权限 / 条件展示 | heading | agent-workflow/templates/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 27 | markdown section |
| 响应式（文字描述，不写 CSS） | heading | agent-workflow/templates/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 33 | markdown section |
| OV-ID（本页触发） | heading | agent-workflow/templates/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 40 | markdown section |
| §BP 数据接入（若适用） | heading | agent-workflow/templates/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 47 | markdown section |
| 验收锚点 | heading | agent-workflow/templates/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 56 | markdown section |
| notes / 待确认 | heading | agent-workflow/templates/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md | 62 | markdown section |
| 40 Boundaries — <name> | heading | agent-workflow/templates/dsl/DSL_SUITE_BOUNDARIES.md | 1 | markdown section |
| 模块边界 | heading | agent-workflow/templates/dsl/DSL_SUITE_BOUNDARIES.md | 3 | markdown section |
| 接口 / 数据契约 | heading | agent-workflow/templates/dsl/DSL_SUITE_BOUNDARIES.md | 8 | markdown section |
| 联动边界 | heading | agent-workflow/templates/dsl/DSL_SUITE_BOUNDARIES.md | 13 | markdown section |
| 风险与约束 | heading | agent-workflow/templates/dsl/DSL_SUITE_BOUNDARIES.md | 18 | markdown section |
| 00 Requirements — <name> | heading | agent-workflow/templates/dsl/DSL_SUITE_REQUIREMENTS.md | 1 | markdown section |
| 需求描述 | heading | agent-workflow/templates/dsl/DSL_SUITE_REQUIREMENTS.md | 3 | markdown section |
| 用户与场景 | heading | agent-workflow/templates/dsl/DSL_SUITE_REQUIREMENTS.md | 7 | markdown section |
| 范围 | heading | agent-workflow/templates/dsl/DSL_SUITE_REQUIREMENTS.md | 11 | markdown section |
| In Scope | heading | agent-workflow/templates/dsl/DSL_SUITE_REQUIREMENTS.md | 13 | markdown section |
| Out of Scope | heading | agent-workflow/templates/dsl/DSL_SUITE_REQUIREMENTS.md | 17 | markdown section |
| 成功标准 | heading | agent-workflow/templates/dsl/DSL_SUITE_REQUIREMENTS.md | 21 | markdown section |
| 追踪 | heading | agent-workflow/templates/dsl/DSL_SUITE_REQUIREMENTS.md | 25 | markdown section |

## 路由 / API 索引

| 方法 | 路径 | 文件 | 行号 | 说明 |
|------|------|------|------|------|

## 测试映射

| 代码文件 / 模块 | 相关测试 | 推断依据 |
|-----------------|----------|----------|
| 待补充 | 待补充 | no test files detected |

## 依赖线索

| 文件 | 依赖 / import | 说明 |
|------|---------------|------|

## Token 读取规则

- 默认先查 `CODE_MAP.md`，再查 `CODE_CONTEXT_INDEX.md`，再查 `FILE_INDEX.md`，最后才用精准 `rg`。
- `CODE_MAP.md` 是定位索引，不等于授权读取全文。编码前仍必须生成并确认 `CTX-<AT-T>.md`。
- 查询结果不足时，Agent 需要说明“缺什么信息、准备扩大到哪些文件、为什么”，等待工程师确认。
- 禁止为了“了解项目”读取全仓；禁止读取 `.git`、`node_modules`、`dist`、`build`、`coverage`、`.next`、`.nuxt`、`target`、`vendor`、`tmp`、`logs`。
