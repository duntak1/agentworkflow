# 调用说明（工具无关 · 真源）

**本文件与 `scripts/*.sh` 适用于任意 AI 编码工具**（Claude Code、OpenAI Codex、GitHub Copilot、Cursor、Windsurf、Cline、Continue、网页对话等）。  
工具专属挂载见 [`adapters/README.md`](./adapters/README.md) — **仅指针，不替代本文流程。**

```bash
./scripts/aw install . --adapters   # 推荐：装入包 + 各 IDE 入口文件
./scripts/aw adapters --all         # 已 install 后补装适配器
```

---

## 一句话流程

```text
启动 aw / @aw → 询问工程师角色（1 产品 / 2 前端 / 3 后端 / 4 全栈）→ install/init → aw project scan 扫描项目内容 → 工程师确认项目阶段（全新 / 已有）→ 按角色和拓扑询问是否建立同步中心（建立 / 不建 / 稍后决定；全栈单仓可不建）→ 若 PM / 产品主导或三端协作，先 `aw pm start` + `aw pm init <project-harness>` 建立 PM 同步中心 → 选择代码托管平台（GitHub/GitLab/Bitbucket/Gitee/GitCode/Gitea/Forgejo/GitLab CE/Gerrit/云效 Codeup/本地 Git）+ 构建目标（前端/后端/前后端；全栈角色默认前后端在同一仓库）→ 若双项目则先确认真实前端仓库 / 后端仓库 / 同步中心并执行 aw sync init → 全新项目走 reference/PM references → DSL → Plan；已有项目走现状盘点 → 一期基线 → 增量 DSL → 增量 Plan；双项目/三端项目先共享 DSL / 协作 Plan / PM dispatch，再派生本地 Plan → DSL 已审 / Plan 可执行 → aw confirm → ENGINEERING_INDEX.md → aw next → AICODING 写代码 → verify → CHANGELOG/Git → handoff
```

## 闭环管理目标

每个大需求和每个 AT-T 完成前，必须能回答并留痕：

| 目标 | 必备证据 |
|------|----------|
| **完整性** | REQ / DSL / Plan / ATOMIC / 测试计划覆盖需求描述、页面结构、交互行为、事件、联动边界、验收和非目标 |
| **可追溯性** | 代码 diff 能追到 REQ / DSL / Plan / AT-T；Bug 进 `AI_BUG_LOG.md`；对外可见变更进 `CHANGELOG [Unreleased]`；按确认结果形成 Git 提交 |
| **可维护性** | `docs/ENGINEERING_RULES.md`、成熟方案选择、必要代码注释、测试、`docs/FILE_INDEX.md` 与实现保持一致 |
| **可交接性** | `docs/handoff/PROJECT_HANDOFF.md`、可复用 Memory、验证证据、遗留风险、下一步、提交/版本记录状态可供新会话或人类工程师接手 |

缺任一项时，不得口头宣布完成；要么补齐，要么在 REQ / Bug / Handoff 中写明例外、责任人和后续动作。

---

## Token 预算与分层读取

AgentWorkflow 默认采用 **先摘要、后展开**。Agent 不应把本手册、HTML 手册、同步中心、工程索引或整仓代码一次性塞进上下文。

| 阶段 | 默认只读 | 需要展开时 |
|------|----------|------------|
| 启动 | `aw start`、`aw status --json`、`aw project scan` 输出摘要 | 只有流程歧义时读取本文相关小节 |
| 新会话恢复 | `aw handoff --check`、`aw memory inject`、`aw status --json`、`aw next` | 只打开当前任务相关 handoff / memory 条目 |
| 生成 DSL | `reference/manifest.yaml`、本轮 REQ、被 manifest 点名的输入文件 | 大型参考材料先摘要成 REQ / DSL 分片，再逐片读取 |
| 生成 Plan | 已审 DSL 的 `INDEX.md` / 相关分片、本轮 REQ、Plan 模板 | 只读与本轮领域相关的 DSL 分片 |
| 研发任务 | `aw task brief <AT-T>`、`docs/context/tasks/CTX-<AT-T>.md` 白名单 | 超预算前说明原因并请求工程师确认 |
| 跨端同步 | `aw sync inbox --from <peer>` 摘要、`TASK_BOARD.md`、相关 event / contract | 不读取整个 `docs/sync/inbox` 或整个 `project-harness` |
| 人类索引 | 提示工程师查看 `ENGINEERING_INDEX.md` / `docs/FILE_INDEX.md` | Agent 不把 `ENGINEERING_INDEX.md` 作为上下文全文读取 |

