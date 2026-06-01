#!/usr/bin/env bash
# Generate docs/FILE_INDEX.md for human engineers to locate project code files.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
OUT="${ROOT}/docs/FILE_INDEX.md"

category_of() {
  local f="$1"
  case "$f" in
    src/views/*|src/pages/*|src/components/*|src/router/*|src/routes/*|src/store/*|src/stores/*|src/api/*|src/assets/*|src/styles/*|src/layout*|src/layouts/*|src/main.*|src/App.*|frontend/*|web/*|apps/*/src/views/*|apps/*/src/pages/*|apps/*/src/components/*|apps/*/src/router/*|apps/*/src/store/*|apps/*/src/api/*|packages/*/src/components/*|packages/*/src/hooks/*) echo "前端业务代码" ;;
    src/main/java/*|src/main/kotlin/*|src/main/resources/*|backend/*|server/*|service/*|services/*|modules/*/src/main/*|app/Http/*|app/Models/*|app/Services/*|app/Repositories/*|app/Controllers/*|internal/*|cmd/*|pkg/*) echo "后端业务代码" ;;
    src/lib/*|src/libs/*|src/utils/*|src/hooks/*|src/composables/*|src/types/*|src/constants/*|src/shared/*|shared/*|common/*|packages/*/src/*|libs/*|lib/*) echo "共享 / 通用代码" ;;
    test/*|tests/*|__tests__/*|src/test/*|src/**/*.test.*|src/**/*.spec.*|**/*.test.*|**/*.spec.*|cypress/*|e2e/*|playwright.config.*|vitest.config.*|jest.config.*) echo "测试代码" ;;
    package.json|pnpm-lock.yaml|package-lock.json|yarn.lock|vite.config.*|vue.config.*|tsconfig*.json|jsconfig*.json|eslint.config.*|.eslintrc*|prettier.config.*|.prettierrc*|tailwind.config.*|postcss.config.*|Dockerfile|docker-compose*.yml|docker-compose*.yaml|pom.xml|build.gradle|settings.gradle|gradle.properties|mvnw|gradlew|application*.yml|application*.yaml|bootstrap*.yml|bootstrap*.yaml|src/main/resources/application*.yml|src/main/resources/application*.yaml|src/main/resources/bootstrap*.yml|src/main/resources/bootstrap*.yaml) echo "运行配置 / 构建配置" ;;
    scripts/aw|scripts/aw-*.sh|scripts/_aw-*.sh|scripts/check-*.sh|scripts/draft-*.sh|scripts/generate-*.sh|scripts/init-project.sh|scripts/install-*.sh|scripts/new-*.sh|scripts/pre-commit-verify.sh|scripts/commit-gate.sh|scripts/sync-skill.sh|scripts/build-skill-archive.sh) echo "CLI / 脚本代码" ;;
    skill/*|.codex-plugin/*|.agents/*) echo "Skill / 插件包" ;;
    agent-workflow/templates/*) echo "模板文件" ;;
    agent-workflow/adapters/*|agent-workflow/adapters/*/*) echo "IDE / Agent 适配" ;;
    agent-workflow/*|agent-workflow/meta/*) echo "工作流包文档" ;;
    docs/dsl/*|docs/plans/*|docs/requirements/*|docs/quality/*|docs/quality/test-plans/*|docs/handoff/*|docs/memory/*|docs/workflow/*|docs/audit/*|docs/policy/*|docs/security/*|docs/release/*|docs/metrics/*|docs/ops/*|docs/agents/*|docs/sync/*|docs/sync/*/*|docs/SERVICE_CATALOG.md) echo "项目工作流文档" ;;
    .github/*|.github/workflows/*|.github/ISSUE_TEMPLATE/*|.githooks/*) echo "CI / Git Hooks" ;;
    reference/*) echo "参考材料入口" ;;
    README.md|AGENTS.md|AGENT_RULES.md|CLAUDE.md|SECURITY.md|PUBLISH.md|LICENSE|docs/PROJECT_CONFIG.md|docs/ENGINEERING_RULES.md|docs/FILE_INDEX.md|docs/README.md) echo "仓库入口 / 配置" ;;
    *) echo "其他项目文件" ;;
  esac
}

desc_of() {
  local f="$1" b
  b="$(basename "$f")"
  case "$f" in
    src/views/*|src/pages/*|apps/*/src/views/*|apps/*/src/pages/*) echo "前端页面入口，承载路由页面布局、页面级状态、查询/表单/列表/详情交互。" ;;
    src/components/*|packages/*/src/components/*|apps/*/src/components/*) echo "前端组件文件，封装可复用 UI、展示逻辑和局部交互。" ;;
    src/router/*|src/routes/*|apps/*/src/router/*) echo "前端路由配置，维护页面路径、权限入口、菜单或导航关系。" ;;
    src/store/*|src/stores/*|apps/*/src/store/*) echo "前端状态管理，维护跨页面共享状态、缓存和业务动作。" ;;
    src/api/*|apps/*/src/api/*) echo "前端 API client，封装接口路径、请求参数、响应类型和错误处理。" ;;
    src/hooks/*|src/composables/*|packages/*/src/hooks/*) echo "前端组合逻辑 / Hook，复用业务状态、请求、校验或交互流程。" ;;
    src/utils/*|src/lib/*|src/libs/*|src/shared/*|src/types/*|src/constants/*|shared/*|common/*|lib/*|libs/*) echo "共享工具、类型、常量或跨模块复用代码。" ;;
    src/main.*|src/App.*) echo "前端应用入口，负责应用挂载、全局插件、根组件或全局样式接入。" ;;
    src/assets/*|src/styles/*) echo "前端资源或样式文件，影响页面视觉、主题、图标或静态资源引用。" ;;
    *Controller.java|*Controller.kt|*Controller.go|*Controller.ts|*Controller.js|app/Controllers/*) echo "后端接口控制器，承载路由入口、参数接收、权限边界和响应结构。" ;;
    *Service.java|*ServiceImpl.java|*Service.kt|*Service.go|app/Services/*|services/*|service/*) echo "后端业务服务，承载核心业务规则、事务编排和外部依赖调用。" ;;
    *Mapper.java|*Repository.java|*Repository.kt|*Dao.java|*DAO.java|app/Repositories/*) echo "后端数据访问层，维护数据库查询、持久化映射或仓储接口。" ;;
    *Entity.java|*Model.java|*DO.java|*PO.java|app/Models/*) echo "后端数据模型，描述持久化实体、领域对象或 ORM 映射。" ;;
    *DTO.java|*VO.java|*Request.java|*Response.java|*Form.java|*Param.java) echo "后端接口数据结构，描述入参、出参、表单、分页或传输对象。" ;;
    src/main/resources/*) echo "后端资源配置，包含应用配置、Mapper XML、静态资源或运行时资源。" ;;
    test/*|tests/*|__tests__/*|src/test/*|*.test.*|*.spec.*|cypress/*|e2e/*) echo "测试代码或测试配置，用于单测、集成测试、端到端验证或复测。" ;;
    package.json) echo "前端 / Node 项目清单，维护脚本、依赖、包信息和工程入口。" ;;
    vite.config.*|vue.config.*|tsconfig*.json|jsconfig*.json|eslint.config.*|.eslintrc*|prettier.config.*|.prettierrc*|tailwind.config.*|postcss.config.*) echo "前端构建、类型检查、Lint、格式化或样式工具配置。" ;;
    pom.xml|build.gradle|settings.gradle|gradle.properties|mvnw|gradlew) echo "后端 Java 构建配置，维护依赖、插件、模块和构建入口。" ;;
    application*.yml|application*.yaml|bootstrap*.yml|bootstrap*.yaml|src/main/resources/application*.yml|src/main/resources/application*.yaml|src/main/resources/bootstrap*.yml|src/main/resources/bootstrap*.yaml) echo "后端运行配置，维护环境参数、数据源、中间件、服务发现和安全配置。" ;;
    Dockerfile|docker-compose*.yml|docker-compose*.yaml) echo "容器化或本地编排配置，维护镜像构建、依赖服务和运行参数。" ;;
    scripts/aw) echo "统一 CLI 路由入口，分发 init、dsl、plan、task、req、bug、tp、index 等子命令。" ;;
    scripts/_aw-lib.sh) echo "共享基础函数：仓库根目录、模板目录、复制、工程师索引刷新等。" ;;
    scripts/_aw-task-lib.sh) echo "任务和工作流共享函数：解析 DSL/Plan/ATOMIC、任务状态、需求确认记录。" ;;
    scripts/_aw-verify-lib.sh) echo "验证共享函数：解析 Verify 单元、TP 引用、PROJECT_CONFIG 命令。" ;;
    scripts/_aw-bug-lib.sh) echo "Bug 流水共享函数：创建和追加 docs/handoff/AI_BUG_LOG.md。" ;;
    scripts/init-project.sh) echo "初始化业务仓 reference、docs、模板、配置、FILE_INDEX、Bug 流水等基础文件。" ;;
    scripts/generate-engineering-index.sh) echo "生成 ENGINEERING_INDEX.md，人类工程师交付路径聚合索引。" ;;
    scripts/generate-file-index.sh) echo "生成 docs/FILE_INDEX.md，面向工程师手动优化代码的项目代码文件索引。" ;;
    scripts/aw-compact.sh) echo "一键工程化上下文压缩：写 handoff、自动快照、新会话粘贴块和可选聊天 Memory。" ;;
    scripts/aw-task.sh) echo "AT-T 子任务生命周期：brief、confirm、start、blocked、complete、done、paste。" ;;
    scripts/aw-req.sh) echo "统一需求入口：口述新增和研发中变更记录到 REQ，并回写 DSL/Plan/ATOMIC。" ;;
    scripts/aw-bug.sh) echo "Bug / 疑似 Bug 记录入口，统一写入 AI_BUG_LOG。" ;;
    scripts/aw-tp.sh) echo "测试计划管理：list、show、new、link 到 AT-T Verify 列。" ;;
    scripts/aw-verify.sh) echo "执行任务 Verify、PROJECT_CONFIG lint/format/typecheck/test/build/e2e。" ;;
    scripts/aw-confirm.sh) echo "任务确认入口：校验 DSL 已审、Plan 可执行并生成确认态和工程师索引。" ;;
    scripts/aw-dsl-apply.sh) echo "将生成的 DSL 落盘到 docs/dsl 并触发索引刷新。" ;;
    scripts/aw-dsl-suite.sh) echo "创建多文件 DSL 套件，覆盖需求、页面、交互、事件、边界、验收。" ;;
    scripts/aw-dsl-review.sh) echo "生成 DSL 工程师审阅包，支持单文件 DSL 和 DSL suite。" ;;
    scripts/aw-plan-apply.sh) echo "将 Plan 与 ATOMIC_TASKS 落盘到 docs/plans 并触发索引刷新。" ;;
    scripts/aw-plan-change.sh) echo "研发中计划变更助手：记录 plan change、追加 AT-T、拆分过大任务并自动审计。" ;;
    scripts/draft-dsl.sh) echo "输出 DSL 生成提示，按 reference/manifest 路径模式组织上下文。" ;;
    scripts/draft-plan.sh) echo "输出 Plan + ATOMIC 生成提示，支持前端/后端等 domain 定向拆分。" ;;
    scripts/check-aw-all.sh) echo "聚合检查入口，串联 layout、dsl、plan、config、rules、req、tp、plugin、memory。" ;;
    scripts/check-aw-layout.sh) echo "检查 agent-workflow 基础目录和关键文件是否存在。" ;;
    scripts/check-docs-commands.sh) echo "检查核心 CLI 命令是否在 skill/reference 与 INVOCATION 中有文档。" ;;
    scripts/check-skill-package.sh) echo "检查打包后的 skill 目录结构、脚本路由和文档能力是否完整。" ;;
    scripts/check-skill-source.sh) echo "检查源码仓 skill 文件、模板、plugin metadata 和版本一致性。" ;;
    scripts/e2e-smoke.sh) echo "端到端冒烟测试：打包、安装、init、DSL/Plan、任务、REQ、Bug、TP、索引刷新。" ;;
    scripts/build-skill-archive.sh) echo "构建 dist/agent-workflow-skill-*.tar.gz 并运行包检查。" ;;
    scripts/sync-skill.sh) echo "同步源码到 Cursor skill 目录和 dist/stage 包目录，可选生成旧版 aw-delivery 别名。" ;;
    scripts/aw-install.sh) echo "将 agent-workflow 包和 scripts 安装到目标业务仓。" ;;
    scripts/aw-upgrade.sh) echo "升级目标仓中的 agent-workflow 包和脚本；--from-github 会重装本机 skill 并替换当前项目。" ;;
    scripts/aw-remove.sh) echo "干运行或执行移除 adapters、CI、package 等安装产物。" ;;
    scripts/aw-status.sh) echo "展示当前 DSL、Plan、confirm、当前任务和建议下一步，支持 JSON。" ;;
    scripts/aw-dashboard.sh) echo "只读终端 dashboard，汇总状态、能力和机器可读入口。" ;;
    scripts/aw-capabilities.sh) echo "输出 CLI 能力摘要和 proof paths，支持 JSON。" ;;
    scripts/aw-config.sh) echo "初始化和更新 docs/PROJECT_CONFIG.md 的技术栈与验证命令。" ;;
    scripts/aw-rules.sh) echo "生成、审阅、检查 docs/ENGINEERING_RULES.md。" ;;
    scripts/aw-memory.sh) echo "文件化记忆系统：init、add、list、search、show、archive、inject。" ;;
    scripts/aw-demo.sh) echo "在临时目录演示完整 agent-workflow 工作流。" ;;
    scripts/aw-doctor.sh) echo "诊断安装、配置、adapter、CI、工作流状态和聚合检查。" ;;
    scripts/aw-setup.sh) echo "一键 setup：install/init/adapters/ci/status/doctor 组合流程。" ;;
    scripts/aw-commit.sh) echo "提交助手：默认先 verify，再建议或执行 commit message。" ;;
    scripts/aw-changelog.sh) echo "版本记录助手：向 CHANGELOG [Unreleased] 写入可追溯变更条目并检查结构。" ;;
    scripts/aw-audit.sh) echo "Agent 执行审计助手：记录任务、动作、决策、命令、结果、证据和人工确认点。" ;;
    scripts/aw-policy.sh) echo "Policy-as-Code 助手：初始化策略文件、记录策略例外和审批决策、检查策略结构。" ;;
    scripts/aw-security.sh) echo "安全与依赖准入助手：记录安全发现和新依赖评审结论。" ;;
    scripts/aw-service-catalog.sh) echo "服务目录助手：维护 docs/SERVICE_CATALOG.md 的服务/模块级交接信息。" ;;
    scripts/aw-release.sh) echo "发布闭环助手：维护环境、发布记录、回滚计划、Feature Flag 台账和发布门禁。" ;;
    scripts/aw-metrics.sh) echo "交付度量助手：记录 DORA / Flow 指标，包括部署、变更、失败和恢复。" ;;
    scripts/aw-ops.sh) echo "可靠性助手：维护 SLO、Incident 和 Runbook 记录。" ;;
    scripts/aw-agents.sh) echo "多 Agent 协作助手：登记长期 Agent 身份，记录角色分配、交接和评审结论。" ;;
    scripts/aw-sync.sh) echo "跨项目同步助手：通过共享 Harness 目录同步前后端 Agent 的 DSL、Plan、REQ、Handoff、Bug 和协作快照。" ;;
    scripts/aw-ci.sh) echo "安装 GitHub Actions workflow 模板。" ;;
    scripts/aw-atomic.sh) echo "多 ATOMIC_TASKS 文件的 list/use 选择器。" ;;
    scripts/aw-dsl-select.sh) echo "多 DSL 文件的 list/use 选择器。" ;;
    scripts/aw-plan-select.sh) echo "多 Plan 文件的 list/use 选择器。" ;;
    scripts/aw-next.sh) echo "输出下一条满足依赖的 AT-T，并引导 brief/confirm/start。" ;;
    scripts/aw-approve.sh) echo "DSL/Plan 审批落章：设置已审/可执行，并可触发 Plan 提示。" ;;
    scripts/check-dsl.sh) echo "校验 DSL 元数据、关联 REQ、manifest 路径和 suite 完整性。" ;;
    scripts/check-plan.sh) echo "校验 Plan 状态、关联 DSL/REQ、ATOMIC 任务和 TP 引用。" ;;
    scripts/check-project-config.sh) echo "检查 PROJECT_CONFIG 技术栈和验证命令是否填写。" ;;
    scripts/check-req-index.sh) echo "检查 REQ 文件、需求类型和 INDEX 反向链接。" ;;
    scripts/check-test-plan-index.sh) echo "检查 TP 文件与测试计划索引一致性。" ;;
    scripts/check-memory.sh) echo "检查 docs/memory 布局和记忆索引。" ;;
    scripts/check-plugin-metadata.sh) echo "检查 Codex plugin 和 marketplace metadata。" ;;
    scripts/check-dsl-business-gate.sh) echo "提交前业务代码闸门：DSL 未已审时阻止业务路径变更。" ;;
    scripts/pre-commit-verify.sh) echo "pre-commit 聚合验证脚本。" ;;
    scripts/commit-gate.sh) echo "提交门禁：运行 pre-commit-verify 并处理 open Bug 流水策略。" ;;
    scripts/install-git-hooks.sh) echo "安装仓库 .githooks。" ;;
    scripts/install-aw-adapters.sh) echo "安装 Claude/Codex/Copilot/Cursor/Windsurf/Cline/Continue 适配规则。" ;;
    scripts/install-cursor-skill.sh) echo "安装构建产物到 Cursor skill 目录。" ;;
    scripts/new-req.sh) echo "兼容旧入口：新建 REQ 文件并更新需求索引。" ;;
    scripts/new-test-plan.sh) echo "新建 TP 测试计划文件并更新 TP 索引。" ;;
    scripts/draft-handoff.sh) echo "生成 PROJECT_HANDOFF 更新草稿。" ;;
    skill/SKILL.md) echo "Codex skill 主说明和触发后的核心工作流。" ;;
    skill/QUICKSTART.md) echo "skill 快速开始命令序列。" ;;
    skill/reference.md) echo "skill 详细 CLI 参考和边界说明。" ;;
    skill/VERSION|agent-workflow/VERSION) echo "agent-workflow / skill 版本号。" ;;
    .codex-plugin/plugin.json) echo "Codex plugin manifest。" ;;
    .agents/plugins/marketplace.json) echo "插件市场本地入口配置。" ;;
    agent-workflow/INVOCATION.md) echo "工具无关调用入口和命令速查。" ;;
    agent-workflow/AGENTWORKFLOW_MANUAL.html) echo "暗色本地 HTML 使用手册，包含完整功能流程图、工程师与 Agent 使用说明、命令和对话模板。" ;;
    agent-workflow/AICODING_WORKFLOW.md) echo "AI 编码阶段 A-E、验证闭环、需求/交接存档规则。" ;;
    agent-workflow/PRODUCT_INPUT_WORKFLOW.md) echo "Reference → DSL → Plan → confirm 的阶段 0 输入流程。" ;;
    agent-workflow/CROSS_PROJECT_SYNC.md) echo "前后端分仓 / 两个项目的 Agent 同步教程，说明 aw sync 的共享 Harness、push/pull 和 inbox 边界。" ;;
    agent-workflow/AGENT_RULES.md) echo "可复制到 IDE/Agent 的精简执行规则。" ;;
    agent-workflow/CLAUDE.md) echo "Claude/Agent 兼容的仓库级工作流说明。" ;;
    agent-workflow/REPOSITORY.md) echo "包内文档导航和仓库真源说明。" ;;
    agent-workflow/INDEX.md) echo "agent-workflow 包文件索引。" ;;
    agent-workflow/CHANGELOG.md) echo "agent-workflow 变更记录。" ;;
    agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md) echo "版本、CHANGELOG、Bug、测试复测闭环规范。" ;;
    agent-workflow/templates/SERVICE_CATALOG.md|docs/SERVICE_CATALOG.md) echo "服务/模块级目录，记录 owner、入口、API、数据、依赖、验证、部署和告警入口。" ;;
    agent-workflow/templates/audit/*|docs/audit/*) echo "Agent 执行审计模板或流水，记录关键动作、命令、结果和确认点。" ;;
    agent-workflow/templates/policy/*|docs/policy/*) echo "Policy-as-Code 策略和例外审批记录。" ;;
    agent-workflow/templates/security/*|docs/security/*) echo "安全发现与依赖准入记录。" ;;
    agent-workflow/templates/release/*|docs/release/*) echo "环境、发布、回滚和 Feature Flag 记录。" ;;
    agent-workflow/templates/metrics/*|docs/metrics/*) echo "DORA / Flow 交付度量模板或记录。" ;;
    agent-workflow/templates/ops/*|docs/ops/*) echo "SLO、Incident、Runbook 可靠性模板或记录。" ;;
    agent-workflow/templates/agents/AGENT_REGISTRY.md|docs/agents/AGENT_REGISTRY.md) echo "长期 Agent 身份登记表，记录 worker identity、职责、边界和状态。" ;;
    agent-workflow/templates/agents/AGENT_PRESETS.tsv|docs/agents/AGENT_PRESETS.tsv) echo "默认 Agent 注册预设配置，供 aw agents register --preset/--defaults 使用。" ;;
    agent-workflow/templates/agents/*|docs/agents/*) echo "多 Agent 角色、交接和评审模板或记录。" ;;
    docs/sync/SYNC_CONFIG.md) echo "跨项目前后端同步配置，记录共享 Harness、项目名、Agent 和角色。" ;;
    docs/sync/README.md) echo "跨项目同步目录说明，解释 inbox/outbox 的只读边界。" ;;
    docs/sync/inbox/*|docs/sync/inbox/*/*) echo "从其他项目拉取的只读同步快照，用于前后端 Agent 协调。" ;;
    docs/sync/outbox/*|docs/sync/outbox/*/*) echo "本项目最近一次发布到共享 Harness 的同步快照副本。" ;;
    agent-workflow/templates/ENGINEERING_INDEX.header.md) echo "ENGINEERING_INDEX.md 生成模板。" ;;
    docs/FILE_INDEX.md) echo "本文件：项目代码文件索引，供人类工程师定位代码文件、理解职责和手动优化。" ;;
    docs/PROJECT_CONFIG.md) echo "项目技术栈、包管理器和验证命令配置。" ;;
    docs/ENGINEERING_RULES.md) echo "项目工程规范实例文件。" ;;
    docs/requirements/INDEX.md) echo "统一需求表，按需求类型区分口述新增和研发中变更。" ;;
    docs/handoff/AI_BUG_LOG.md) echo "Bug / 测试失败 / 反馈问题流水。" ;;
    docs/handoff/PROJECT_HANDOFF.md) echo "当前进度、目标、风险和下一步交接快照。" ;;
    docs/memory/INDEX.md) echo "跨会话记忆索引。" ;;
    README.md) echo "仓库根 README，能力总览和入口。" ;;
    AGENTS.md|CLAUDE.md|AGENT_RULES.md) echo "仓库根 Agent 入口规则。" ;;
    SECURITY.md|agent-workflow/SECURITY.md) echo "安全报告和安全策略说明。" ;;
    PUBLISH.md) echo "发布和打包说明。" ;;
    LICENSE) echo "许可证文件。" ;;
    .github/workflows/*) echo "GitHub Actions workflow。" ;;
    .github/ISSUE_TEMPLATE/*) echo "GitHub Issue 模板。" ;;
    .github/pull_request_template.md) echo "Pull Request 模板。" ;;
    .githooks/*) echo "Git hook 脚本。" ;;
    agent-workflow/adapters/codex-context/README.md) echo "Codex 新会话连续性说明：Handoff、Memory、Chat Memory 与原生上下文压缩边界。" ;;
    agent-workflow/adapters/*) echo "IDE / Agent 适配说明：$(basename "$f" .md)。" ;;
    agent-workflow/templates/dsl/*|docs/dsl/*) echo "DSL 模板或示例文件：${b}。" ;;
    agent-workflow/templates/plans/*|docs/plans/*) echo "Plan / ATOMIC_TASKS 模板或说明：${b}。" ;;
    agent-workflow/templates/quality/test-plans/*|docs/quality/test-plans/*) echo "测试计划模板或索引：${b}。" ;;
    agent-workflow/templates/memory/*|docs/memory/*) echo "记忆系统模板或说明：${b}。" ;;
    agent-workflow/templates/rules/*) echo "工程规范模板：${b}。" ;;
    agent-workflow/templates/prompts/*) echo "生成提示模板：${b}。" ;;
    reference/*) echo "参考材料目录说明或 manifest 示例。" ;;
    *.md) echo "项目 Markdown 文档：${b}。" ;;
    *.json) echo "项目 JSON 配置：${b}。" ;;
    *.yml|*.yaml) echo "项目 YAML 配置：${b}。" ;;
    *) echo "项目文件：${b}。" ;;
  esac
}

include_file() {
  local f="$1"
  case "$f" in
    dist/*|build/*|coverage/*|node_modules/*|target/*|.next/*|.nuxt/*|.vite/*|.git/*|*.DS_Store|ENGINEERING_INDEX.md) return 1 ;;
    *.png|*.jpg|*.jpeg|*.gif|*.webp|*.ico|*.svg|*.pdf|*.zip|*.tar|*.gz|*.jar|*.class|*.map) return 1 ;;
    docs/FILE_INDEX.md) return 0 ;;
    src/*|app/*|apps/*|packages/*|modules/*|frontend/*|backend/*|web/*|server/*|service/*|services/*|shared/*|common/*|lib/*|libs/*|internal/*|cmd/*|pkg/*|test/*|tests/*|__tests__/*|cypress/*|e2e/*) return 0 ;;
    package.json|pnpm-lock.yaml|package-lock.json|yarn.lock|vite.config.*|vue.config.*|tsconfig*.json|jsconfig*.json|eslint.config.*|.eslintrc*|prettier.config.*|.prettierrc*|tailwind.config.*|postcss.config.*|Dockerfile|docker-compose*.yml|docker-compose*.yaml|pom.xml|build.gradle|settings.gradle|gradle.properties|mvnw|gradlew|application*.yml|application*.yaml|bootstrap*.yml|bootstrap*.yaml) return 0 ;;
    scripts/*|skill/*|agent-workflow/*|agent-workflow/adapters/*/*|docs/*|reference/*|.github/*|.githooks/*|.codex-plugin/*|.agents/*|README.md|AGENTS.md|AGENT_RULES.md|CLAUDE.md|SECURITY.md|PUBLISH.md|LICENSE) return 0 ;;
    *) return 1 ;;
  esac
}

list_files() {
  if command -v rg >/dev/null 2>&1; then
    rg --files \
      -g '!dist/**' \
      -g '!build/**' \
      -g '!coverage/**' \
      -g '!node_modules/**' \
      -g '!target/**' \
      -g '!.next/**' \
      -g '!.nuxt/**' \
      -g '!.vite/**' \
      -g '!ENGINEERING_INDEX.md' \
      -g '!*.DS_Store' \
      "$ROOT"
  else
    find "$ROOT" -type f \
      ! -path '*/dist/*' \
      ! -path '*/build/*' \
      ! -path '*/coverage/*' \
      ! -path '*/node_modules/*' \
      ! -path '*/target/*' \
      ! -path '*/.next/*' \
      ! -path '*/.nuxt/*' \
      ! -path '*/.vite/*' \
      ! -name 'ENGINEERING_INDEX.md' \
      ! -name '*.DS_Store'
  fi | sed "s#^${ROOT}/##" | sort
}

emit_table() {
  local cat="$1" f any=false
  echo "## ${cat}"
  echo ""
  echo "| 路径 | 说明 | 维护提示 |"
  echo "|------|------|----------|"
  while IFS= read -r f; do
    include_file "$f" || continue
    [[ "$(category_of "$f")" == "$cat" ]] || continue
    any=true
    printf '| `%s` | %s | %s |\n' "$f" "$(desc_of "$f")" "$(maintain_hint "$f")"
  done < "$TMP_FILES"
  $any || echo "| — | 暂无 | — |"
  echo ""
}

maintain_hint() {
  local f="$1"
  case "$f" in
    scripts/*) echo "改 CLI 行为时同步更新 help、reference、e2e。" ;;
    skill/*) echo "改能力或命令后同步 skill 文档和包检查。" ;;
    agent-workflow/templates/*) echo "改模板后同步 init/e2e 和生成产物预期。" ;;
    agent-workflow/*) echo "改流程规则后同步 AGENT_RULES、INVOCATION、skill 引用。" ;;
    docs/dsl/*|docs/plans/*|docs/requirements/*) echo "作为业务真源变更时同步相关 REQ/DSL/Plan/ATOMIC。" ;;
    docs/handoff/*|docs/memory/*|docs/sync/*) echo "更新交接、记忆或同步快照时保持来源、时间和范围清楚。" ;;
    .github/*|.githooks/*) echo "改门禁后同步本地/CI 验证说明。" ;;
    *) echo "变更后按影响范围同步索引、文档和验证。" ;;
  esac
}

TMP_FILES="$(mktemp)"
trap 'rm -f "$TMP_FILES"' EXIT
mkdir -p "${ROOT}/docs"
list_files > "$TMP_FILES"

{
  echo "# FILE_INDEX（项目代码文件索引）"
  echo ""
  echo "> 读者：人类工程师。用途是在 AI 代写或修改代码后，快速定位真实项目代码文件，理解每个文件职责，方便人工审查、手动优化和接手维护。"
  echo ""
  echo "## 维护规则"
  echo ""
  echo "- 本文件由 \`./scripts/aw file-index\` 或 \`./scripts/generate-file-index.sh\` 生成。"
  echo "- 新增 / 删除 / 重命名前端、后端、共享、测试或配置代码文件后，运行 \`./scripts/aw file-index\`。"
  echo "- 优先查看「前端业务代码 / 后端业务代码 / 共享代码 / 测试代码 / 运行配置」；脚本、模板、工作流文档只是辅助索引。"
  echo "- 本文件供人类工程师定位代码和手改点，不替代代码真源、DSL、Plan、REQ、测试计划或 Bug 流水。"
  echo "- 生成时间：$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo ""
  for cat in \
    "前端业务代码" \
    "后端业务代码" \
    "共享 / 通用代码" \
    "测试代码" \
    "运行配置 / 构建配置" \
    "CLI / 脚本代码" \
    "Skill / 插件包" \
    "工作流包文档" \
    "模板文件" \
    "IDE / Agent 适配" \
    "项目工作流文档" \
    "CI / Git Hooks" \
    "仓库入口 / 配置" \
    "参考材料入口" \
    "其他项目文件"; do
    emit_table "$cat"
  done
} > "$OUT"

echo "Wrote: docs/FILE_INDEX.md"
