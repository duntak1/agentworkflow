# Agent Registry（长期 Agent 身份登记）

用途：登记长期存在的 Agent worker identity。这里记录“这个 Agent 是谁、长期职责和边界是什么”，不等同于某个 REQ / AT-T 的一次性 assignment。

## Registry Rules

- `aw agents register` 记录长期身份。
- `aw agents assign` 记录具体任务或阶段里的职责分配。
- `aw agents claim` 记录具体任务锁。
- 默认 `unregister` 会把 Agent 标记为 `retired`，保留历史追溯。

