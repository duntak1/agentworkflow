# Cursor Hooks（可选安装）

本目录说明如何在**需要**时启用 preCompact 自动交接；**不**随 `aw install` 默认写入目标仓库。

## 安装步骤（概要）

1. 在仓库根创建 `.cursor/hooks.json`（参考 Cursor 官方 Hooks 文档）。
2. 注册 `preCompact` → 调用 `scripts/draft-handoff.sh` 并写 `docs/handoff/LAST_AUTO_SNAPSHOT.md`。
3. （可选）`AUTO_REQ_ON_PRECOMPACT=0` 关闭自动 REQ，避免 `REQ-*-precompact-context` 占位文件。
4. 重启 Cursor，在 **Settings → Hooks** 确认生效。

## 与本包的关系

| 能力 | 默认（无 hooks） | 安装 hooks 后 |
|------|------------------|---------------|
| 流程真源 | `agent-workflow/INVOCATION.md` | 相同 |
| 手动交接 | `./scripts/aw handoff` | 相同 |
| 自动快照 | 无 | `LAST_AUTO_SNAPSHOT.md` |
| preCompact REQ | 无 | 可选（建议关闭） |

详见 [`docs/handoff/CURSOR_CONTEXT_HOOK.md`](../../../docs/handoff/CURSOR_CONTEXT_HOOK.md)。
