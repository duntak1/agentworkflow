# Cursor（可选 · 非唯一入口）

Cursor 只是支持的 IDE 之一。无 Cursor 时用 [`generic-chat.md`](./generic-chat.md) 或其他 [适配器](./README.md)。

## 项目规则（推荐）

```bash
./scripts/aw adapters --cursor
# → .cursor/rules/agent-workflow.mdc
```

## 个人 Skill（可选）

```bash
./scripts/sync-skill.sh   # 仅 Cursor：~/.cursor/skills/agent-workflow/
```

业务仓仍须 `aw install .` 将 `agent-workflow/` 纳入 Git；Skill 不能替代仓库内真源。

## 触发

与 [`INVOCATION.md`](../INVOCATION.md) 一致：`按 AI 工作流` · `aw status` · `生成 DSL`。