默认研发任务预算：**6 个业务文件、12 个 symbol、3 次精准搜索**。超过预算必须先记录原因并得到工程师确认。禁止读取 `.git`、`node_modules`、`dist`、`build`、`coverage`、`.next`、`.nuxt`、`target`、`vendor`、`tmp`、`logs` 等目录。

---

## 统一 CLI（推荐）

在仓库根（已拷贝 `scripts/aw` 或 `scripts/aw.sh`）：

```bash
chmod +x scripts/aw scripts/*.sh
./scripts/aw install .    # 首次从源码仓装入目标库（可选）
./scripts/aw init
./scripts/aw project scan  # 必须先扫描项目内容，生成 docs/PROJECT_SCAN.md
./scripts/aw demo          # 可选：临时目录演示完整路径
./scripts/aw dashboard     # 可选：只读终端视图
./scripts/aw memory inject # 可选：跨会话记忆摘要
./scripts/aw status --json # 可选：机器可读状态
./scripts/aw capabilities --json # 可选：机器可读能力摘要
./scripts/aw config init --project-stage 1 # 1=全新项目；2=已有/存量项目；必须先依据 PROJECT_SCAN 和工程师确认
./scripts/aw config init --sync-center 1 --sync-center-path ../project-harness # 1=建立/使用；2=不建立；3=稍后决定且阻断 Plan
./scripts/aw config init --project-kind 1 --repo-url https://github.com/<owner>/<repo> # 1=GitHub
# 2=本地 Git，无需远程仓库地址；3=GitLab，4=Bitbucket，5=Gitee，6=GitCode，7=Gitea，8=Forgejo，9=GitLab CE，10=Gerrit，11=云效 Codeup
./scripts/aw config init --build-target 1 # 1=前端项目；2=后端项目；3=前后端项目
./scripts/aw rules init && ./scripts/aw rules discover --write && ./scripts/aw rules review # 工程规范：保留团队固定清单，补项目差异
./scripts/aw dsl          # L1 prompt；L2: aw paste dsl-write；L3: aw dsl apply
./scripts/aw dsl review docs/dsl/DSL_DRAFT.md --write  # 工程师审阅包
./scripts/aw approve dsl docs/dsl/DSL_DRAFT.md [--req REQ-...] --plan [--domain frontend|backend]
./scripts/aw plan apply --plan-file /tmp/PLAN.md --atomic-file /tmp/ATOMIC_TASKS.md --slug xxx
./scripts/aw approve plan docs/plans/PLAN_xxx.md
./scripts/aw confirm docs/dsl/<已审>.md docs/plans/<可执行-plan>.md   # 须同时指定 DSL + Plan
./scripts/aw index              # 仅刷新路径表，不等同任务确认
./scripts/aw file-index         # 刷新 docs/FILE_INDEX.md 项目代码文件索引
./scripts/aw check
./scripts/aw paste dev    # 打印可贴入任意对话的指令块
```

---

## 对话触发语（各工具通用）

人类在**任意** Agent 对话中说：

