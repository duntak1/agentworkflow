# OpenClaw

OpenClaw 使用仓库内薄规则入口，流程真源仍是 `agent-workflow/INVOCATION.md`。

```bash
./scripts/aw adapters --openclaw
# -> .openclaw/agent-workflow.md
```

OpenClaw 若作为龙嘉应用中的 Agent 容器运行，应通过 `aw agents bind` 记录 runtime、workspace、interface 和 sync mode，便于 gate、handoff 和 dashboard 观察。

Agent runtime binding:

```bash
./scripts/aw agents bind backend-agent --runtime openclaw --provider longjia --interface api --sync-mode sync-center
```
