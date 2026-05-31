# FILE_INDEX（项目代码文件索引）

> 读者：人类工程师。用途是在 AI 代写或修改代码后，快速定位真实项目代码文件，理解每个文件职责，方便人工审查、手动优化和接手维护。

## 维护规则

- 本文件由 `./scripts/aw file-index` 或 `./scripts/generate-file-index.sh` 生成。
- 新增 / 删除 / 重命名前端、后端、共享、测试或配置代码文件后，运行 `./scripts/aw file-index`。
- 优先查看「前端业务代码 / 后端业务代码 / 共享代码 / 测试代码 / 运行配置」；脚本、模板、工作流文档只是辅助索引。
- 本文件供人类工程师定位代码和手改点，不替代代码真源、DSL、Plan、REQ、测试计划或 Bug 流水。
- 生成时间：2026-05-31T15:55:30Z

## 前端业务代码

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| — | 暂无 | — |

## 后端业务代码

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| — | 暂无 | — |

## 共享 / 通用代码

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| — | 暂无 | — |

## 测试代码

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| — | 暂无 | — |

## 运行配置 / 构建配置

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| — | 暂无 | — |

## CLI / 脚本代码

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| `scripts/_aw-bug-lib.sh` | Bug 流水共享函数：创建和追加 docs/handoff/AI_BUG_LOG.md。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/_aw-lib.sh` | 共享基础函数：仓库根目录、模板目录、复制、工程师索引刷新等。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/_aw-task-lib.sh` | 任务和工作流共享函数：解析 DSL/Plan/ATOMIC、任务状态、需求确认记录。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/_aw-verify-lib.sh` | 验证共享函数：解析 Verify 单元、TP 引用、PROJECT_CONFIG 命令。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw` | 统一 CLI 路由入口，分发 init、dsl、plan、task、req、bug、tp、index 等子命令。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-agents.sh` | 多 Agent 协作助手：登记长期 Agent 身份，记录角色分配、交接和评审结论。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-approve.sh` | DSL/Plan 审批落章：设置已审/可执行，并可触发 Plan 提示。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-atomic.sh` | 多 ATOMIC_TASKS 文件的 list/use 选择器。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-audit.sh` | Agent 执行审计助手：记录任务、动作、决策、命令、结果、证据和人工确认点。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-bug.sh` | Bug / 疑似 Bug 记录入口，统一写入 AI_BUG_LOG。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-capabilities.sh` | 输出 CLI 能力摘要和 proof paths，支持 JSON。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-changelog.sh` | 版本记录助手：向 CHANGELOG [Unreleased] 写入可追溯变更条目并检查结构。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-ci.sh` | 安装 GitHub Actions workflow 模板。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-code-map.sh` | 项目文件：aw-code-map.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-commit.sh` | 提交助手：默认先 verify，再建议或执行 commit message。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-compact.sh` | 一键工程化上下文压缩：写 handoff、自动快照、新会话粘贴块和可选聊天 Memory。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-config.sh` | 初始化和更新 docs/PROJECT_CONFIG.md 的技术栈与验证命令。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-confirm.sh` | 任务确认入口：校验 DSL 已审、Plan 可执行并生成确认态和工程师索引。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-context.sh` | 项目文件：aw-context.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-contract.sh` | 项目文件：aw-contract.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-dashboard.sh` | 只读终端 dashboard，汇总状态、能力和机器可读入口。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-demo.sh` | 在临时目录演示完整 agent-workflow 工作流。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-doctor.sh` | 诊断安装、配置、adapter、CI、工作流状态和聚合检查。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-dsl-apply.sh` | 将生成的 DSL 落盘到 docs/dsl 并触发索引刷新。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-dsl-review.sh` | 生成 DSL 工程师审阅包，支持单文件 DSL 和 DSL suite。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-dsl-select.sh` | 多 DSL 文件的 list/use 选择器。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-dsl-suite.sh` | 创建多文件 DSL 套件，覆盖需求、页面、交互、事件、边界、验收。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-gate.sh` | 项目文件：aw-gate.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-github-pr.sh` | 项目文件：aw-github-pr.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-install.sh` | 将 agent-workflow 包和 scripts 安装到目标业务仓。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-memory.sh` | 文件化记忆系统：init、add、list、search、show、archive、inject。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-metrics.sh` | 交付度量助手：记录 DORA / Flow 指标，包括部署、变更、失败和恢复。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-next.sh` | 输出下一条满足依赖的 AT-T，并引导 brief/confirm/start。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-ops.sh` | 可靠性助手：维护 SLO、Incident 和 Runbook 记录。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-plan-apply.sh` | 将 Plan 与 ATOMIC_TASKS 落盘到 docs/plans 并触发索引刷新。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-plan-change.sh` | 研发中计划变更助手：记录 plan change、追加 AT-T、拆分过大任务并自动审计。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-plan-select.sh` | 多 Plan 文件的 list/use 选择器。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-pm.sh` | 项目文件：aw-pm.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-policy.sh` | Policy-as-Code 助手：初始化策略文件、记录策略例外和审批决策、检查策略结构。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-project.sh` | 项目文件：aw-project.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-recover.sh` | 项目文件：aw-recover.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-release.sh` | 发布闭环助手：维护环境、发布记录、回滚计划、Feature Flag 台账和发布门禁。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-remove.sh` | 干运行或执行移除 adapters、CI、package 等安装产物。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-report.sh` | 项目文件：aw-report.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-req.sh` | 统一需求入口：口述新增和研发中变更记录到 REQ，并回写 DSL/Plan/ATOMIC。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-rules.sh` | 生成、审阅、检查 docs/ENGINEERING_RULES.md。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-score.sh` | 项目文件：aw-score.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-security.sh` | 安全与依赖准入助手：记录安全发现和新依赖评审结论。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-service-catalog.sh` | 服务目录助手：维护 docs/SERVICE_CATALOG.md 的服务/模块级交接信息。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-setup.sh` | 一键 setup：install/init/adapters/ci/status/doctor 组合流程。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-status.sh` | 展示当前 DSL、Plan、confirm、当前任务和建议下一步，支持 JSON。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-sync.sh` | 跨项目同步助手：通过共享 Harness 目录同步前后端 Agent 的 DSL、Plan、REQ、Handoff、Bug 和协作快照。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-task.sh` | AT-T 子任务生命周期：brief、confirm、start、blocked、complete、done、paste。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-tp.sh` | 测试计划管理：list、show、new、link 到 AT-T Verify 列。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-trace.sh` | 项目文件：aw-trace.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-upgrade.sh` | 升级目标仓中的 agent-workflow 包、脚本和可选 CI。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-vcs.sh` | 项目文件：aw-vcs.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-verify.sh` | 执行任务 Verify、PROJECT_CONFIG lint/format/typecheck/test/build/e2e。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/aw-watch.sh` | 项目文件：aw-watch.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/build-skill-archive.sh` | 构建 dist/agent-workflow-skill-*.tar.gz 并运行包检查。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-aw-all.sh` | 聚合检查入口，串联 layout、dsl、plan、config、rules、req、tp、plugin、memory。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-aw-layout.sh` | 检查 agent-workflow 基础目录和关键文件是否存在。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-docs-commands.sh` | 检查核心 CLI 命令是否在 skill/reference 与 INVOCATION 中有文档。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-dsl-business-gate.sh` | 提交前业务代码闸门：DSL 未已审时阻止业务路径变更。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-dsl.sh` | 校验 DSL 元数据、关联 REQ、manifest 路径和 suite 完整性。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-file-index-sync.sh` | 项目文件：check-file-index-sync.sh。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-memory.sh` | 检查 docs/memory 布局和记忆索引。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-plan.sh` | 校验 Plan 状态、关联 DSL/REQ、ATOMIC 任务和 TP 引用。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-plugin-metadata.sh` | 检查 Codex plugin 和 marketplace metadata。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-project-config.sh` | 检查 PROJECT_CONFIG 技术栈和验证命令是否填写。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-req-index.sh` | 检查 REQ 文件、需求类型和 INDEX 反向链接。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-skill-package.sh` | 检查打包后的 skill 目录结构、脚本路由和文档能力是否完整。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-skill-source.sh` | 检查源码仓 skill 文件、模板、plugin metadata 和版本一致性。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/check-test-plan-index.sh` | 检查 TP 文件与测试计划索引一致性。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/commit-gate.sh` | 提交门禁：运行 pre-commit-verify 并处理 open Bug 流水策略。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/draft-dsl.sh` | 输出 DSL 生成提示，按 reference/manifest 路径模式组织上下文。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/draft-handoff.sh` | 生成 PROJECT_HANDOFF 更新草稿。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/draft-plan.sh` | 输出 Plan + ATOMIC 生成提示，支持前端/后端等 domain 定向拆分。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/generate-engineering-index.sh` | 生成 ENGINEERING_INDEX.md，人类工程师交付路径聚合索引。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/generate-file-index.sh` | 生成 docs/FILE_INDEX.md，面向工程师手动优化代码的项目代码文件索引。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/init-project.sh` | 初始化业务仓 reference、docs、模板、配置、FILE_INDEX、Bug 流水等基础文件。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/install-aw-adapters.sh` | 安装 Claude/Codex/Copilot/Cursor/Windsurf/Cline/Continue 适配规则。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/install-cursor-skill.sh` | 安装构建产物到 Cursor skill 目录。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/install-git-hooks.sh` | 安装仓库 .githooks。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/new-req.sh` | 兼容旧入口：新建 REQ 文件并更新需求索引。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/new-test-plan.sh` | 新建 TP 测试计划文件并更新 TP 索引。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/pre-commit-verify.sh` | pre-commit 聚合验证脚本。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/sync-skill.sh` | 同步源码到 Cursor skill 目录和 dist/stage 包目录。 | 改 CLI 行为时同步更新 help、reference、e2e。 |

## Skill / 插件包

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| `skill/QUICKSTART.md` | skill 快速开始命令序列。 | 改能力或命令后同步 skill 文档和包检查。 |
| `skill/SKILL.md` | Codex skill 主说明和触发后的核心工作流。 | 改能力或命令后同步 skill 文档和包检查。 |
| `skill/VERSION` | agent-workflow / skill 版本号。 | 改能力或命令后同步 skill 文档和包检查。 |
| `skill/reference.md` | skill 详细 CLI 参考和边界说明。 | 改能力或命令后同步 skill 文档和包检查。 |

## 工作流包文档

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| `agent-workflow/AGENTS.md` | 项目 Markdown 文档：AGENTS.md。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/AGENTWORKFLOW_MANUAL.html` | 暗色本地 HTML 使用手册，包含完整功能流程图、工程师与 Agent 使用说明、命令和对话模板。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/AGENT_RULES.md` | 可复制到 IDE/Agent 的精简执行规则。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/AICODING_WORKFLOW.md` | AI 编码阶段 A-E、验证闭环、需求/交接存档规则。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/BOOTSTRAP.md` | 项目 Markdown 文档：BOOTSTRAP.md。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/CHANGELOG.md` | agent-workflow 变更记录。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/CLAUDE.md` | Claude/Agent 兼容的仓库级工作流说明。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/CROSS_PROJECT_SYNC.md` | 前后端分仓 / 两个项目的 Agent 同步教程，说明 aw sync 的共享 Harness、push/pull 和 inbox 边界。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/INDEX.md` | agent-workflow 包文件索引。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/INVOCATION.en.md` | 项目 Markdown 文档：INVOCATION.en.md。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/INVOCATION.md` | 工具无关调用入口和命令速查。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/PRODUCT_INPUT_WORKFLOW.md` | Reference → DSL → Plan → confirm 的阶段 0 输入流程。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/PROMPTS.md` | 项目 Markdown 文档：PROMPTS.md。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/README.md` | 项目 Markdown 文档：README.md。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/README_AGENT_DOCS.md` | 项目 Markdown 文档：README_AGENT_DOCS.md。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/REPOSITORY.md` | 包内文档导航和仓库真源说明。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/REPO_LANDING_CHECKLIST.md` | 项目 Markdown 文档：REPO_LANDING_CHECKLIST.md。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/SECURITY.md` | 安全报告和安全策略说明。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/VERSION` | agent-workflow / skill 版本号。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md` | 版本、CHANGELOG、Bug、测试复测闭环规范。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/WINDOWS.md` | 项目 Markdown 文档：WINDOWS.md。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/meta/PRE_COMMIT_AND_HOOKS.md` | 项目 Markdown 文档：PRE_COMMIT_AND_HOOKS.md。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/meta/README_AGENT_DOCS.md` | 项目 Markdown 文档：README_AGENT_DOCS.md。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |

## 模板文件

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| `agent-workflow/templates/ENGINEERING_INDEX.header.md` | ENGINEERING_INDEX.md 生成模板。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/SERVICE_CATALOG.md` | 服务/模块级目录，记录 owner、入口、API、数据、依赖、验证、部署和告警入口。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/agents/AGENT_HANDOFFS.md` | 多 Agent 角色、交接和评审模板或记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/agents/AGENT_HEARTBEATS.md` | 多 Agent 角色、交接和评审模板或记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/agents/AGENT_LOCKS.md` | 多 Agent 角色、交接和评审模板或记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/agents/AGENT_PRESETS.tsv` | 默认 Agent 注册预设配置，供 aw agents register --preset/--defaults 使用。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/agents/AGENT_REGISTRY.md` | 长期 Agent 身份登记表，记录 worker identity、职责、边界和状态。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/agents/AGENT_REVIEWS.md` | 多 Agent 角色、交接和评审模板或记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/agents/AGENT_ROLES.md` | 多 Agent 角色、交接和评审模板或记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/audit/AGENT_TRACE.md` | Agent 执行审计模板或流水，记录关键动作、命令、结果和确认点。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/context/CODE_CONTEXT_INDEX.md` | 项目 Markdown 文档：CODE_CONTEXT_INDEX.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/context/CODE_MAP.md` | 项目 Markdown 文档：CODE_MAP.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/context/CONTEXT_CONFIG.md` | 项目 Markdown 文档：CONTEXT_CONFIG.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/context/CONTEXT_PLAN_TEMPLATE.md` | 项目 Markdown 文档：CONTEXT_PLAN_TEMPLATE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/contracts/API_CHANGELOG.md` | 项目 Markdown 文档：API_CHANGELOG.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/contracts/API_CONTRACT.openapi.yaml` | 项目 YAML 配置：API_CONTRACT.openapi.yaml。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/contracts/CONTRACT_TESTS.md` | 项目 Markdown 文档：CONTRACT_TESTS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/contracts/MOCK_SERVER.md` | 项目 Markdown 文档：MOCK_SERVER.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/dsl/DSL_DRAFT.md` | DSL 模板或示例文件：DSL_DRAFT.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/dsl/DSL_SPEC_TEMPLATE.md` | DSL 模板或示例文件：DSL_SPEC_TEMPLATE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/dsl/DSL_SUITE_ACCEPTANCE.md` | DSL 模板或示例文件：DSL_SUITE_ACCEPTANCE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/dsl/DSL_SUITE_BOUNDARIES.md` | DSL 模板或示例文件：DSL_SUITE_BOUNDARIES.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/dsl/DSL_SUITE_EVENTS.md` | DSL 模板或示例文件：DSL_SUITE_EVENTS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/dsl/DSL_SUITE_INDEX.md` | DSL 模板或示例文件：DSL_SUITE_INDEX.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/dsl/DSL_SUITE_INTERACTIONS.md` | DSL 模板或示例文件：DSL_SUITE_INTERACTIONS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/dsl/DSL_SUITE_PAGES.md` | DSL 模板或示例文件：DSL_SUITE_PAGES.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/dsl/DSL_SUITE_REQUIREMENTS.md` | DSL 模板或示例文件：DSL_SUITE_REQUIREMENTS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md` | DSL 模板或示例文件：FRONTEND_PAGE_SPEC_TEMPLATE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/github/BRANCH_POLICY.md` | 项目 Markdown 文档：BRANCH_POLICY.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/github/PR_CHECKLIST.md` | 项目 Markdown 文档：PR_CHECKLIST.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/github/REVIEW_GATE.md` | 项目 Markdown 文档：REVIEW_GATE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/hooks/HOOKS.md` | 项目 Markdown 文档：HOOKS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/memory/INDEX.md` | 记忆系统模板或说明：INDEX.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/memory/README.md` | 记忆系统模板或说明：README.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/memory/_TEMPLATE.md` | 记忆系统模板或说明：_TEMPLATE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/metrics/DELIVERY_METRICS.md` | DORA / Flow 交付度量模板或记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/ops/INCIDENTS.md` | SLO、Incident、Runbook 可靠性模板或记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/ops/RUNBOOKS.md` | SLO、Incident、Runbook 可靠性模板或记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/ops/SLO.md` | SLO、Incident、Runbook 可靠性模板或记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/plans/_TEMPLATE_ATOMIC_TASKS.md` | Plan / ATOMIC_TASKS 模板或说明：_TEMPLATE_ATOMIC_TASKS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/plans/_TEMPLATE_PLAN.md` | Plan / ATOMIC_TASKS 模板或说明：_TEMPLATE_PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/analytics/EVENT_TRACKING.md` | 项目 Markdown 文档：EVENT_TRACKING.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/analytics/FUNNEL.md` | 项目 Markdown 文档：FUNNEL.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/analytics/METRICS_PLAN.md` | 项目 Markdown 文档：METRICS_PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/analytics/METRICS_REVIEW.md` | 项目 Markdown 文档：METRICS_REVIEW.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/architecture/ARCHITECTURE_DECISION_RECORDS.md` | 项目 Markdown 文档：ARCHITECTURE_DECISION_RECORDS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/architecture/AUTH_MODEL.md` | 项目 Markdown 文档：AUTH_MODEL.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/architecture/DATA_MODEL.md` | 项目 Markdown 文档：DATA_MODEL.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/architecture/INTEGRATION_DESIGN.md` | 项目 Markdown 文档：INTEGRATION_DESIGN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/architecture/TECH_DESIGN.md` | 项目 Markdown 文档：TECH_DESIGN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/contracts/INTEGRATION_MATRIX.md` | 项目 Markdown 文档：INTEGRATION_MATRIX.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dashboard/BLOCKERS.md` | 项目 Markdown 文档：BLOCKERS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dashboard/CHANGE_REQUESTS.md` | 项目 Markdown 文档：CHANGE_REQUESTS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dashboard/DECISION_BOARD.md` | 项目 Markdown 文档：DECISION_BOARD.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dashboard/EXECUTIVE_SUMMARY.md` | 项目 Markdown 文档：EXECUTIVE_SUMMARY.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dashboard/LIFECYCLE_BOARD.md` | 项目 Markdown 文档：LIFECYCLE_BOARD.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dashboard/PROGRESS_BOARD.md` | 项目 Markdown 文档：PROGRESS_BOARD.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dashboard/PROJECT_DASHBOARD.md` | 项目 Markdown 文档：PROJECT_DASHBOARD.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dashboard/RISKS.md` | 项目 Markdown 文档：RISKS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/delivery/DAILY_SYNC.md` | 项目 Markdown 文档：DAILY_SYNC.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/delivery/DELIVERY_RISKS.md` | 项目 Markdown 文档：DELIVERY_RISKS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/delivery/DEPENDENCY_GRAPH.md` | 项目 Markdown 文档：DEPENDENCY_GRAPH.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/delivery/ITERATION_PLAN.md` | 项目 Markdown 文档：ITERATION_PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/delivery/REWORK_LOG.md` | 项目 Markdown 文档：REWORK_LOG.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dispatch/ADMIN_ASSIGNMENTS.md` | 项目 Markdown 文档：ADMIN_ASSIGNMENTS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dispatch/BACKEND_ASSIGNMENTS.md` | 项目 Markdown 文档：BACKEND_ASSIGNMENTS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dispatch/FRONTEND_ASSIGNMENTS.md` | 项目 Markdown 文档：FRONTEND_ASSIGNMENTS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dispatch/TASK_BOARD.md` | 项目 Markdown 文档：TASK_BOARD.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dsl/DSL_ACCEPTANCE.md` | 项目 Markdown 文档：DSL_ACCEPTANCE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dsl/DSL_BOUNDARIES.md` | 项目 Markdown 文档：DSL_BOUNDARIES.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dsl/DSL_EVENTS.md` | 项目 Markdown 文档：DSL_EVENTS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dsl/DSL_INTERACTIONS.md` | 项目 Markdown 文档：DSL_INTERACTIONS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dsl/DSL_PAGES.md` | 项目 Markdown 文档：DSL_PAGES.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dsl/DSL_REQUIREMENTS.md` | 项目 Markdown 文档：DSL_REQUIREMENTS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/dsl/INDEX.md` | 项目 Markdown 文档：INDEX.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/integration/INTEGRATION_ACCEPTANCE.md` | 项目 Markdown 文档：INTEGRATION_ACCEPTANCE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/integration/INTEGRATION_ISSUES.md` | 项目 Markdown 文档：INTEGRATION_ISSUES.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/integration/INTEGRATION_PLAN.md` | 项目 Markdown 文档：INTEGRATION_PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/integration/MOCK_STRATEGY.md` | 项目 Markdown 文档：MOCK_STRATEGY.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/knowledge/DECISION_LOG.md` | 项目 Markdown 文档：DECISION_LOG.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/knowledge/FAQ.md` | 项目 Markdown 文档：FAQ.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/knowledge/PRODUCT_KNOWLEDGE.md` | 项目 Markdown 文档：PRODUCT_KNOWLEDGE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/knowledge/TECH_KNOWLEDGE.md` | 项目 Markdown 文档：TECH_KNOWLEDGE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/plans/ADMIN_FRONTEND_PLAN.md` | 项目 Markdown 文档：ADMIN_FRONTEND_PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/plans/ATOMIC_TASKS.md` | 项目 Markdown 文档：ATOMIC_TASKS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/plans/BACKEND_PLAN.md` | 项目 Markdown 文档：BACKEND_PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/plans/FRONTEND_PLAN.md` | 项目 Markdown 文档：FRONTEND_PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/plans/GLOBAL_PLAN.md` | 项目 Markdown 文档：GLOBAL_PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/product/COMPETITOR_NOTES.md` | 项目 Markdown 文档：COMPETITOR_NOTES.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/product/MVP_SCOPE.md` | 项目 Markdown 文档：MVP_SCOPE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/product/PRODUCT_BRIEF.md` | 项目 Markdown 文档：PRODUCT_BRIEF.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/product/STAKEHOLDERS.md` | 项目 Markdown 文档：STAKEHOLDERS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/product/SUCCESS_METRICS.md` | 项目 Markdown 文档：SUCCESS_METRICS.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/quality/QUALITY_REPORT.md` | 项目 Markdown 文档：QUALITY_REPORT.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/quality/REGRESSION_PLAN.md` | 项目 Markdown 文档：REGRESSION_PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/quality/TEST_CASES.md` | 项目 Markdown 文档：TEST_CASES.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/quality/TEST_STRATEGY.md` | 项目 Markdown 文档：TEST_STRATEGY.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/quality/UAT_RECORD.md` | 项目 Markdown 文档：UAT_RECORD.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/references/README.md` | 项目 Markdown 文档：README.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/references/design/DESIGN_CHANGELOG.md` | 项目 Markdown 文档：DESIGN_CHANGELOG.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/references/design/DESIGN_FREEZE.md` | 项目 Markdown 文档：DESIGN_FREEZE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/references/design/DESIGN_INDEX.md` | 项目 Markdown 文档：DESIGN_INDEX.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/references/design/DESIGN_QA.md` | 项目 Markdown 文档：DESIGN_QA.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/references/design/DESIGN_REVIEW.md` | 项目 Markdown 文档：DESIGN_REVIEW.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/references/design/pencil/README.md` | 项目 Markdown 文档：README.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/release/GO_LIVE_CHECKLIST.md` | 项目 Markdown 文档：GO_LIVE_CHECKLIST.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/release/POST_RELEASE_REVIEW.md` | 项目 Markdown 文档：POST_RELEASE_REVIEW.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/release/RELEASE_PLAN.md` | 项目 Markdown 文档：RELEASE_PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/release/ROLLBACK_PLAN.md` | 项目 Markdown 文档：ROLLBACK_PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/requirements/ACCEPTANCE_RECORD.md` | 项目 Markdown 文档：ACCEPTANCE_RECORD.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/requirements/BACKLOG.md` | 项目 Markdown 文档：BACKLOG.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/requirements/PRIORITIZATION.md` | 项目 Markdown 文档：PRIORITIZATION.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/pm/requirements/REVIEW_LOG.md` | 项目 Markdown 文档：REVIEW_LOG.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/policy/POLICY.yml` | Policy-as-Code 策略和例外审批记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/policy/POLICY_DECISIONS.md` | Policy-as-Code 策略和例外审批记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/prompts/PROMPT-DSL.md` | 生成提示模板：PROMPT-DSL.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/prompts/PROMPT-PLAN.md` | 生成提示模板：PROMPT-PLAN.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/quality/test-plans/INDEX.md` | 测试计划模板或索引：INDEX.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/quality/test-plans/README.md` | 测试计划模板或索引：README.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/quality/test-plans/_TEMPLATE.md` | 测试计划模板或索引：_TEMPLATE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/recovery/RECOVERY_PLAYBOOK.md` | 项目 Markdown 文档：RECOVERY_PLAYBOOK.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/reference/README.md` | 项目 Markdown 文档：README.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/reference/manifest.yaml.example` | 项目文件：manifest.yaml.example。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/release/ENVIRONMENTS.md` | 环境、发布、回滚和 Feature Flag 记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/release/FEATURE_FLAGS.md` | 环境、发布、回滚和 Feature Flag 记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/release/RELEASE_RECORD.md` | 环境、发布、回滚和 Feature Flag 记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/rules/ENGINEERING_RULES.md` | 工程规范模板：ENGINEERING_RULES.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/score/DELIVERY_SCORE.md` | 项目 Markdown 文档：DELIVERY_SCORE.md。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/security/DEPENDENCY_REVIEW.md` | 安全发现与依赖准入记录。 | 改模板后同步 init/e2e 和生成产物预期。 |
| `agent-workflow/templates/security/SECURITY_FINDINGS.md` | 安全发现与依赖准入记录。 | 改模板后同步 init/e2e 和生成产物预期。 |

## IDE / Agent 适配

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| `agent-workflow/adapters/README.md` | IDE / Agent 适配说明：README。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/adapters/claude-code.md` | IDE / Agent 适配说明：claude-code。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/adapters/cline.md` | IDE / Agent 适配说明：cline。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/adapters/codex-context/README.md` | Codex 新会话连续性说明：Handoff、Memory、Chat Memory 与原生上下文压缩边界。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/adapters/codex.md` | IDE / Agent 适配说明：codex。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/adapters/continue.md` | IDE / Agent 适配说明：continue。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/adapters/copilot.md` | IDE / Agent 适配说明：copilot。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/adapters/cursor-hooks/README.md` | IDE / Agent 适配说明：README。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/adapters/cursor.md` | IDE / Agent 适配说明：cursor。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/adapters/generic-chat.md` | IDE / Agent 适配说明：generic-chat。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/adapters/vscode.md` | IDE / Agent 适配说明：vscode。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |
| `agent-workflow/adapters/windsurf.md` | IDE / Agent 适配说明：windsurf。 | 改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。 |

## 项目工作流文档

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| `docs/SERVICE_CATALOG.md` | 服务/模块级目录，记录 owner、入口、API、数据、依赖、验证、部署和告警入口。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/agents/AGENT_HANDOFFS.md` | 多 Agent 角色、交接和评审模板或记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/agents/AGENT_HEARTBEATS.md` | 多 Agent 角色、交接和评审模板或记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/agents/AGENT_LOCKS.md` | 多 Agent 角色、交接和评审模板或记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/agents/AGENT_PRESETS.tsv` | 默认 Agent 注册预设配置，供 aw agents register --preset/--defaults 使用。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/agents/AGENT_REGISTRY.md` | 长期 Agent 身份登记表，记录 worker identity、职责、边界和状态。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/agents/AGENT_REVIEWS.md` | 多 Agent 角色、交接和评审模板或记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/agents/AGENT_ROLES.md` | 多 Agent 角色、交接和评审模板或记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/audit/AGENT_TRACE.md` | Agent 执行审计模板或流水，记录关键动作、命令、结果和确认点。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/dsl/DSL_SPEC_TEMPLATE.md` | DSL 模板或示例文件：DSL_SPEC_TEMPLATE.md。 | 作为业务真源变更时同步相关 REQ/DSL/Plan/ATOMIC。 |
| `docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md` | DSL 模板或示例文件：FRONTEND_PAGE_SPEC_TEMPLATE.md。 | 作为业务真源变更时同步相关 REQ/DSL/Plan/ATOMIC。 |
| `docs/dsl/README.md` | DSL 模板或示例文件：README.md。 | 作为业务真源变更时同步相关 REQ/DSL/Plan/ATOMIC。 |
| `docs/handoff/AGENTWORKFLOW_ROADMAP.md` | 项目 Markdown 文档：AGENTWORKFLOW_ROADMAP.md。 | 更新交接、记忆或同步快照时保持来源、时间和范围清楚。 |
| `docs/handoff/AI_BUG_LOG.md` | Bug / 测试失败 / 反馈问题流水。 | 更新交接、记忆或同步快照时保持来源、时间和范围清楚。 |
| `docs/handoff/CURSOR_CONTEXT_HOOK.md` | 项目 Markdown 文档：CURSOR_CONTEXT_HOOK.md。 | 更新交接、记忆或同步快照时保持来源、时间和范围清楚。 |
| `docs/handoff/ENGINEERING_HARNESS_TASKS.md` | 项目 Markdown 文档：ENGINEERING_HARNESS_TASKS.md。 | 更新交接、记忆或同步快照时保持来源、时间和范围清楚。 |
| `docs/handoff/HANDOFF_GUIDE.md` | 项目 Markdown 文档：HANDOFF_GUIDE.md。 | 更新交接、记忆或同步快照时保持来源、时间和范围清楚。 |
| `docs/handoff/NEW_CHAT_PASTE_TEMPLATE.md` | 项目 Markdown 文档：NEW_CHAT_PASTE_TEMPLATE.md。 | 更新交接、记忆或同步快照时保持来源、时间和范围清楚。 |
| `docs/handoff/PROJECT_HANDOFF.md` | 当前进度、目标、风险和下一步交接快照。 | 更新交接、记忆或同步快照时保持来源、时间和范围清楚。 |
| `docs/handoff/README.md` | 项目 Markdown 文档：README.md。 | 更新交接、记忆或同步快照时保持来源、时间和范围清楚。 |
| `docs/memory/INDEX.md` | 跨会话记忆索引。 | 更新交接、记忆或同步快照时保持来源、时间和范围清楚。 |
| `docs/memory/README.md` | 记忆系统模板或说明：README.md。 | 更新交接、记忆或同步快照时保持来源、时间和范围清楚。 |
| `docs/memory/_TEMPLATE.md` | 记忆系统模板或说明：_TEMPLATE.md。 | 更新交接、记忆或同步快照时保持来源、时间和范围清楚。 |
| `docs/metrics/DELIVERY_METRICS.md` | DORA / Flow 交付度量模板或记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/ops/INCIDENTS.md` | SLO、Incident、Runbook 可靠性模板或记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/ops/RUNBOOKS.md` | SLO、Incident、Runbook 可靠性模板或记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/ops/SLO.md` | SLO、Incident、Runbook 可靠性模板或记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/plans/README.md` | Plan / ATOMIC_TASKS 模板或说明：README.md。 | 作为业务真源变更时同步相关 REQ/DSL/Plan/ATOMIC。 |
| `docs/plans/_TEMPLATE_ATOMIC_TASKS.md` | Plan / ATOMIC_TASKS 模板或说明：_TEMPLATE_ATOMIC_TASKS.md。 | 作为业务真源变更时同步相关 REQ/DSL/Plan/ATOMIC。 |
| `docs/plans/_TEMPLATE_PLAN.md` | Plan / ATOMIC_TASKS 模板或说明：_TEMPLATE_PLAN.md。 | 作为业务真源变更时同步相关 REQ/DSL/Plan/ATOMIC。 |
| `docs/policy/POLICY.yml` | Policy-as-Code 策略和例外审批记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/policy/POLICY_DECISIONS.md` | Policy-as-Code 策略和例外审批记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/quality/README.md` | 项目 Markdown 文档：README.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/quality/test-plans/INDEX.md` | 测试计划模板或索引：INDEX.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/quality/test-plans/README.md` | 测试计划模板或索引：README.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/quality/test-plans/_TEMPLATE.md` | 测试计划模板或索引：_TEMPLATE.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/release/ENVIRONMENTS.md` | 环境、发布、回滚和 Feature Flag 记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/release/FEATURE_FLAGS.md` | 环境、发布、回滚和 Feature Flag 记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/release/RELEASE_RECORD.md` | 环境、发布、回滚和 Feature Flag 记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/requirements/INDEX.md` | 统一需求表，按需求类型区分口述新增和研发中变更。 | 作为业务真源变更时同步相关 REQ/DSL/Plan/ATOMIC。 |
| `docs/requirements/README.md` | 项目 Markdown 文档：README.md。 | 作为业务真源变更时同步相关 REQ/DSL/Plan/ATOMIC。 |
| `docs/requirements/_TEMPLATE.md` | 项目 Markdown 文档：_TEMPLATE.md。 | 作为业务真源变更时同步相关 REQ/DSL/Plan/ATOMIC。 |
| `docs/security/DEPENDENCY_REVIEW.md` | 安全发现与依赖准入记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/security/SECURITY_FINDINGS.md` | 安全发现与依赖准入记录。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/workflow/README.md` | 项目 Markdown 文档：README.md。 | 变更后按影响范围同步索引、文档和验证。 |

## CI / Git Hooks

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| — | 暂无 | — |

## 仓库入口 / 配置

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| `AGENTS.md` | 仓库根 Agent 入口规则。 | 变更后按影响范围同步索引、文档和验证。 |
| `AGENT_RULES.md` | 仓库根 Agent 入口规则。 | 变更后按影响范围同步索引、文档和验证。 |
| `CLAUDE.md` | 仓库根 Agent 入口规则。 | 变更后按影响范围同步索引、文档和验证。 |
| `LICENSE` | 许可证文件。 | 变更后按影响范围同步索引、文档和验证。 |
| `PUBLISH.md` | 发布和打包说明。 | 变更后按影响范围同步索引、文档和验证。 |
| `README.md` | 仓库根 README，能力总览和入口。 | 变更后按影响范围同步索引、文档和验证。 |
| `SECURITY.md` | 安全报告和安全策略说明。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/ENGINEERING_RULES.md` | 项目工程规范实例文件。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/FILE_INDEX.md` | 本文件：项目代码文件索引，供人类工程师定位代码文件、理解职责和手动优化。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/PROJECT_CONFIG.md` | 项目技术栈、包管理器和验证命令配置。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/README.md` | 项目 Markdown 文档：README.md。 | 变更后按影响范围同步索引、文档和验证。 |

## 参考材料入口

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| `reference/README.md` | 参考材料目录说明或 manifest 示例。 | 变更后按影响范围同步索引、文档和验证。 |
| `reference/manifest.yaml.example` | 参考材料目录说明或 manifest 示例。 | 变更后按影响范围同步索引、文档和验证。 |

## 其他项目文件

| 路径 | 说明 | 维护提示 |
|------|------|----------|
| `docs/context/CODE_CONTEXT_INDEX.md` | 项目 Markdown 文档：CODE_CONTEXT_INDEX.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/context/CODE_MAP.md` | 项目 Markdown 文档：CODE_MAP.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/context/CONTEXT_CONFIG.md` | 项目 Markdown 文档：CONTEXT_CONFIG.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/contracts/API_CHANGELOG.md` | 项目 Markdown 文档：API_CHANGELOG.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/contracts/API_CONTRACT.openapi.yaml` | 项目 YAML 配置：API_CONTRACT.openapi.yaml。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/contracts/CONTRACT_TESTS.md` | 项目 Markdown 文档：CONTRACT_TESTS.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/contracts/MOCK_SERVER.md` | 项目 Markdown 文档：MOCK_SERVER.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/github/BRANCH_POLICY.md` | 项目 Markdown 文档：BRANCH_POLICY.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/github/PR_CHECKLIST.md` | 项目 Markdown 文档：PR_CHECKLIST.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/github/REVIEW_GATE.md` | 项目 Markdown 文档：REVIEW_GATE.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/hooks/HOOKS.md` | 项目 Markdown 文档：HOOKS.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/index.html` | 项目文件：index.html。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/product/ENGINEERING_HARNESS_PRD.md` | 项目 Markdown 文档：ENGINEERING_HARNESS_PRD.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/product/PM_AGENT_LIFECYCLE_PRD.md` | 项目 Markdown 文档：PM_AGENT_LIFECYCLE_PRD.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/product/tasks/PM_AGENT_LIFECYCLE_PLAN.md` | 项目 Markdown 文档：PM_AGENT_LIFECYCLE_PLAN.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/product/tasks/PM_AGENT_LIFECYCLE_TASKS.md` | 项目 Markdown 文档：PM_AGENT_LIFECYCLE_TASKS.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/recovery/RECOVERY_PLAYBOOK.md` | 项目 Markdown 文档：RECOVERY_PLAYBOOK.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/score/DELIVERY_SCORE.md` | 项目 Markdown 文档：DELIVERY_SCORE.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/vcs/BRANCH_POLICY.md` | 项目 Markdown 文档：BRANCH_POLICY.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/vcs/PR_CHECKLIST.md` | 项目 Markdown 文档：PR_CHECKLIST.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `docs/vcs/REVIEW_GATE.md` | 项目 Markdown 文档：REVIEW_GATE.md。 | 变更后按影响范围同步索引、文档和验证。 |
| `scripts/README.md` | 项目 Markdown 文档：README.md。 | 改 CLI 行为时同步更新 help、reference、e2e。 |
| `scripts/e2e-smoke.sh` | 端到端冒烟测试：打包、安装、init、DSL/Plan、任务、REQ、Bug、TP、索引刷新。 | 改 CLI 行为时同步更新 help、reference、e2e。 |

