# Claude Code

## 挂载

- 仓库根 **`CLAUDE.md`** → 指向或包含 `agent-workflow/CLAUDE.md` 摘要 + 链接 [`INVOCATION.md`](../INVOCATION.md)
- 可选用户级：`~/.claude/CLAUDE.md` 写「默认先读各项目 INVOCATION」

## 触发

对话中说：`按 agent-workflow` / `aw init` / `生成 DSL` — Agent 读 `agent-workflow/INVOCATION.md`。

## 脚本

```bash
./scripts/aw init
./scripts/aw dsl
```

Claude Code 可/bash 执行上述命令（若环境允许）。
