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
| 写代码 | `AICODING_WORKFLOW.md` + `docs/plans/` 当前 AT-T* |
| 换会话 | `docs/handoff/PROJECT_HANDOFF.md` |

## 工具适配（可选）

见 [`adapters/README.md`](./adapters/README.md) — Cursor / Claude / Codex / Copilot / 通用对话。
