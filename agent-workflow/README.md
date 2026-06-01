# agent-workflow（通用 AI 交付工作流包）

可整夹拷贝到**任意仓库、任意 AI 工具**（Claude Code / Codex / Copilot / Cursor / Windsurf / Cline / Continue / QoderWork / TraeIDE / Lingma / OpenClaw / qclaw / 纯对话）。

**调用真源：** [`INVOCATION.md`](./INVOCATION.md) · 工具适配见 [`adapters/`](./adapters/)

**本地教程：** [`AGENTWORKFLOW_MANUAL.html`](./AGENTWORKFLOW_MANUAL.html) 可直接用浏览器打开，适合工程师系统学习完整流程。

## 五分钟上手

```bash
# 在目标仓库根目录
chmod +x scripts/aw scripts/*.sh
./scripts/aw setup
./scripts/aw demo
```

1. 人类：编辑 `reference/manifest.yaml`，材料放入 `reference/inputs/`
2. `./scripts/aw dsl` → 将 prompt 贴入**任意** Agent 对话，产出写入 `docs/dsl/`
3. 人类：DSL 元数据 **状态 → 已审**
4. `./scripts/aw plan docs/dsl/DSL_DRAFT.md`
5. 按 [`AICODING_WORKFLOW.md`](./AICODING_WORKFLOW.md) 阶段 A→E 研发
6. 高风险、依赖、安全、服务边界、发布相关工作同步用 `aw audit` / `aw policy` / `aw security` / `aw service-catalog` / `aw release` 留痕

前后端分成两个项目时，见 [`CROSS_PROJECT_SYNC.md`](./CROSS_PROJECT_SYNC.md)，用 `aw sync init|pull|push` 通过共享 Harness 同步两个 Agent 的状态。

## 文档地图

| 文件 | 用途 |
|------|------|
| [`AGENTWORKFLOW_MANUAL.html`](./AGENTWORKFLOW_MANUAL.html) | 暗色本地 HTML 使用手册，含流程图、角色说明、命令与对话模板 |
| [`PRODUCT_INPUT_WORKFLOW.md`](./PRODUCT_INPUT_WORKFLOW.md) | 阶段 0：Reference → DSL → Plan |
| [`CROSS_PROJECT_SYNC.md`](./CROSS_PROJECT_SYNC.md) | 前后端分仓 / 两项目 Agent 同步 |
| [`AICODING_WORKFLOW.md`](./AICODING_WORKFLOW.md) | 阶段 A–E：Karpathy 协作 |
| [`VERSION_CHANGELOG_QUALITY_LOOP.md`](./VERSION_CHANGELOG_QUALITY_LOOP.md) | 质量、§11、CHANGELOG |
| [`AGENT_RULES.md`](./AGENT_RULES.md) | 精简规则（→ `.cursor/rules`） |
| [`CLAUDE.md`](./CLAUDE.md) | 栈与禁令详版 |
| [`AGENTS.md`](./AGENTS.md) | Codex 路由 |
| [`INVOCATION.md`](./INVOCATION.md) | **工具无关调用真源** |
| [`adapters/`](./adapters/) | Claude / Codex / Copilot / Cursor / Windsurf / Cline / Continue / QoderWork / TraeIDE / Lingma / OpenClaw / qclaw / 通用对话 |
| [`BOOTSTRAP.md`](./BOOTSTRAP.md) | 复用到其他仓库 |
| [`templates/`](./templates/) | init 拷贝用模板，含 audit / policy / security / service catalog / release |
| [`INDEX.md`](./INDEX.md) | 文件索引 |

## 复用到其他仓库

见 [`BOOTSTRAP.md`](./BOOTSTRAP.md)。

## 可选：Cursor Skill

`~/.cursor/skills/agent-workflow/`（别名 `aw-delivery`）仅为 **Cursor 薄适配**；见 [`adapters/cursor.md`](./adapters/cursor.md)。
