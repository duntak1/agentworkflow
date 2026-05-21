# 会话交接（Handoff）

用于**上下文压缩**：换模型、新开对话、隔天继续时，先把「机器记不住的」固化为 Markdown。

| 文件 | 用途 |
|------|------|
| [`HANDOFF_GUIDE.md`](./HANDOFF_GUIDE.md) | 如何压缩上下文、何时更新、与 Claude Code compact 类比 |
| [`PROJECT_HANDOFF.md`](./PROJECT_HANDOFF.md) | **当前项目进度真源（须定期覆盖更新）** |
| [`AI_BUG_LOG.md`](./AI_BUG_LOG.md) | **会话内 Bug / 测试失败流水**（Agent 见 `AGENT_RULES`：须自动追加一行） |
| [`CURSOR_CONTEXT_HOOK.md`](./CURSOR_CONTEXT_HOOK.md) | **Cursor**：上下文 ≥95%（约剩 5%）触发 `preCompact` 时自动写快照并预警 |
| `LAST_AUTO_SNAPSHOT.md` | Hook 自动生成（需合并进 `PROJECT_HANDOFF.md`） |
| `PASTE_IN_NEW_CHAT.txt` | Hook 生成的短引导（指向下方模板文件） |
| [`NEW_CHAT_PASTE_TEMPLATE.md`](./NEW_CHAT_PASTE_TEMPLATE.md) | **Vue 前端新开会话：整段可复制首条消息**（人类维护「下一步」） |

与 [`docs/requirements/`](../requirements/) 配合：Handoff 回答「现在在哪儿」；需求单回答「提过什么、做到哪」。

快速生成草稿：

```bash
./scripts/aw handoff "本轮目标" > /tmp/PROJECT_HANDOFF.md
```

人工审阅后可直接写入并检查：

```bash
./scripts/aw handoff "本轮目标" --write
./scripts/aw handoff --check
```

`--write` 会先备份旧的 `PROJECT_HANDOFF.md`，再覆盖写入；`--check` 用于新开会话前确认交接快照完整。不要把完整聊天记录、长日志或 secret 写入 handoff。