| 意图 | 示例 |
|------|------|
| 启动 AgentWorkflow | `启动 aw` / `@aw` / `aw start`。Agent 必须先声明已进入 AgentWorkflow，然后询问角色：`1=产品`、`2=前端`、`3=后端`、`4=全栈`；未确认角色前不得生成 DSL / Plan 或写业务代码 |
| 初始化 | `按 agent-workflow 初始化` / `aw init`；启动后必须先 `aw project scan` 扫描项目内容，再问工程师确认：这是全新项目还是已有 / 存量项目 |
| 项目扫描 | `aw project scan` 生成 `docs/PROJECT_SCAN.md`，Agent 先复述扫描依据和建议阶段，再让工程师确认 |
| 选择项目阶段 | `aw config init --project-stage 1` = 全新项目；`aw config init --project-stage 2` = 已有 / 存量项目。未扫描、未确认前不得生成 DSL / Plan 或写业务代码 |
| 非全新项目接入 | 先执行 `aw status`、`aw check config`、`aw rules review`、`aw context plan`、`aw file-index`、`aw service-catalog discover --write`；回填一期基线后，再为下一期 / 当前增量需求生成 DSL / Plan |
| 一键设置 | `aw setup` |
| 诊断 | `aw doctor` |
| 演示 | `aw demo` |
| 仪表盘 | `aw dashboard` |
| 能力摘要 | `aw capabilities` |
| 机器能力摘要 | `aw capabilities --json` |
| 机器状态 | `aw status --json` |
| 升级 | `aw upgrade` |
| 移除集成 | `aw remove` |
| 工程化上下文压缩 | `aw compact "本轮目标" --write --snapshot` |
| 记忆 | `aw memory add/search/inject`；记住聊天用 `aw memory chat` |
| 工程规范 | `aw rules init|discover|review|check`（默认带团队前端/后端/统一 AI 规范清单，项目内补差异） |
| 生成 DSL | `生成 DSL` / `aw dsl` |
| 生成 DSL 套件 | `aw dsl suite <slug> "title"`（复杂项目，多维规格） |
| DSL 工程师审阅 | `aw dsl review <dsl> --write` |
| 生成 Plan | `aw approve dsl <dsl> --plan` / `生成 Plan` / `aw plan`（须 DSL 已审） |
| 研发中计划变更 | 小变更用 `aw plan change --summary "..."`；同范围新增任务用 `aw plan task-add --title "..."`；任务过大用 `aw task split <AT-T> --into "A; B"`；大范围变化新建 Plan / ATOMIC 后重新 approve/confirm |
| 选择项目类型 | 项目阶段确认后询问工程师使用哪种代码托管平台，再执行 `aw config init --project-kind <n> --repo-url <url>`；1=GitHub，2=本地 Git，3=GitLab，4=Bitbucket，5=Gitee，6=GitCode，7=Gitea，8=Forgejo，9=GitLab CE，10=Gerrit，11=云效 Codeup；2 不需要 `--repo-url` |
| 同步中心决策 | 项目阶段确认后立即询问工程师是否建立同步中心：`aw config init --sync-center 1 --sync-center-path <path>` = 建立 / 使用，`--sync-center 2` = 不建立，`--sync-center 3` = 稍后决定且 Plan 保持阻断 |
| 选择构建目标 | DSL 已审后、Plan 生成前执行 `aw config init --build-target 1|2|3`；1=前端项目，2=后端项目，3=前后端项目。启动角色为 `全栈` 时默认前后端代码在同一仓库，优先配置 `3=前后端项目`，不默认强制同步中心 |
| 双项目拓扑确认 | 构建目标为前后端且前后端分仓时，先确认前端真实仓库、后端真实仓库、同电脑 / 不同电脑、同步中心路径 / 远程仓库地址；未确认前不得拆本地 Plan |
| 同步中心建设 | 同电脑用本地 `project-harness`；不同电脑先创建并 clone 独立远程 `project-harness` 仓库；前后端分别执行 `aw sync init <harness> --project ... --agent ... --role ...` |
| PM 产品生命周期 | `aw pm start` 进入 PM 向导；`aw pm init <harness>` 创建 PM 同步中心；`aw pm intake-check --write` 体检资料；`aw pm design import/link/change` 管理 Pencil；`aw pm dispatch/dashboard/gate` 派发三端任务、刷新看板、检查生命周期 |
| 双项目 Plan 拆分 | DSL 已审后，先写 `project-harness/global/plans/` 协作 Plan，再派生 `project-frontend/docs/plans/` 和 `project-backend/docs/plans/` 本地 Plan |
| 定向生成任务 | `aw approve dsl <dsl> --plan --domain frontend` / `--domain backend` |
| 任务确认 | `任务确认` / `aw confirm` → 生成 `ENGINEERING_INDEX.md` |
| 研发 | `aw next` → `aw task brief` → 需求沟通确认 → `aw task confirm`（范围 / 验收 / 非目标齐全） → `aw context plan` → `aw context gate` → `aw task start` → `aw paste task` → `aw task complete`；配置同步中心后，start 自动 pull/gate，complete 自动发布 complete 事件，blocked 自动发布 block 事件 |
| 子任务需求确认 | `aw task brief <AT-T>` → 工程师确认后 `aw task confirm <AT-T> "已确认：范围=...；验收=...；非目标=..."` |
| 口述新增需求 | `aw req new <slug> "标题" --type 口述新增 --impact "..." --acceptance "..."` |
| 研发中需求变更 | `aw req change <AT-T> "摘要" --impact "..." --acceptance "..."` → 回写 REQ / DSL / Plan / ATOMIC → 重新 brief/confirm |
| 阻塞任务 | `aw task blocked <AT-T>` |
| 完成任务 | `aw task complete <AT-T>`（自动验证；失败写 `AI_BUG_LOG.md`） |
| 阶段性提交提醒 | 每个大需求 / AT-T 完成后询问是否提交当前分支；同意后 `aw commit --task <AT-T> ... --execute` |
| Bug 留痕 | `aw bug add "摘要" --source chat|test|review|runtime|prod --scope <范围>` |
| 版本记录 | `aw changelog add --type Changed --message "..."`；也可在提交助手中用 `aw commit --changelog "..."` 写入 `[Unreleased]` |
| 执行审计 | `aw audit add --task <AT-T> --action "..." --result "..." --evidence "..."`，记录 AI 关键动作、命令、结果和确认点 |
| Policy 门禁 | `aw policy check`；高风险路径、新依赖、生产/数据库/安全/破坏性变更用 `aw policy decision ...` 留痕；严格阻断用 `aw policy gate --strict` |
| Policy diff | `aw policy diff [--staged|--all]` 检查 git diff 中的高风险路径和依赖文件变化 |
| 安全与依赖 | `aw security finding "..."` 记录安全发现；`aw security dependency "pkg" --version ... --purpose ...` 记录依赖准入 |
| 安全扫描适配 | `aw security scan` 检测可用 secret/SCA/SAST 工具并建议命令；`aw security scan --run` 执行已安装扫描器 |
| 服务目录 | `aw service-catalog add "module" ...` 维护 `docs/SERVICE_CATALOG.md` |
| 服务目录发现 | `aw service-catalog discover` 输出候选服务/模块，并提示入口、API、数据、依赖、端口/脚本、日志/观测；`--write` 写入候选项 |
| 发布闭环 | `aw release record ...` 记录环境、发布、验证、回滚、CHANGELOG/tag；`aw release flag ...` 记录 Feature Flag |
| 发布门禁 | `aw release gate [--run-verify] [--run-security] [--strict-policy] [--strict-report]` 聚合 CHANGELOG、Policy、Security、Service Catalog、环境、Ops、Agents、Metrics、报告门禁与可选验证 |
| 自动 Gate | `aw gate pre-commit|task|pr|release` 聚合 DSL、REQ、TP、Contract、Agent 锁、Trace、Score、Release；`aw hooks install` 可接入 Git hooks |
| 代码上下文控制 | `aw context init|status|plan|query|impact|affected|gate` 生成任务级 Context Plan，限制读取文件和 symbol，优先接入 CodeGraph，避免无目标全仓扫描 |
| 上下文自动补全 | `aw context enrich --task <AT-T>` 自动补全 Symbol / 影响范围；`aw verify --affected --task <AT-T>` 先写入 affected analysis 再验证 |
| 前后端契约 | `aw contract init|change|test|diff|gate` 维护 OpenAPI、API 变更、Mock、Contract Test、Schema Diff 和破坏性变更阻断 |
| 契约自动化 | `aw contract diff --write|breaking-check|sync` 自动记录 OpenAPI diff、检测破坏性变更候选，并发布契约同步事件；配置同步中心后 `aw contract change` 自动发布 contract 事件 |
| VCS PR/MR/CR 闭环 | `aw vcs branch|fill|create|review|gate` / `aw vcs gate` 维护分支策略、PR/MR/CR 清单、Review、Contract/Score/Release/Rollback 检查；支持 GitHub、GitLab、Bitbucket、Gitee、GitCode、Gitea、Forgejo、GitLab CE、Gerrit、Codeup |
| PR/MR/CR 自动填充 | `aw vcs fill|create` 基于 AT-T、DSL、Plan、Context、Verify、Contract、Score 自动生成草稿；真正创建远端请求需工程师确认 |
| Watch 自动化 | `aw watch index [--once|--loop]` 刷新 FILE_INDEX / ENGINEERING_INDEX，并输出 affected analysis |
| 多 Agent 锁 | `aw agents claim|heartbeat|release|lock-check` 维护任务锁、心跳、过期锁、路径冲突；严格模式阻断并行冲突 |
| 交付评分 / 恢复 | `aw score record --scope ...` 写 0-100 交付评分；`aw recover context|plan|sync|failed-task|conflict|rollback` 固化恢复路径 |
| 严格报告发布门禁 | `aw release gate --strict-report` 要求最近 release 报告存在且关键快照完整 |
| 工程报告 | `aw report handoff|release [--write]` 生成交接 / 发布审查报告，落盘到 `docs/reports/` |
| 发布报告 | `aw report release [--write]` 生成发布审查报告，包含 release gate、trace check、metrics summary 和服务发现快照 |
| 报告门禁 | `aw report check [--strict]` 检查最近交接 / 发布报告是否存在且关键章节完整；严格模式可作为交接 / 发布阻断项 |
| Feature Flag 生命周期 | `aw release flag-check` 检查 flag 是否有清理计划 |
| 交付度量 | `aw metrics record --type deploy|change|failure|recovery ...` 记录 DORA / Flow 指标；`aw metrics summary` 输出交付健康摘要 |
| 可靠性 / 事故 | `aw ops slo|incident|incident-close|runbook ...` 记录 SLO、事故、恢复闭环、Runbook；`aw ops gate` 检查未关闭高危事故 |
| 多 Agent 协作 | `aw agents assign|handoff|review ...` 记录角色、文件边界、交接和评审结论；`aw agents gate` 检查阻断评审和路径重叠，`--strict` 可阻断冲突 |
| 多 Agent 严格门禁 | `aw agents gate --strict` 发现 allowed paths 重叠时阻断，要求先 handoff 或重新分配文件边界 |
| 跨项目前后端同步 | `aw sync init <harness-dir> --project <name> --agent <name>` 配置共享同步中心；`aw sync baseline` 显示 / 初始化共享 DSL、协作 Plan、接口契约基线路径；`aw sync board` 生成 / 查看共享任务看板；`aw sync gate --task <AT-T>` 在分仓任务开始前强制最近 pull、inbox、board 就绪；`aw sync event --type ...` 编排任务完成、需求变更、阻塞、问题、契约、Bug、决策和交接；`aw sync change <AT-T> "summary" --to <agent> --impact "..." --acceptance "..."` 是需求变更快捷入口；`aw sync inbox` 汇总对方事件；`aw sync pull` 拉取其他项目快照到只读 inbox；`aw sync push --task <AT-T>` 发布本项目 DSL / Plan / REQ / Handoff / Agents / Bug / TP / Security 快照；配置同步中心后任务生命周期会自动调用这些同步动作 |
| PM 三端任务派发 | DSL 审核后先 `aw pm plan --write` 生成 `project-harness/global/plans/*`；Plan 审核后 `aw pm dispatch --write` 生成 `TASK_BOARD.md`、`FRONTEND_ASSIGNMENTS.md`、`ADMIN_ASSIGNMENTS.md`、`BACKEND_ASSIGNMENTS.md`；前台/后台/后端 Agent 开始任务前先读取自己的 assignments 和 `global/contracts/INTEGRATION_MATRIX.md` |

