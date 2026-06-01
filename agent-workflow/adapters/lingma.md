# Lingma / 通义灵码

Lingma 使用仓库内薄规则入口，流程真源仍是 `agent-workflow/INVOCATION.md`。

```bash
./scripts/aw adapters --lingma
# -> .lingma/rules/agent-workflow.md
```

如果 Lingma 在当前 IDE 中通过项目规则、知识库或提示词模板读取约束，请挂载 `.lingma/rules/agent-workflow.md`，并让它继续引用仓库内真源。

Agent runtime binding:

```bash
./scripts/aw agents bind backend-agent --runtime lingma --provider aliyun --interface ide --sync-mode local-files
```
