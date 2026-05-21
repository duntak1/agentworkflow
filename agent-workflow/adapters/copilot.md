# GitHub Copilot

## 挂载

创建或更新 **`.github/copilot-instructions.md`**：

```markdown
# 项目 Agent 指令

执行研发任务前阅读：
- agent-workflow/INVOCATION.md
- agent-workflow/AGENT_RULES.md
- docs/PROJECT_CONFIG.md

DSL 未「已审」时不写业务代码。验证命令见 PROJECT_CONFIG。
```

可用 `./scripts/install-aw-adapters.sh --copilot` 生成上述文件。

## 触发

PR / Issue 或对话中引用 `@agent-workflow/INVOCATION.md`。
