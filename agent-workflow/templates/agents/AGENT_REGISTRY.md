# Agent Registry（长期 Agent 身份登记）

用途：登记长期存在的 Agent worker identity。这里记录“这个 Agent 是谁、长期职责和边界是什么”，不等同于某个 REQ / AT-T 的一次性 assignment。

## Registry Rules

- `aw agents register` 记录长期身份。
- `aw agents assign` 记录具体任务或阶段里的职责分配。
- `aw agents claim` 记录具体任务锁。
- `aw agents bind` 记录 Agent 实际运行的工具 / provider / workspace / interface / sync mode。
- `aw agents bindings` 或 `aw agents list --bindings` 查询当前 runtime/tool binding。
- 默认 `unregister` 会把 Agent 标记为 `retired`，保留历史追溯。
- `aw agents gate --strict` 会阻断未注册 Agent、active Agent 缺少 runtime/tool binding、任务锁冲突和 allowed paths 重叠。

## Binding Fields

- Runtime: `codex` / `claude-code` / `cursor` / `cline` / `windsurf` / `copilot` / `continue` / `qoderwork` / `qoder` / `trae` / `traeide` / `lingma` / `openclaw` / `qclaw` / `generic-chat` / `manual`
- Provider: `openai` / `anthropic` / `github` / `cursor` / `aliyun` / `longjia` / `other`
- Interface: `cli` / `desktop` / `web` / `ide` / `api` / `manual`
- Sync mode: `local-files` / `sync-center` / `handoff-only` / `manual-paste` / `none`
- Binding status: `active` / `paused` / `unknown`
