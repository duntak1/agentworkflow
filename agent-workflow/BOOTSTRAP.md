# 复用到其他仓库（工具无关）

## 方式 A：拷贝文档包 + 脚本（推荐 · 任意 AI 工具）

1. 复制 **`agent-workflow/`** 到目标仓库根目录。
2. 复制 **`scripts/`**（含 **`aw`**、`init-project.sh`、`draft-dsl.sh` 等）。
3. 执行：`chmod +x scripts/aw scripts/*.sh && ./scripts/aw init`
4. 根目录入口（按需，见 [`adapters/`](./adapters/)）：
   - **Claude Code** → `CLAUDE.md` 链到 `agent-workflow/CLAUDE.md` + `INVOCATION.md`
   - **Codex** → `AGENTS.md` 链到 `agent-workflow/AGENTS.md`
   - **Copilot** → `./scripts/install-aw-adapters.sh --copilot`
   - **一键多 IDE** → `./scripts/aw adapters --all`（Claude/Codex/Copilot/Cursor/Windsurf/Cline/Continue/QoderWork/TraeIDE/Lingma/OpenClaw/qclaw）
   - **国产 / 龙嘉组合** → `./scripts/aw adapters --china`
   - **无规则文件** → `./scripts/aw paste session` 贴入对话
5. 填写 `docs/PROJECT_CONFIG.md`。

## 方式 B：仅对话 + 粘贴（无 IDE 规则）

1. `./scripts/aw init`
2. `./scripts/aw paste session` → 复制到 ChatGPT / 企业 IM / 任意 Agent
3. `@agent-workflow/INVOCATION.md` 与 `reference/` 材料

## 不要依赖单一 IDE

- **禁止**把流程真源只放在 `.cursor/` 或某一厂商私有目录。
- **真源**始终在 Git 的 `agent-workflow/` + `scripts/aw`。

## init 后目录

```
reference/
docs/dsl/
docs/plans/
docs/requirements/
docs/handoff/
docs/PROJECT_CONFIG.md
```

## 不要拷贝

- 业务 `src/`、其他项目专有 `reference/` 内容（按需新建）