PM 常用命令：`aw pm plan --write` 从已审 DSL 生成共享/三端 Plan 草案；`aw pm dispatch --write` 从 `global/plans/ATOMIC_TASKS.md` 生成派发表；`aw pm assignments --role frontend|admin|backend|all` 查看三端任务派发；`aw pm dashboard --write` 刷新项目进度看板。
| 追溯链检查 | `aw trace check` 检查 REQ、DSL、Plan、AT-T、TP、Bug、Changelog 和 Harness 记录是否断链 |
| 验证 | `aw verify` / `aw verify --task AT-T…` / `aw verify --run-e2e` |
| Plan 校验 | `aw check plan` |
| Plugin 校验 | `aw check plugin` |
| Memory 校验 | `aw check memory` |
| 项目配置 | `aw check config`（占位符检测） |
| 项目配置填写 | `aw config init --project-kind <n> --repo-url <url> --build-target 1|2|3 --lint ...` |
| CI 模板 | `aw ci install` |
| 项目代码文件索引 | `aw file-index` → `docs/FILE_INDEX.md`（新增 / 删除 / 重命名前端、后端、共享、测试、运行配置代码文件时刷新；脚本/模板/文档只是辅助索引） |
| 文件索引门禁 | `aw gate file-index` 检查新增 / 删除 / 重命名业务文件是否同步刷新 `docs/FILE_INDEX.md` |
| Plan 落盘 | `aw paste plan-write` / `aw plan write` / `aw plan apply` |
| 多 ATOMIC | `aw atomic list` / `aw atomic use <slug>` |
| 多 DSL / Plan | `aw dsl list/use` · `aw plan list/use` |
| 提交助手 | `aw commit -m "feat(AT-T…): …" --changelog "Changed: ..."`（默认不执行 git commit） |
| 完成检查点 | `aw task checkpoint <AT-T> --git yes|no --reason "..." --handoff --compact --file-index` 记录任务完成后的 Git 决策、交接压缩和索引刷新；完成态任务缺失时 `aw gate task` 阻断 |
| DSL 落盘 | `aw dsl write` / `aw paste dsl-write` / `aw dsl apply` |
| 测试计划 | `aw tp new` · `aw tp link <AT-T> <TP>` · `aw check tp` · Verify 列 `TP:path` |
| Git 提交 | `aw commit --task <AT-T> --changelog "..." -m "type(<AT-T>): 摘要"` → 版本记录 + 验证 + 建议提交；工程师确认或 `--execute` 后才真正提交 |
| 交接 | `aw handoff "本轮目标"` 生成草稿；审阅后 `aw handoff "本轮目标" --write` 落盘；新会话前 `aw handoff --check` |
| 闭环检查 | 进入下一大需求 / AT-T 前，核对完整性、可追溯性、可维护性、可交接性；缺口写入 REQ / Bug / Handoff |

