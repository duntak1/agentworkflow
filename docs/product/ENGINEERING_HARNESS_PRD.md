# Engineering Harness PRD

## 1. 产品定位

Engineering Harness 是面向 AI 研发的本地优先工程控制系统。它不替代 Codex、Cursor、Claude Code、Cline、Windsurf 等编程 Agent，而是负责管理 Agent 研发过程中的需求、DSL、计划、任务、验证、Bug、Git、PR、前后端同步、交接和恢复。

一句话定位：

> 让 AI 写代码从“对话式执行”升级为“可审、可测、可追踪、可回滚、可交接的工程交付”。

## 2. 背景与问题

真实 AI 研发中的核心问题不是模型不会写代码，而是研发流程缺少控制面：

- 需求未确认就进入编码。
- Agent 猜测业务规则、接口字段、项目路径和验收标准。
- DSL、Plan、AT-T、代码、测试、Bug、Git 之间断链。
- 前端、后端、后台前端多 Agent 之间靠聊天同步，容易歧义。
- AI 写完代码后，工程师不知道改了哪些文件、为什么改、该从哪里接手。
- 上下文溢出或换会话后，任务状态丢失。
- GitHub PR、CI、Review、Release、Rollback 没有形成闭环。
- 失败后缺少恢复路径，容易继续猜测。

## 3. 产品目标

### 3.1 核心目标

- 建立 Reference → DSL → Plan → AT-T → Verify → Handoff/Git 的可视化研发流水线。
- 强制关键节点工程师确认，降低 AI 猜测。
- 为前端、后端、多项目、多 Agent 建立同步中心和任务锁。
- 自动维护文件索引、Bug 流水、交付评分和恢复手册。
- 与 GitHub PR / CI / Release / Rollback 形成闭环。

### 3.2 非目标

- V1 不做完整 SaaS 多租户。
- V1 不自研代码生成 Agent。
- V1 不替代 Jira / Linear / GitHub Projects。
- V1 不默认全自动提交、合并或发布生产。

## 4. 目标用户

| 用户 | 诉求 |
|------|------|
| 独立开发者 | 让 AI 生成项目时不丢上下文、不乱改文件、有交付记录 |
| 前端工程师 | 清楚后端接口、页面任务、状态同步和联调风险 |
| 后端工程师 | 清楚前端依赖、API 契约、权限/错误码/数据模型变更 |
| 技术负责人 | 审核 DSL、Plan、PR、质量、风险和交付状态 |
| AI Agent 操作者 | 有明确任务、上下文、边界、验证命令和交接要求 |

## 5. 核心对象模型

| 对象 | 说明 |
|------|------|
| Project | 本地或 GitHub 项目，支持单项目、多项目、前后端分离 |
| Reference | 参考资料、PRD、设计稿、代码工程、接口文档 |
| Requirement | 需求、口述新增、研发中变更、约束规则 |
| DSL Suite | 多文件 DSL：需求、页面、交互、事件、联动边界、验收 |
| Plan | 研发计划，可按前端、后端、Fullstack、QA、Ops 拆分 |
| Atomic Task | AT-T 原子任务，带状态、依赖、验收、验证命令 |
| Agent | 前台前端、后台前端、后端、QA、Review 等角色 |
| Agent Lock | 多 Agent 任务锁，防止并行冲突 |
| Contract | OpenAPI、Mock、Contract Test、Schema Diff |
| Bug | Bug / 疑似问题 / 测试失败 / 联调失败流水 |
| Verification | lint/test/build/e2e/contract/security 证据 |
| File Index | 工程师代码文件索引 |
| Handoff | 当前会话/任务交接 |
| Memory | 可复用长期记忆和聊天摘要 |
| PR / Release | GitHub PR、Review、CI、Release、Rollback |
| Score | 交付评分 |
| Recovery | 上下文、Plan、Sync、任务失败、冲突、回滚恢复路径 |

## 6. 核心流程

### 6.1 项目初始化

