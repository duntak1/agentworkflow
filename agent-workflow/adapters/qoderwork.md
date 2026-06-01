# QoderWork / Qoder

QoderWork / Qoder 使用仓库内薄规则入口，流程真源仍是 `agent-workflow/INVOCATION.md`。

```bash
./scripts/aw adapters --qoderwork
# -> .qoderwork/rules/agent-workflow.md
```

如果当前版本的 Qoder 提供官方项目规则目录，可把该文件内容挂载到对应规则入口；不要把完整流程复制成第二份真源。

Agent runtime binding:

```bash
./scripts/aw agents bind frontend-agent --runtime qoderwork --provider other --interface ide --sync-mode local-files
```