Agent 应先读本文件的相关小节，再执行对应 `scripts/aw` 子命令或等价步骤；只有进入 Reference → DSL → Plan 阶段且命令 / 模板不明确时，才读取 `PRODUCT_INPUT_WORKFLOW.md` 的相关段落，不要默认整篇加载。

当工程师说“执行研发任务 / 开始开发 / 做下一个任务”时，Agent 的第一步必须是输出或执行 `aw next` 与 `aw task brief <AT-T>`，然后像真实研发一样追问需求、边界、验收、异常态、联动、非目标和风险。工程师明确确认前，不得写业务代码，不得生成编码提示，不得调用 `aw paste task`。确认后必须记录 `aw task confirm <AT-T> "已确认：范围=...；验收=...；非目标=..."`，再执行 `aw context plan`、`aw context gate`、`aw task start`。

启动 AgentWorkflow 时，工程师可以只说 `启动 aw` 或 `@aw`。Agent 第一反应不是扫描也不是写代码，而是声明进入 AgentWorkflow，并询问工程师角色：`1=产品`、`2=前端`、`3=后端`、`4=全栈`。角色确认后，Agent 才运行 `aw project scan` 扫描项目内容，生成并阅读 `docs/PROJECT_SCAN.md`，再把“建议项目阶段、判断依据、前端/后端线索、同步中心状态”复述给工程师确认。确认后写入 `docs/PROJECT_CONFIG.md`：全新项目用 `aw config init --project-stage 1`；已有 / 存量项目用 `aw config init --project-stage 2`。随后按角色和项目拓扑询问工程师是否建立同步中心，并用 `aw config init --sync-center 1|2|3` 记录。`全栈` 角色默认前后端代码在同一仓库，构建目标为 `3=fullstack`，同步中心可以选择不建立；如果工程师确认前后端分仓、不同电脑或 PM 管理三端协作，则必须建立同步中心。未确认角色、未扫描、未确认项目阶段、未记录同步中心决策前，不得生成 DSL / Plan，不得写业务代码。

