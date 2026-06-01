# 工具适配层（可选）

**流程真源（工具无关）：** [`../INVOCATION.md`](../INVOCATION.md) · [`../PRODUCT_INPUT_WORKFLOW.md`](../PRODUCT_INPUT_WORKFLOW.md) · `scripts/aw`

各工具只需让 Agent **能读到** 上述真源；下表为常见挂载路径。

## 一键安装（业务仓库根）

```bash
./scripts/install-aw-adapters.sh --all
# 或按需：--claude --codex --copilot --cursor --windsurf --cline --continue --qoderwork --trae --lingma --openclaw --qclaw
# 国产 / 龙嘉组合：--china
```

也可：`./scripts/aw adapters --all`

## 支持矩阵

| 工具 / 环境 | 适配文件 | 说明 |
|-------------|----------|------|
| **任意对话** | `aw paste session` | [generic-chat.md](./generic-chat.md) |
| **Claude Code** | `CLAUDE.md` | [claude-code.md](./claude-code.md) |
| **OpenAI Codex** | `AGENTS.md` | [codex.md](./codex.md) |
| **Codex Context** | Handoff / Memory 新会话连续性 | [codex-context/README.md](./codex-context/README.md) |
| **GitHub Copilot** | `.github/copilot-instructions.md` | [copilot.md](./copilot.md) |
| **Cursor** | `.cursor/rules/*.mdc` + 可选 Skill | [cursor.md](./cursor.md) |
| **Windsurf** | `.windsurfrules` | [windsurf.md](./windsurf.md) |
| **Cline** | `.clinerules` | [cline.md](./cline.md) |
| **Continue** | `.continue/rules/` | [continue.md](./continue.md) |
| **QoderWork / Qoder** | `.qoderwork/rules/agent-workflow.md` | [qoderwork.md](./qoderwork.md) |
| **TraeIDE** | `.trae/rules/agent-workflow.md` | [traeide.md](./traeide.md) |
| **Lingma / 通义灵码** | `.lingma/rules/agent-workflow.md` | [lingma.md](./lingma.md) |
| **OpenClaw** | `.openclaw/agent-workflow.md` | [openclaw.md](./openclaw.md) |
| **qclaw** | `.qclaw/agent-workflow.md` | [qclaw.md](./qclaw.md) |
| **VS Code 组合** | 见上 | [vscode.md](./vscode.md) |

## 原则

1. **禁止**把流程真源只写在某一 IDE 私有目录而不进 `agent-workflow/`。
2. Cursor Skill、`copilot-instructions`、`.windsurfrules` 等均为 **指针**，可复制、可审计。
3. 换工具时：安装对应适配器 + 继续用同一套 `docs/dsl/`、`docs/plans/`、`scripts/aw`。

## Cursor Skill（可选）

个人 Skill 仅为 Cursor 的薄封装；其他工具不需要安装 Skill。见 [cursor.md](./cursor.md) 与仓库 [PUBLISH.md](../../PUBLISH.md)。
