# agent-workflow — 参考

## 工具无关原则

- **真源：** `agent-workflow/INVOCATION.md`（`aw install` 后位于业务仓）
- **CLI：** `scripts/aw` — 所有 IDE 共用
- **Skill：** 仅 Cursor 可选；Windsurf/Cline/Codex 等用各自规则文件

## 编码原则

| 原则 | 防止的问题 |
|------|------------|
| 编码前思考 | 错误假设、隐藏困惑、缺少权衡 |
| 简洁优先 | 过度复杂、臃肿抽象、过早设计 |
| 成熟方案优先 | 脆弱手写实现、重复造轮子、维护成本高 |
| 精准修改 | 无关编辑、意外重构、噪声 diff |
| 目标驱动执行 | 验收不清、没有验证、口头完成 |
| 闭环管理 | 完整性、可追溯性、可维护性、可交接性缺证据 |

详版见业务仓 `agent-workflow/AICODING_WORKFLOW.md` 阶段 A-E。

前后端分成两个项目时，先读业务仓 `agent-workflow/CROSS_PROJECT_SYNC.md`。`aw sync pull` 只把对方快照导入 `docs/sync/inbox/` 供只读参考；接口或需求变化要在本项目重新落 REQ / Bug / Handoff 后再 `aw sync push`。

## 闭环管理

每个大需求 / AT-T 进入下一项前，必须确认：

| 目标 | 证据 |
|------|------|
| 完整性 | REQ / DSL / Plan / ATOMIC / TP 覆盖需求、页面、交互、事件、联动边界、验收、非目标 |
| 可追溯性 | 代码、Bug、测试、CHANGELOG、Git 提交可反查到 REQ / DSL / Plan / AT-T |
| 可维护性 | 工程规范、成熟方案选择、必要注释、测试、`docs/FILE_INDEX.md` 与实现同步 |
| 可交接性 | Handoff / Memory / 验证证据 / 风险 / 下一步 / 提交状态可供新会话或工程师接手 |

## 适配器安装

```bash
./scripts/aw adapters --all
```

| 标志 | 生成文件 |
|------|----------|
| `--claude` | `CLAUDE.md` |
| `--codex` | `AGENTS.md` |
| `--copilot` | `.github/copilot-instructions.md` |
| `--cursor` | `.cursor/rules/agent-workflow.mdc` |
| `--windsurf` | `.windsurfrules` |
| `--cline` | `.clinerules` |
| `--continue` | `.continue/rules/agent-workflow.md` |

详见业务仓 `agent-workflow/adapters/README.md`。

## Skill 安装

```bash
# 本地源码
./scripts/install-cursor-skill.sh /path/to/agentworkflow

# 远程仓库
./scripts/install-cursor-skill.sh https://github.com/<you>/agentworkflow.git

# 指定 tag/branch
AW_SKILL_REF=v1.1.0 ./scripts/install-cursor-skill.sh https://github.com/<you>/agentworkflow.git
```

安装后在业务仓执行：

```bash
~/.cursor/skills/agent-workflow/scripts/aw install . --adapters
```

## 常用检查

```bash
./scripts/aw status
./scripts/aw dashboard
./scripts/aw memory inject
./scripts/aw status --json
./scripts/aw capabilities
./scripts/aw capabilities --json
./scripts/aw demo
./scripts/aw check all
./scripts/aw check tp
```

`aw status` 会显示当前 DSL、Plan、confirm 状态，以及进行中的 AT-T（若已 `aw task start`）。

## Handoff vs Memory

`docs/FILE_INDEX.md` is the human-facing project code file index for manual code review and optimization. Generate it with `aw file-index`; it prioritizes frontend business code, backend business code, shared code, tests, and runtime/build configuration, with scripts/templates/workflow docs kept as auxiliary sections. Refresh it whenever project code files are added, deleted, or renamed so engineers can quickly locate AI-written files that need review or manual edits.

| 功能 | 存放 | 适合记录 | 不适合记录 |
|------|------|----------|------------|
| Handoff | `docs/handoff/PROJECT_HANDOFF.md` | 当前目标、阶段进度、阻塞、下一步、待确认 | 长期偏好、可复用模式、历史聊天全文 |
| Memory | `docs/memory/` | 稳定事实、已拍板决策、项目偏好、可复用流程、反复出现的风险、聊天摘要 | 临时状态、整段 handoff、完整逐字聊天、secret/token/password |