生成 Plan 或拆 AT-T 前必须通过 `aw project gate`：已完成项目扫描；项目阶段、同步中心决策、项目类型、构建目标已确认；若同步中心决策为 `pending` 必须阻断；若构建目标为前后端且前后端分仓 / 双项目，必须先引导工程师建立同步中心并执行 `aw sync init <project-harness> --project ... --agent ... --role ...`。未通过 gate 时，`aw plan`、`aw approve dsl --plan`、`aw plan apply` 必须阻断。

非全新 / 存量项目接入时，Agent 应先建立当前真实状态，不得按空白新项目重建：确认项目阶段、仓库类型、构建目标和一期完成范围；目标化读取入口文件，禁止无目标全仓扫描；刷新 `docs/FILE_INDEX.md` 与 `docs/SERVICE_CATALOG.md`；把已实现能力、已知 Bug、技术债、未确认事项、不应被误改的稳定边界写入 Handoff / REQ / Memory；只有一期基线经工程师确认后，才为下一期、维护、Bug 修复或联调需求生成增量 DSL 和增量 Plan。

前后端分成两个项目时，先按需读取 [`CROSS_PROJECT_SYNC.md`](./CROSS_PROJECT_SYNC.md) 的相关小节，不要整篇加载。共享 DSL / 协作 Plan 放在同步中心 `global/dsl/` 和 `global/plans/`，共享任务看板放在 `global/plans/TASK_BOARD.md`，本项目 DSL / Plan 是执行派生；`aw sync pull` 只导入对方快照到 `docs/sync/inbox/`，不得直接覆盖本项目 DSL / Plan / 代码。跨端任务开始前优先读 `aw sync inbox --from <peer>` 摘要、`TASK_BOARD.md` 和相关 event / contract；不要默认读取整个 inbox 或整个同步中心。接口、字段、权限、错误码或阻塞变化必须在本项目重新通过 REQ / Bug / Handoff 落账后再 `aw sync push`。

