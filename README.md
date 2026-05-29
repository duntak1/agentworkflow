# agent-workflow

通用 **AI 交付工作流 Skill + CLI**：把需求材料变成可审阅 DSL、可执行 Plan、原子任务和可验证交付。它不绑定某个 IDE，支持 **Claude Code、Codex、Copilot、Cursor、Windsurf、Cline、Continue** 及任意对话；Cursor Skill 只是可选入口。

在线手册：<https://duntak1.github.io/agentworkflow/>

## 为什么需要

AI 编码常见问题不是“不会写代码”，而是上下文和闸门不稳定：

- 需求没审清就直接改业务代码。
- Agent 猜测路径、架构、验收标准。
- Plan 不可执行，任务之间依赖不清。
- 改动范围扩大，夹带无关重构。
- 口头说完成，但没有跑项目真实验证命令。
- 换 IDE 或新会话后，要重复解释流程。

## 解决方案

agent-workflow 把交付拆成一条跨工具流水线：

```text
Project Scan → 阶段确认 → 同步中心决策 → 项目类型/构建目标确认 → 必要时同步中心就绪 → Reference/基线 → DSL 已审 → Plan 可执行 → confirm → AT-T 任务 → verify → compact / handoff
```

| 能力 | 解决的问题 |
|------|------------|
| `reference/manifest.yaml` | 材料来源可追踪，避免编造路径 |
| `aw project scan|gate` | 先扫描项目内容判断全新/已有项目；未扫描、未确认阶段、未记录同步中心决策或 fullstack 未建同步中心时阻断 Plan |
| `aw dsl` / `aw dsl apply` | 先产出可审需求 DSL，再允许写代码 |
| `aw dsl suite` | 生成多文件 DSL 套件，覆盖需求、页面、交互、事件、联动边界、验收 |
| `aw dsl review` | 给工程师输出 DSL 审阅包，确认通过后再 approve |
| `aw plan` / `aw plan apply` | 把方案拆成可执行 Plan + AT-T 原子任务 |
| `aw rules init|review|check` | 生成并校验工程规范：技术栈、代码规范、禁令、SOP |
| `aw confirm` | 人类确认后才生成工程执行索引 |
| `aw file-index` / `docs/FILE_INDEX.md` | 生成项目代码文件索引；AI 代写代码后供人类工程师快速定位需手改文件 |
| `aw task brief|confirm` | 每个子任务写代码前先沟通需求；用户说“执行研发任务”时先 brief 和追问，不直接写代码 |
| `aw context plan|gate` | 每个子任务写代码前限制允许读取文件，防止无目标全仓扫描 |
| `aw task start|blocked|complete|checkpoint` | 任务状态可追踪；完成必须来自已 start 任务，并补 Git / compact / handoff / FILE_INDEX 检查点；配置同步中心后自动 pull/gate、发布 complete/block 事件 |
| `aw task complete --run-e2e` | 使用项目真实命令验证；通过完成，失败自动写 Bug 流水 |
| `aw bug add|list` | 所有 Bug / 疑似 Bug 统一记录到 `docs/handoff/AI_BUG_LOG.md` |
| `aw req new|change` | 口述新增和研发中变更都记录到 `docs/requirements/INDEX.md`，用“需求类型”区分；变更会回写 DSL / Plan / ATOMIC |
| `aw index` | 交付文件索引刷新；REQ / Bug / TP / DSL / Plan 写入命令会自动触发扫描刷新 |
| `aw file-index` | 项目代码文件索引刷新；覆盖 scripts、skill、templates、agent-workflow、docs、CI、配置入口 |
| `aw adapters --all` | 同一套规则接入多 IDE / 多 Agent |
| `aw paste session|task` | 新会话可直接恢复上下文 |
| `aw status --json` / `aw capabilities --json` | 给 dashboard、插件和自动化提供机器可读状态与能力摘要 |
| `aw dashboard` | 只读终端视图，集中显示当前状态、能力和机器可读入口 |
| `aw memory add|search|inject` | 文件化跨会话记忆，记录可追踪事实、决策、偏好、模式和风险 |
| `aw compact --write --snapshot` | Codex / 新会话前的一键工程化上下文压缩：更新 handoff、生成新会话粘贴块、可选写聊天 Memory |
| `aw gate pre-commit|task|pr|release` | 自动 Gate：把 DSL、REQ、TP、Contract、Agent 锁、Trace、Score、Release 检查串起来 |
| `aw context plan|gate|affected` | 任务级代码上下文控制：禁止全仓扫描，按 CodeGraph / 索引生成最小读取范围和受影响测试 |
| `aw context enrich` / `aw verify --affected` | 自动补全 Context Plan 的 symbol/影响范围，并按变更范围写入 affected analysis |
| `aw contract change|test|gate` | 前后端契约系统：OpenAPI、Mock、Contract Test、Schema Diff、破坏性变更阻断；配置同步中心后 contract change 自动发布契约同步事件 |
| `aw contract diff --write` / `aw vcs fill` / `aw watch index` | 自动记录契约 diff、生成 PR/MR/CR 草稿、刷新索引和 affected analysis |
| `aw vcs branch|fill|create|review|gate` | 多代码仓库 PR/MR/CR 闭环：GitHub、GitLab、Bitbucket、Gitee、GitCode、Gitea、Forgejo、GitLab CE、Gerrit、Codeup |
| `aw pm start|init|intake-check|design|plan|dispatch|dashboard|gate` | PM Agent 产品全生命周期：同步中心资料、Pencil、DSL 审核后生成共享/三端 Plan、Plan 审核后三端任务派发、看板、生命周期 Gate |
| `aw agents claim|heartbeat|release` | 多 Agent 任务锁和心跳：认领任务、续约状态、释放任务、冲突检测 |
| `aw score record` / `aw recover ...` | 交付评分和恢复机制：审计、修复、交接、回滚有固定路径 |