从 Handoff 提炼 Memory 的标准：未来 2 次以上任务可能复用；有明确来源；能用一句话说明。否则保留在 Handoff。

`aw compact "focus" --write --snapshot` 是 Codex / 新会话前的一键工程化上下文压缩：更新并检查 `PROJECT_HANDOFF.md`，生成 `docs/handoff/LAST_AUTO_SNAPSHOT.md` 和 `docs/handoff/PASTE_IN_NEW_CHAT.txt`。带 `--memory-summary "..."` 时，会同步写入聊天摘要 Memory。

`aw handoff "focus"` 会自动读取当前 DSL / Plan / ATOMIC / 任务 / REQ / Bug / 项目配置 / Git 状态并输出 handoff 草稿。审阅后可用 `aw handoff "focus" --write` 备份旧文件并覆盖 `docs/handoff/PROJECT_HANDOFF.md`；新开会话前用 `aw handoff --check` 检查必备章节、体积和疑似 secret。

当用户要求“记住这段聊天”时，用 `aw memory chat <slug> "标题" --summary "..." --decisions "..." --todos "..." --open "..." --related "..."` 记录聊天摘要。聊天里形成的正式需求仍用 `aw req new|change`，当前进度仍用 `aw handoff --write`。

## CLI 速查

| 命令 | 用途 |
|------|------|
| `aw install [path] --adapters` | 装入流程包与 IDE 入口 |
| `aw setup` | 一键执行 install/init/adapters/CI/status/doctor |
| `aw doctor` | 诊断安装、闸门、适配器、CI、配置 |
| `aw demo` | 在临时目录跑 install → init → DSL → Plan → confirm → task → TP → verify 演示 |
| `aw dashboard` | 只读终端视图，集中显示状态、能力和机器可读入口 |
| `aw status --json` | 机器可读状态，供 dashboard/plugin/自动化消费 |
| `aw capabilities` | 输出支持工具、核心命令和证明路径摘要 |
| `aw capabilities --json` | 机器可读能力摘要，供 dashboard/plugin/自动化消费 |
| `aw memory init|add|list|search|show|archive|inject` | 文件化跨会话记忆 |
| `aw memory chat <slug> "title" --summary "..."` | 记录聊天摘要记忆：背景、决定、待办、待确认和关联对象 |
| `aw upgrade` | 刷新 package/scripts，保留业务 docs/reference |
| `aw remove` | 预览移除 adapters/CI/package，`--execute` 后删除 |
| `aw init` | 初始化 reference、DSL、Plan、TP 模板 |
| `aw project scan` | 扫描当前项目内容，写入 `docs/PROJECT_SCAN.md`，给出全新 / 已有项目建议；Agent 必须复述给工程师确认 |
| `aw project gate` | Plan 前硬闸门：未扫描、未确认项目阶段 / 同步中心决策 / 类型 / 构建目标，或 fullstack 分仓未配置同步中心时阻断 |
| `aw config init --project-stage 1|2` | 选择启动分流：1=全新项目，2=已有 / 存量项目；未选择前不得生成 DSL / Plan 或写业务代码 |
| `aw dsl [A|B|C]` | 打印 DSL prompt |
| `aw dsl suite <slug> "title"` | 生成多文件 DSL 套件：需求、页面、交互、事件、联动边界、验收 |
| `aw dsl review [dsl] [--write]` | 输出/写入工程师 DSL 审阅包，通过后再 approve |
| `aw dsl apply --file DSL.md` | 校验并写入 `docs/dsl/` |
| `aw dsl list|use` | 多 DSL 仓库选择当前 DSL |
| `aw approve dsl <file> [--plan] [--domain frontend|backend|...]` | DSL 状态设为已审；`--plan` 直接输出 Plan/ATOMIC 生成提示；`--domain` 定向拆任务 |
| `aw plan <dsl> [--domain frontend|backend|...]` | 打印 Plan prompt，可只生成指定领域任务；会先执行 project gate |
| `aw plan apply --plan-file PLAN.md --atomic-file ATOMIC.md --slug name` | 写入 Plan 与 ATOMIC；会先执行 project gate |
| `aw plan list|use` | 多 Plan 仓库选择当前 Plan |
| `aw plan change --summary "..."` | 记录研发中计划变更，回写当前 Plan / ATOMIC 并自动审计 |
| `aw plan task-add --title "..."` | 在当前 ATOMIC 追加同范围新任务 |
| `aw approve plan <file>` | Plan 状态设为可执行 |
| `aw confirm <dsl> <plan>` | 任务确认并生成索引 |
| `aw req new <slug> "title" --type 口述新增|补充需求|约束规则` | 记录口述新增需求到统一需求表 |
| `aw req change <AT-T> "summary" --impact "..." --acceptance "..."` | 记录研发中需求变更到统一需求表，并回写 DSL / Plan / ATOMIC |
| `aw next` | 输出下一条 AT-T |
| `aw task brief <AT-T>` | 输出子任务开始前的需求沟通包 |
| `aw task confirm <AT-T> "已确认：范围=...；验收=...；非目标=..."` | 工程师确认需求已问清楚；摘要缺少范围 / 验收 / 非目标会被拒绝；未确认不能 `start` / `complete` |
| `aw task start|blocked|complete|done|show` | AT-T 生命周期 |
| `aw task blocked <AT-T>` | 标记任务阻塞 |
| `aw task split <AT-T> --into "A; B"` | 将过大的任务拆成后续 AT-T，并阻塞原任务 |
| `aw task complete <AT-T>` | 自动执行验证；通过标记已完成，失败写 `AI_BUG_LOG.md` 并保留进行中 |
| `aw paste task` | 单任务 Agent 提示块 |
| `aw verify --task <AT-T>` | 执行 Verify 列与 PROJECT_CONFIG |
| `aw verify --run-e2e` | 对 TP 项执行 e2e/playwright 命令 |
| `aw verify --task <AT-T> --run-e2e` | TP 关联项触发 PROJECT_CONFIG 的 e2e/playwright 命令 |
| `aw task checkpoint <AT-T> --git yes|no --reason "..." --handoff --compact --file-index` | 完成任务后的硬检查点：记录 Git 决策、交接/压缩、FILE_INDEX 刷新状态 |
| `aw compact "focus" --write --snapshot` | 一键上下文压缩：写 handoff、自动快照、新会话粘贴块，可选 Memory |
| `aw handoff "focus"` | 生成当前上下文压缩草稿 |
| `aw handoff "focus" --write` | 备份并覆盖写入 `docs/handoff/PROJECT_HANDOFF.md` |
| `aw handoff --check` | 检查交接快照是否具备关键章节、无明显 secret、未塞入工程索引正文 |
| `aw tp new|link|show|list` | 测试计划管理 |
| `aw bug add "summary" --source chat|test|review|runtime|prod --scope <scope>` | 记录所有 Bug / 疑似 Bug |
| `aw bug list|path` | 查看 Bug 流水或输出路径 |
| `aw changelog add --type Changed --message "..."` | 写入 `[Unreleased]` 版本记录，保证提交前有可追溯变更说明 |
| `aw changelog check` | 检查 CHANGELOG 是否存在 `[Unreleased]` |
| `aw audit init|add|check` | 记录 AI 执行审计：任务、动作、决策、命令、结果、证据、人工确认 |
| `aw policy init|decision|check|diff|gate` | 初始化和检查 Policy-as-Code，记录高风险变更 / 例外审批；`gate --strict` 可强制阻断高风险 diff |
| `aw policy gate --strict` | 严格策略门禁：高风险路径或依赖清单变化必须先有 policy/security 记录 |
| `aw security init|finding|dependency|check` | 记录安全发现和新依赖准入评审 |
| `aw security scan [--run]` | 检测可用 secret/SCA/SAST 工具；默认只建议命令，`--run` 执行已安装扫描器 |
| `aw service-catalog init|add|check` | 维护服务/模块级目录，覆盖 owner、API、数据、依赖、部署和告警入口 |
| `aw service-catalog discover [--write]` | 扫描常见服务/模块入口，并提示入口、API 路由、数据/存储、依赖清单、端口/脚本、日志/观测候选 |
| `aw release init|record|flag|check` | 维护环境、发布记录、回滚方案、Feature Flag 和发布验证 |
| `aw release gate [--run-verify] [--run-security] [--strict-policy] [--strict-report]` | 发布前聚合检查：CHANGELOG、Policy、Security、Service Catalog、环境、Ops、Agents、Metrics、报告门禁和可选验证/安全扫描 |
| `aw release gate --strict-report` | 严格发布报告门禁：要求最近 release 报告存在并包含 release gate、trace、metrics、service discovery 等关键快照 |
| `aw release flag-check` | 检查 Feature Flag 是否有清理计划 |
| `aw report handoff [--write]` | 生成工程师交接报告，汇总 workflow、REQ、Bug、Changelog、Release、Metrics、Ops、Agents、Trace |
| `aw report release [--write]` | 生成发布审查报告，包含 release gate、trace check、metrics summary 和服务发现快照 |
| `aw report check [--strict]` | 检查最近交接 / 发布报告是否存在且包含关键章节；`--strict` 可作为交接 / 发布阻断门禁 |
| `aw metrics init|record|summary|check` | 记录 DORA / Flow 指标，并输出交付健康摘要 |
| `aw metrics summary` | 汇总 records、deployments、production deployments、failures、recoveries，用于发布 / 交接判断 |
| `aw ops init|slo|incident|incident-close|runbook|gate|check` | 记录 SLO、事故、恢复闭环和 Runbook；发布/交接前可运行 ops gate |
| `aw ops gate` | 检查是否存在未关闭的 sev1 / sev2 事故；存在时阻断发布 / 交接 |
| `aw agents init|assign|handoff|review|gate|check` | 记录多 Agent 角色、文件边界、交接和评审结论；gate 检查阻断评审 |
| `aw agents claim|heartbeat|release|lock-check` | 多 Agent 任务锁和状态心跳，防止并行修改冲突和任务无人负责 |
| `aw agents gate` | 检查 block 评审、未确认文件边界、多个 Agent allowed paths 重叠；默认 warn |
| `aw agents gate --strict` | 严格协作门禁：发现 allowed paths 重叠时阻断，要求先 handoff 或重新分配边界 |
| `aw gate init|check|pre-commit|task|pr|release` | 自动 Gate 聚合 DSL、REQ、TP、Contract、Agent 锁、Trace、Score、Release 等关键检查 |
| `aw gate file-index` | 新增 / 删除 / 重命名业务文件时，若未刷新 `docs/FILE_INDEX.md` 则阻断 |
| `aw context init|status|plan|query|impact|affected|gate|budget` | 任务级代码上下文控制：禁止无目标全仓扫描，按 CodeGraph / CODE_CONTEXT_INDEX / FILE_INDEX 生成最小读取范围和 affected 分析 |
| `aw context enrich --task <AT-T>` | 自动用 CodeGraph / 精准 rg / 索引补全 Context Plan 的 Symbol 和影响范围 |
| `aw verify --affected --task <AT-T>` | 先写入 affected analysis，再执行任务验证 |
| `aw contract init|change|test|diff|gate|check` | 前后端契约系统：OpenAPI、API 变更、Mock、Contract Test、Schema Diff、破坏性变更阻断 |
| `aw contract diff --write|breaking-check|sync` | 自动记录 OpenAPI diff、检测破坏性变更候选，并向同步中心发布契约事件 |
| `aw vcs init|branch|fill|create|review|gate|check` / `aw vcs gate` | 多代码仓库 PR/MR/CR 闭环：GitHub、GitLab、Bitbucket、Gitee、GitCode、Gitea、Forgejo、GitLab CE、Gerrit、Codeup |
| `aw github-pr ...` | 兼容旧入口，内部转发到 `aw vcs` |
| `aw score init|record|check|latest` | 交付评分：需求、DSL/Plan、任务确认、验证、Bug、文件索引、Contract、Git/Release、Handoff |
| `aw recover init|context|plan|sync|failed-task|conflict|rollback|check` | 恢复机制：上下文断裂、计划过期、同步漂移、任务失败、冲突和回滚 |
| `aw watch index [--once|--loop]` | 自动刷新 FILE_INDEX / ENGINEERING_INDEX，并输出 affected analysis 提示 |
| `aw sync init <harness-dir> --project <name> --agent <name>` | 为前后端分仓项目配置共享同步中心 |
| `aw sync pull [--from <project|all>]` | 将其他项目快照拉到 `docs/sync/inbox/` 供只读参考，不覆盖本项目 DSL / Plan / 代码 |
| `aw sync gate --task <AT-T>` | 双项目 / 分仓任务开始前硬检查：最近已 pull、inbox 存在、共享任务看板存在 |
| `aw sync push [--task AT-T...]` | 将本项目 DSL / Plan / REQ / Handoff / Agents / Bug / TP / Security 等快照发布到同步中心 |
| `aw sync baseline` | 显示并初始化同步中心 `global/dsl/`、`global/plans/`、`global/contracts/` 共享基线路径 |
| `aw sync board` | 从已 push 的前后端 ATOMIC 快照生成 / 查看 `global/plans/TASK_BOARD.md` 共享任务看板 |
| `aw sync event --type complete|change|block|question|contract|bug|decision|handoff --task <AT-T> --to <agent> --summary "..."` | 通用跨端同步事件：按类型写本地流水 / handoff / push / board，并输出 Harness Git 提交建议 |
| `aw sync change <AT-T> "summary" --to <agent> --impact "..." --acceptance "..."` | 跨端需求变更编排：本项目 REQ 回写、Agent handoff、sync push、board 刷新，并输出 Harness Git 提交建议 |
| `aw sync inbox [--from <project|all>]` | 汇总已 pull 到本项目 inbox 的对方 manifest 和 sync events，方便采纳 |
| `aw sync status|check` | 查看或校验跨项目同步配置和快照状态 |
| `aw trace check` | 检查 REQ、DSL、Plan、AT-T、TP、Bug、Changelog、Audit、Policy、Security、Release、Metrics、Ops、Agents 的追溯链 |
| `aw index` | 仅扫描刷新 `ENGINEERING_INDEX.md`；写入 REQ / Bug / TP / DSL / Plan 时自动触发 |
| `aw file-index` | 生成 `docs/FILE_INDEX.md`，代码优先覆盖前端、后端、共享、测试和运行配置文件，脚本/模板/文档作为辅助索引 |
| `aw check all|dsl|plan|config|req|tp|plugin` | 分项或聚合检查 |
| `aw check plugin` | 校验 Codex plugin / marketplace metadata |
| `aw check memory` | 校验 docs/memory 布局、字段与敏感信息 |
| `aw config init --project-stage 1|2 --sync-center 1|2|3 --project-kind <n> --repo-url <url> --build-target 1|2|3` | 填写 PROJECT_CONFIG；项目阶段必须先依据 `aw project scan` 和工程师确认；启动接入时必须询问是否建立同步中心，1=建立/使用、2=不建立、3=稍后决定且 Plan 阻断；代码托管平台支持 1=GitHub、2=本地 Git、3=GitLab、4=Bitbucket、5=Gitee、6=GitCode、7=Gitea、8=Forgejo、9=GitLab CE、10=Gerrit、11=云效 Codeup；构建目标 3=前后端时，分仓/双项目必须先 `aw sync init` 建同步中心 |
| `aw rules init|review|check` | 生成、审阅、校验工程规范 `docs/ENGINEERING_RULES.md`；默认固化团队前端/后端/统一 AI 执行规范清单，真实项目只补差异、关键文件和注释原则 |
| `aw rules discover [--write]` | 扫描真实项目候选关键文件，并可回写 `docs/ENGINEERING_RULES.md` 的“关键文件”表 |
| `aw ci install` | 安装 GitHub Actions workflow 模板 |
| `aw commit [-m] [--changelog "..."]` | verify + 可选写入 CHANGELOG + 提交信息建议；大需求 / AT-T 完成后先询问工程师是否提交当前分支 |

## 流程与闸门

见 `PRODUCT_INPUT_WORKFLOW.md` · DSL **已审** 前不写业务代码 · `confirm` 须 DSL + Plan。
