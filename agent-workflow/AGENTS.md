# AGENTS.md（Codex / 多 Agent 路由）

**默认规则面：** [`AGENT_RULES.md`](./AGENT_RULES.md)  
**详版栈与禁令：** [`CLAUDE.md`](./CLAUDE.md)  
**阶段 0（Reference → DSL → Plan）：** [`PRODUCT_INPUT_WORKFLOW.md`](./PRODUCT_INPUT_WORKFLOW.md)  
**研发协作（A–E）：** [`AICODING_WORKFLOW.md`](./AICODING_WORKFLOW.md)  
**质量闭环：** [`VERSION_CHANGELOG_QUALITY_LOOP.md`](./VERSION_CHANGELOG_QUALITY_LOOP.md)

## 快速路由

| 用户意图 | 先读 |
|----------|------|
| 任意工具 / 入口 | [`INVOCATION.md`](./INVOCATION.md) |
| 新项目 / 初始化 | `PRODUCT_INPUT_WORKFLOW.md` → `./scripts/aw init` |
| 生成 DSL | `./scripts/aw dsl` + `templates/prompts/PROMPT-DSL.md` |
| 生成 Plan | `./scripts/aw plan <dsl.md>`（DSL 须 `已审`） |
| 执行研发任务 / 开始开发 / 做下一个任务 | 先 `./scripts/aw next` → `./scripts/aw task brief <AT-T>` → 追问并等待工程师确认 |
| 写代码 | 仅在 `task confirm`（范围 / 验收 / 非目标齐全）+ `context gate` + `task start` 后，使用 `aw paste task` 的单任务提示 |
| 换会话 | `docs/handoff/PROJECT_HANDOFF.md` |

## 研发硬闸门

当工程师说“执行研发任务 / 开始开发 / 做下一个任务”时，Agent 不得直接写代码。必须先运行或输出 `./scripts/aw next` 和 `./scripts/aw task brief <AT-T>`，向工程师确认需求、范围、验收、异常态、联动边界、非目标和风险。工程师明确确认后，依次执行：

```bash
./scripts/aw task confirm <AT-T> "已确认：范围=...；验收=...；非目标=..."
./scripts/aw context plan --task <AT-T>
./scripts/aw context gate --task <AT-T>
./scripts/aw task start <AT-T>
./scripts/aw paste task
```

未完成上述链路时，禁止读取大范围项目文件、禁止生成编码提示、禁止修改业务代码。

## 工具适配（可选）

见 [`adapters/README.md`](./adapters/README.md) — Claude / Codex / Copilot / Cursor / Windsurf / Cline / Continue / QoderWork / TraeIDE / Lingma / OpenClaw / qclaw / 通用对话。