1. 选择项目类型：GitHub 仓库 / 本地 Git 仓库。
2. 选择构建目标：前端 / 后端 / 前后端 / 多项目。
3. 配置项目路径、GitHub URL、同步中心路径。
4. 生成 `docs/PROJECT_CONFIG.md`、工程规范、hooks、contracts、github、score、recovery 基础文件。
5. 安装 Agent 适配入口：Codex、Cursor、Claude Code、Cline、Windsurf、Copilot。

### 6.2 Reference 到 DSL

1. 工程师上传或指定参考资料。
2. Harness 维护 reference manifest。
3. Agent 生成 DSL Suite。
4. Harness 展示 DSL diff 和审阅状态。
5. 工程师确认后 DSL 状态变为“已审”。

### 6.3 DSL 到 Plan

1. 工程师选择生成前端 / 后端 / 前后端计划。
2. Harness 从 DSL 生成 Plan 和 AT-T。
3. 每个 AT-T 绑定 REQ、DSL、验收标准、验证命令、允许文件范围。
4. 工程师确认 Plan 后，任务进入可认领状态。

### 6.4 研发执行

1. Agent 通过 `claim` 认领任务。
2. 任务开始前必须沟通需求边界。
3. 工程师确认后任务进入 Coding。
4. Agent 修改代码并维护 File Index。
5. 完成任务前运行 verify、contract gate、trace gate、score。
6. 询问是否提交 Git checkpoint。

### 6.5 前后端同步

1. 统一 DSL / Plan / Task Board 放入 Sync Center。
2. 前端、后端、后台前端分别认领任务。
3. API 变更必须写入 Contract。
4. 每次完成任务后 push 同步快照。
5. 另一侧 pull inbox，确认依赖变化后继续开发。

### 6.6 GitHub PR 闭环

1. 从 AT-T 或 REQ 创建 branch。
2. 自动生成 PR draft。
3. PR 绑定 REQ / DSL / Plan / AT-T / Verify / Contract / Score / Rollback。
4. Review 结果记录到 Review Gate。
5. CI 通过后进入 Release Gate。
6. Release 记录版本、环境、回滚方案和验证证据。

## 7. 功能模块

### 7.1 Dashboard

- 项目总览
- 当前 DSL 状态
- Plan / AT-T 看板
- 多 Agent 状态
- 前后端同步状态
- Contract 状态
- Bug 状态
- Verify 结果
- Git / PR / Release 状态
- Score 和风险

### 7.2 DSL Review

- 展示多文件 DSL。
- 显示来源 Reference。
- 支持评论、确认、驳回、变更。
- DSL 未确认时阻止业务代码任务开始。

### 7.3 Plan Board

- 支持按前端、后台前端、后端、Fullstack、QA、Ops 过滤。
- 支持任务依赖图。
- 支持任务拆分、合并、变更回写。
- 任务开始前必须有需求确认记录。

### 7.4 Contract Center

- OpenAPI 编辑/查看。
- API changelog。
- Mock server 配置。
- Contract test 记录。
- Schema diff。
- 破坏性变更提醒。

### 7.5 Agent Coordination

- Agent 注册。
- 任务 claim lock。
- Heartbeat。
- 过期锁提醒。
- 路径冲突检测。
- Handoff 和 Review。

### 7.6 GitHub PR / CI / Release

- 分支命名建议。
- PR draft 生成。
- PR checklist。
- Review gate。
- CI 状态采集。
- Release record。
- Rollback 记录。

### 7.7 Score & Recovery

- 交付评分：需求覆盖、DSL/Plan、任务确认、验证、Bug、文件索引、Contract、Git/Release、Handoff。
- 恢复路径：context、plan、sync、failed task、conflict、rollback。

## 8. 技术方案建议

### 8.1 V1 技术栈

