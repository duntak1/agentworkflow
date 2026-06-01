# qclaw

qclaw 使用仓库内薄规则入口，流程真源仍是 `agent-workflow/INVOCATION.md`。

```bash
./scripts/aw adapters --qclaw
# -> .qclaw/agent-workflow.md
```

qclaw 适合被记录为外部或应用内 Agent runtime：本地可读写仓库时用 `local-files`，跨应用协作时用 `sync-center` 或 `handoff-only`。

Agent runtime binding:

```bash
./scripts/aw agents bind tester-agent --runtime qclaw --provider longjia --interface api --sync-mode handoff-only
```