Skill 首屏还内置编码原则：**Think before coding、Simplicity first、Mature solutions first、Surgical changes、Goal-driven execution**。

## 快速开始

```bash
cd your-app
/path/to/agentworkflow/scripts/aw install . --adapters
chmod +x scripts/aw scripts/*.sh
./scripts/aw setup
./scripts/aw project scan
./scripts/aw config init --project-stage 1 # 1=全新项目，2=已有/存量项目；先看 docs/PROJECT_SCAN.md 再确认
./scripts/aw config init --sync-center 1 --sync-center-path ../project-harness # 1=建立/使用，2=不建立，3=稍后决定且阻断 Plan
./scripts/aw config init --project-kind 1 --repo-url https://github.com/<owner>/<repo>
# 代码托管平台：1=GitHub，2=本地 Git，3=GitLab，4=Bitbucket，5=Gitee，6=GitCode，7=Gitea，8=Forgejo，9=GitLab CE，10=Gerrit，11=云效 Codeup
./scripts/aw config init --build-target 1 # 1=前端，2=后端，3=前后端
./scripts/aw status
./scripts/aw dashboard
./scripts/aw memory inject
./scripts/aw status --json
./scripts/aw capabilities --json
```

如果从远程仓库安装 Cursor Skill，可直接传 GitHub URL：

```bash
/path/to/agentworkflow/scripts/install-cursor-skill.sh https://github.com/duntak1/agentworkflow.git
```

验证整条流程：

```bash
./scripts/aw demo
```

工程规范写入 `docs/ENGINEERING_RULES.md`，项目实际栈和命令写入 `docs/PROJECT_CONFIG.md`。AT-T 原子任务会标注领域：`Frontend / Backend / Fullstack / QA / Docs / Ops / Data`。前后端边界清楚时拆开，必须贯通 UI 与 API 的验收标 `Fullstack`，避免为了分类强拆任务。