| 层 | 建议 |
|----|------|
| 前端 | Next.js + React + TypeScript |
| UI | Tailwind + shadcn/ui |
| 图谱 | React Flow |
| 表格 | TanStack Table |
| 本地数据 | SQLite |
| ORM | Prisma |
| 文件监听 | chokidar |
| Git | simple-git |
| Markdown | unified / remark |
| OpenAPI | swagger-parser / openapi-diff |
| 命令执行 | Node child_process 调用 `scripts/aw` |

### 8.2 架构

```text
Engineering Harness
├─ Web Dashboard
├─ Harness API
├─ Local SQLite
├─ File Watcher
├─ AW CLI Adapter
├─ GitHub Adapter
├─ Agent Adapter
└─ Sync Center Adapter
```

## 9. 数据存储策略

V1 建议采用“双写但 Markdown 为真源”的方式：

- Markdown / YAML / JSON 继续作为项目可交接真源。
- SQLite 作为 UI 查询、索引、过滤、状态缓存。
- 文件变化由 watcher 解析并同步到 SQLite。
- UI 修改后回写 Markdown。

## 10. MVP 范围

### V0.1

- 读取现有 agent-workflow 项目。
- 展示 DSL、Plan、AT-T、Bug、Handoff、File Index。
- 展示 Gate / Score 状态。
- 不做复杂编辑。

### V0.2

- 支持 DSL 审阅和确认。
- 支持 Plan / AT-T 确认。
- 支持 Bug 录入。
- 支持 Score 生成。

### V0.3

- 支持 Contract Center。
- 支持 Agent claim / heartbeat / release。
- 支持 Hook / Gate 自动检查。

### V0.4

- 支持多项目同步中心。
- 支持 GitHub PR draft / review / release gate。
- 支持恢复流程。

## 11. 成功指标

| 指标 | 目标 |
|------|------|
| DSL 未审业务代码改动阻断率 | 100% |
| AT-T 任务确认覆盖率 | ≥ 95% |
| 验证证据覆盖率 | ≥ 90% |
| Bug 留痕覆盖率 | 100% |
| File Index 更新及时率 | ≥ 90% |
| 前后端 Contract 变更同步率 | ≥ 95% |
| PR Trace 完整率 | ≥ 90% |
| Handoff 完整率 | ≥ 95% |

## 12. 风险

- 过度流程化导致开发变慢：需要提供轻量模式和严格模式。
- 自动 Gate 误报：必须支持例外记录，但例外必须可追踪。
- 多 Agent 锁管理复杂：V1 先做文件锁和心跳，不做分布式锁服务。
- 与不同 IDE 集成复杂：V1 先通过 CLI 和提示词适配，不做深度插件。
- Markdown 与 SQLite 双写冲突：必须明确 Markdown 为真源。

## 13. 与 agent-workflow Skill 的关系

agent-workflow Skill 是协议层和命令层；Engineering Harness 是可视化控制层。

| agent-workflow | Engineering Harness |
|----------------|---------------------|
| CLI / 文档 / 模板 | Dashboard / API / 数据库 |
| 规则定义 | 规则执行和展示 |
| Markdown 真源 | UI 读写真源 |
| Agent 提示词 | Agent 任务控制台 |
| 手动命令 | 自动 Gate / Watcher |

## 14. 第一版开发建议

第一版先做本地工具，不做云端 SaaS：

1. 初始化 Next.js 项目。
2. 读取一个已安装 agent-workflow 的项目路径。
3. 解析 `docs/` 文件生成 Dashboard。
4. 调用 `scripts/aw status --json` 和 `scripts/aw capabilities --json`。
5. 实现 DSL / Plan / Task / Bug / Contract / Score 页面。
6. 实现 `Run Gate` 按钮。
7. 实现 GitHub PR draft 页面。
8. 实现 Sync Center 页面。

## 15. 参考资料包

本 PRD 同目录建议包含：

- `agentworkflow-source/`：现有 Skill / CLI 源码快照。
- `manual/`：当前 HTML 使用手册。
- `templates/`：DSL、Plan、Contract、GitHub、Hooks、Score、Recovery 模板。
- `scripts/`：aw CLI 脚本，供 Harness 调用。
