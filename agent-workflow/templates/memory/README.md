# Agent Memory

轻量文件化记忆层，用于跨会话保留可追踪事实、决策、偏好、模式、风险，以及经过摘要的聊天上下文。

## 目录

| 路径 | 用途 |
|------|------|
| `INDEX.md` | 活跃记忆索引 |
| `entries/` | 单条记忆正文 |
| `archive/` | 归档记忆 |

## 规则

- 只记录对后续 Agent 有复用价值的内容。
- 每条记忆必须有来源、类型、置信度和生命周期。
- 不记录 secret、token、密码、个人敏感信息。
- 可以记录聊天，但记录的是摘要、决策、待办、待确认和关联对象；不要保存完整逐字聊天。
- 写业务代码前可运行 `aw memory inject` 获取当前记忆摘要。

## 与 Handoff 的边界

| 功能 | 记录什么 | 不记录什么 |
|------|----------|------------|
| Handoff (`docs/handoff/PROJECT_HANDOFF.md`) | 当前目标、进度、阻塞、下一步 | 长期知识库 |
| Memory (`docs/memory/`) | 稳定事实、决策、偏好、流程、风险、聊天摘要 | 临时任务状态、整段 handoff、完整逐字聊天 |

## 聊天记忆

当用户希望“记住这段聊天”时，使用聊天摘要记忆：

```bash
./scripts/aw memory chat <slug> "标题" \
  --summary "这段聊天讨论了什么，以及对后续工作的意义。" \
  --decisions "已确认的决定。" \
  --todos "后续要做的事项。" \
  --open "仍待确认的问题。" \
  --related "关联 REQ / DSL / Plan / AT-T / 文件路径。"
```

聊天里形成的正式需求仍然必须写入 `docs/requirements/`；当前进度仍然写入 `docs/handoff/PROJECT_HANDOFF.md`。

从 Handoff 提炼 Memory 的标准：

- 未来多个任务会复用。
- 有明确来源，例如 DSL、Plan、REQ、PR、人工决策。
- 可以写成一句可执行/可判断的结论。
- 不包含 secret 或个人敏感信息。