也可以按人类指令定向拆任务，例如“DSL 已确认，生成前端研发计划”对应：

```bash
./scripts/aw approve dsl docs/dsl/DSL_xxx.md --plan --domain frontend
```

后端同理使用 `--domain backend`。

源码仓发布检查：

```bash
./scripts/e2e-smoke.sh
./scripts/build-skill-archive.sh
```

## 支持矩阵

| Agent / IDE | 入口文件 | 安装命令 | 状态 |
|-------------|----------|----------|------|
| Claude Code | `CLAUDE.md` | `aw adapters --claude` | 支持 |
| OpenAI Codex | `AGENTS.md` | `aw adapters --codex` | 支持 |
| GitHub Copilot / VS Code | `.github/copilot-instructions.md` | `aw adapters --copilot` | 支持 |
| Cursor | `.cursor/rules/agent-workflow.mdc` + 可选 Skill | `aw adapters --cursor` / `aw sync-skill` | 支持 |
| Windsurf | `.windsurfrules` | `aw adapters --windsurf` | 支持 |
| Cline | `.clinerules` | `aw adapters --cline` | 支持 |
| Continue | `.continue/rules/agent-workflow.md` | `aw adapters --continue` | 支持 |
| 任意 Chat | 粘贴块 | `aw paste session` | 支持 |

## 可验证范围

- 7 类以上 Agent / IDE 适配入口。
- 20+ 个 `aw` 子命令覆盖安装、诊断、DSL、Plan、任务、验证、CI、升级、移除。
- e2e 路径覆盖：install → init → DSL → Plan → approve → confirm → task → TP → verify。
- 发布检查覆盖 Skill 源、Skill 包、命令文档同步与版本文件。

## Cursor Skill（可选）

```bash
cd agentworkflow
./scripts/sync-skill.sh
```

也可从远程仓安装：

```bash
./scripts/install-cursor-skill.sh https://github.com/duntak1/agentworkflow.git
```

详见 [PUBLISH.md](PUBLISH.md) · [skill/QUICKSTART.md](skill/QUICKSTART.md)。

## Codex Plugin Metadata

本仓包含 [.codex-plugin/plugin.json](.codex-plugin/plugin.json)，用于 Codex 插件入口的基础元数据；[.agents/plugins/marketplace.json](.agents/plugins/marketplace.json) 提供 repo-root local marketplace 条目，`source.path` 指向当前仓库根。核心流程仍以 `agent-workflow/` 与 `scripts/aw` 为真源。

## Handoff vs Memory

- `docs/handoff/PROJECT_HANDOFF.md`：当前目标、进度、阻塞、下一步。
- `docs/memory/`：稳定事实、决策、偏好、可复用流程、长期风险。
- 只有当 Handoff 里的结论会被未来任务复用时，才提炼成 `aw memory add`。
- `aw compact "本轮目标" --write --snapshot`：一键生成工程化压缩快照，写入 `PROJECT_HANDOFF.md`、`LAST_AUTO_SNAPSHOT.md` 和 `PASTE_IN_NEW_CHAT.txt`；带 `--memory-summary` 时同步写聊天摘要 Memory。

## 文档

| 路径 | 说明 |
|------|------|
| [skill/SKILL.md](skill/SKILL.md) | Cursor Skill 真源 |
| [skill/reference.md](skill/reference.md) | Skill 能力与 CLI 速查 |
| [agent-workflow/INVOCATION.md](agent-workflow/INVOCATION.md) | 调用真源（install 后） |
| [agent-workflow/AICODING_WORKFLOW.md](agent-workflow/AICODING_WORKFLOW.md) | AI 编码阶段 A-E |
| [docs/handoff/AGENTWORKFLOW_ROADMAP.md](docs/handoff/AGENTWORKFLOW_ROADMAP.md) | 项目路线图 |

## License

[MIT](LICENSE)
