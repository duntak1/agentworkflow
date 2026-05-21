# Cursor：上下文将满时自动交接（Hooks）

> **仅适用于 Cursor，且为可选能力。** 本仓库**默认不包含** `.cursor/hooks.json`（避免绑定单一 IDE）。需要时按 [`agent-workflow/adapters/cursor-hooks/README.md`](../../agent-workflow/adapters/cursor-hooks/README.md) 自行安装。

与 Cursor 聊天界面中的 **Context used** 指示器配合：在 **即将触发上下文压缩**（`preCompact`）且占用达到阈值时，可自动：

1. 记录一行到 `docs/handoff/compaction-events.log`
2. 覆盖生成 `docs/handoff/LAST_AUTO_SNAPSHOT.md`（调用 `scripts/draft-handoff.sh`）
3. 写入 `docs/handoff/PASTE_IN_NEW_CHAT.txt`
4. 通过 Hook 的 **`user_message`** 弹出预警
5. **需求占位（可选）**：`scripts/new-req.sh` 生成 `REQ-*-precompact-context.md`（建议关闭或事后标 **作废**）

手动交接始终可用：[`HANDOFF_GUIDE.md`](./HANDOFF_GUIDE.md)、`./scripts/aw handoff`。

---

## 默认阈值（安装 hooks 后）

- **`CONTEXT_WARN_THRESHOLD_PERCENT`** 默认为 **`95`**。
- 仅在 `preCompact` 的 **`context_usage_percent` ≥ 阈值** 时执行上述动作。

**`AUTO_REQ_ON_PRECOMPACT`** 默认为开启；meta 仓建议设为 **`0`**，避免刷屏占位 REQ。

---

## 限制说明

| 点 | 说明 |
|----|------|
| **触发时机** | 依赖 Cursor 派发 `preCompact`；百分比以 Cursor 为准。 |
| **新开窗口** | Hook **无法**替你点击「新对话」；仅 `user_message` 提示。 |
| **压缩含义** | Cursor 做会话摘要；仓库侧做 **Handoff 草稿落盘**。 |

---

## 变更记录

- 文档：明确 hooks **非默认入库**；占位 REQ 应标作废或删除。
- 初版设计：`preCompact` + `draft-handoff.sh` 联动（见 adapters/cursor-hooks）。