PM Agent 场景：PM 不需要记底层命令，先运行 `aw pm start` 查看向导。若项目使用同步中心作为产品事实源，运行 `aw pm init <project-harness> --project <name> --agent pm-agent --role pm`，再把 PRD/UI/技术/API/业务/Pencil 资料放入 `global/references/`。Pencil `.pen` 存在 `global/references/design/pencil/source/`，导出物放 `exports/`，截图放 `screenshots/`；`.pen` 不允许普通文本解析。新增需求、设计稿变更和三端派发变更先走 `aw pm change` 或 `aw pm design change`，再更新 DSL、Plan、dispatch 和 dashboard，不能直接让实现 Agent 改代码。

产品全生命周期 Gate：立项未确认不生成 DSL；需求未评审不生成正式 Plan；设计未冻结不派发正式前端任务；技术方案未确认不派发正式后端任务；API 契约未确认不进入联调；测试计划未生成不允许任务完成；UAT 未通过不允许发布；上线 checklist 未完成不允许 release；复盘未记录项目不能关闭。用 `aw pm gate` 检查，`--strict` 会阻断所有待确认生命周期状态。

双项目从 DSL 进入 Plan 前，Agent 必须先引导工程师完成真实代码仓库与同步中心建设：前端仓库、后端仓库、同步中心都要有明确本地路径；不同电脑协作时，同步中心必须是单独远程 Git 仓库，双方都先 `git pull` 最新 harness 后再拆 Plan。若仓库未准备好，Agent 只能继续引导建仓 / 初始化 / `aw sync init`，不能生成本地 Plan。

写入 REQ / Bug / TP / DSL / Plan 的 CLI 命令成功后会自动以扫描模式刷新 `ENGINEERING_INDEX.md`；这不等同于 `aw confirm`，不会改变任务确认状态。

## Handoff 与 Memory 边界

| 功能 | 用途 | 命令 / 文件 |
|------|------|-------------|
| Handoff | 当前交接：目标、进度、阻塞、下一步、待确认 | `docs/handoff/PROJECT_HANDOFF.md` / `aw handoff` |
| Memory | 长期复用：稳定事实、决策、偏好、流程、风险、聊天摘要 | `docs/memory/` / `aw memory add|chat|search|inject` |

规则：Handoff 写过程状态；Memory 写可复用结论和聊天摘要。只有当 Handoff 里的结论未来会反复用，才提炼成 `aw memory add`。当用户要求记住聊天时，使用 `aw memory chat` 保存摘要、决策、待办、待确认和关联对象；不要把整段 Handoff、完整逐字聊天或 secret 写入 Memory。

Codex 原生上下文压缩无法由 skill 直接监听。AgentWorkflow 的联动入口是 `aw compact`：在上下文变长、切换模型、新开会话、长时间暂停、完成一个大需求或 AT-T 批次时，先执行：

```bash
./scripts/aw compact "本轮目标" --write --snapshot
```

它会更新并检查 `docs/handoff/PROJECT_HANDOFF.md`，生成 `docs/handoff/LAST_AUTO_SNAPSHOT.md` 和 `docs/handoff/PASTE_IN_NEW_CHAT.txt`。如果需要记住聊天摘要，加：

```bash
./scripts/aw compact "本轮目标" --write --snapshot \
  --memory-summary "本轮讨论摘要" \
  --memory-decisions "已确认决定" \
  --memory-todos "后续待办" \
  --memory-open "待确认问题"
```

`aw handoff "focus"` 会自动读取当前 DSL / Plan / ATOMIC / 任务 / REQ / Bug / 项目配置 / Git 状态并输出可审阅草稿。推荐先看草稿：

