# TraeIDE

TraeIDE 使用仓库内薄规则入口，流程真源仍是 `agent-workflow/INVOCATION.md`。

```bash
./scripts/aw adapters --trae
# -> .trae/rules/agent-workflow.md
```

若团队使用 Trae 的自定义规则或项目知识库能力，请让该入口指向 `agent-workflow/INVOCATION.md`、`agent-workflow/AGENT_RULES.md` 和 `docs/PROJECT_CONFIG.md`，避免复制整套流程。

Agent runtime binding:

```bash
./scripts/aw agents bind frontend-agent --runtime trae --provider other --interface ide --sync-mode local-files
```
