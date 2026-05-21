# Agent 约定文档 — 如何使用（工具无关）

**流程调用真源：** [`../INVOCATION.md`](../INVOCATION.md) + 仓库 `./scripts/aw`  
**各工具挂载：** [`../adapters/README.md`](../adapters/README.md)

本文档与 **具体厂商 / IDE 解耦**；约定文件在 **`agent-workflow/`**（进 Git）。团队按工具将入口 **指向** 真源，而非把流程只写在 IDE 私有目录。


| 文件                   | 角色                                                                                 |
| -------------------- | ---------------------------------------------------------------------------------- |
| `**CLAUDE.md`**      | **仓库根**：入口链接。**正文**：`agent-workflow/CLAUDE.md`（详版真源：栈、禁令、SOP、命令）。**Claude Code** 等通常读仓库根的该文件名。 |
| `**AGENTS.md`**      | **仓库根**：Codex 等默认入口。**正文**：`agent-workflow/AGENTS.md`。**Codex 建议同时纳入包内 `AGENT_RULES.md`**。 |
| `**AGENT_RULES.md`** | **仓库根**：入口。**正文**：`agent-workflow/AGENT_RULES.md`。优先挂载到 IDE「项目规则」。                     |
| `**README.md`**（根目录） | **短入口**。**团队真源正文**：`agent-workflow/REPOSITORY.md`。与包内 `CHANGELOG.md`、`agent-workflow/` 配套。              |


---

## 各工具常见挂载方式（按需选用）

以下为常见做法，**以各工具官方文档为准**；更新时只改仓库内上述 Markdown，再在 IDE 里刷新或重新加载。

- **Claude Code**：默认查找仓库根 `CLAUDE.md`（本仓库为入口，**正文在 `agent-workflow/CLAUDE.md`**）；用户级 `~/.claude/CLAUDE.md`；支持与 `CLAUDE.md` 配套的 `@import`（见官方说明）。
- **OpenAI Codex**：默认查找仓库根 `AGENTS.md`（入口，**正文在文档包**）；全局 `~/.codex/AGENTS.md`；建议上下文附加 **`agent-workflow/AGENTS.md`** 与 **`AGENT_RULES.md`**（见 [AGENTS.md 指南](https://developers.openai.com/codex/guides/agents-md)）。
- **GitHub Copilot**：仓库 `.github/copilot-instructions.md`（或当前产品要求的文件名），可将包内 `AGENT_RULES.md` / `CLAUDE.md` 摘要粘贴或脚本同步进去。
- **Cursor**：在项目根创建 `**.cursor/rules/`** 下的规则文件；**优先复制包内 `agent-workflow/AGENT_RULES.md`**（比整篇 `CLAUDE.md` 省上下文）；规则已在 Active Rules 时，对话里不必重复 `@AGENT_RULES.md`。与包内 `CLAUDE.md` **语义对齐**。
- **其他编辑器 / 内部平台**：将包内 `AGENT_RULES.md` 或 `CLAUDE.md` 全文作为「项目级系统提示」上传或引用。

---

## 同步原则

1. **语义单一真源**：以 **`agent-workflow/CLAUDE.md`** 为详版；仓库根 `CLAUDE.md` / `AGENTS.md` / `AGENT_RULES.md` 为 **入口**，修改栈 / 禁令后 **入口与正文同步**。
2. **禁止只有 Cursor 副本**：不要把约定只写在某一 IDE 私有路径而不进 Git；应至少在 **`agent-workflow/`** 保留正文，并在根目录保留可被工具发现的入口文件名（若团队约定如此）。