```bash
./scripts/aw handoff "本轮目标" > /tmp/PROJECT_HANDOFF.md
```

人工审阅后可直接落盘并自动备份旧文件：

```bash
./scripts/aw handoff "本轮目标" --write
./scripts/aw handoff --check
```

等价占位示例：`aw handoff "focus" --write`。

---

## Agent 必读（按阶段）

| 阶段 | 文档 |
|------|------|
| 0 Reference→DSL→Plan | [`PRODUCT_INPUT_WORKFLOW.md`](./PRODUCT_INPUT_WORKFLOW.md) |
| A–E 写代码 | [`AICODING_WORKFLOW.md`](./AICODING_WORKFLOW.md) |
| 规则面 | [`AGENT_RULES.md`](./AGENT_RULES.md) |
| 栈/命令 | 仓库 `docs/PROJECT_CONFIG.md` |
| 工程规范 | 仓库 `docs/ENGINEERING_RULES.md`（团队固定清单 + 项目特有差异） |
| 质量 | [`VERSION_CHANGELOG_QUALITY_LOOP.md`](./VERSION_CHANGELOG_QUALITY_LOOP.md) |
| 交接 | 仓库 `docs/handoff/PROJECT_HANDOFF.md` |
| 记忆 | 仓库 `docs/memory/INDEX.md`，按需 `aw memory inject` |

---

## 硬闸门（所有工具）

1. 未 init → 建议运行 `./scripts/aw init`。
2. DSL **状态 ≠ 已审** → 只改文档，**不写业务代码**。
3. 用户说“执行研发任务 / 开始开发 / 做下一个任务” → 只允许进入 `aw next` + `aw task brief` + 追问确认流程；未 `aw task confirm`、`aw context gate`、`aw task start` 前不写业务代码。
4. `aw paste task` 是编码提示闸门；如果没有当前已 start 且已确认的任务，它必须阻断。
5. 禁止编造 `reference/`、`docs/dsl/` 下不存在的路径。
6. 代码实现遵守 `docs/ENGINEERING_RULES.md`；验证以 `docs/PROJECT_CONFIG.md` 命令 + §11 真实环境为准。
7. 大需求 / AT-T 未完成闭环检查（完整性、可追溯性、可维护性、可交接性）前，不进入下一项实现。

---

## 新会话粘贴块（复制到任意 Chat）

```text
请按本仓库 agent-workflow 工作流执行。
先读：agent-workflow/INVOCATION.md 的相关小节；只有生成 DSL / Plan 时才按需读取 PRODUCT_INPUT_WORKFLOW.md
真源：docs/handoff/PROJECT_HANDOFF.md、docs/requirements/INDEX.md、docs/dsl/、docs/plans/
本轮：<一句话任务>
闸门：DSL 非「已审」不写业务代码。省 token：先 aw status --json / aw next / aw task brief / aw context plan，不全仓扫描，不读 ENGINEERING_INDEX.md。
```

运行 `./scripts/aw paste session` 可打印带路径的完整版。

---

## IDE 适配（一览）

| 工具 | 入口文件 | 安装 |
|------|----------|------|
| Claude Code | `CLAUDE.md` | `aw adapters --claude` |
| Codex | `AGENTS.md` | `aw adapters --codex` |
| Copilot / VS Code | `.github/copilot-instructions.md` | `aw adapters --copilot` |
| Cursor | `.cursor/rules/agent-workflow.mdc` | `aw adapters --cursor` |
| Windsurf | `.windsurfrules` | `aw adapters --windsurf` |
| Cline | `.clinerules` | `aw adapters --cline` |
| Continue | `.continue/rules/agent-workflow.md` | `aw adapters --continue` |
| 任意对话 | — | `aw paste session` |

Windows / WSL / Git Bash 见 [`WINDOWS.md`](./WINDOWS.md)。

## 与 Cursor Skill 的关系

| 载体 | 角色 |
|------|------|
| **`agent-workflow/` + `scripts/aw`** | **跨工具真源**（进 Git） |
| 各 IDE 规则文件 | 指向真源的**薄适配** |
| `~/.cursor/skills/agent-workflow/` | **仅 Cursor 可选** Skill，见 [`adapters/cursor.md`](./adapters/cursor.md) |

**不要**把流程只写在某一 IDE 私有目录而不进 `agent-workflow/`。
