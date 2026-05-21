# Windsurf（Cascade）

## 挂载

- 项目根 **`.windsurfrules`** — 由 `./scripts/install-aw-adapters.sh --windsurf` 生成（指向 [`INVOCATION.md`](../INVOCATION.md)）

## 触发

对话：`按 agent-workflow` · `aw init` · `生成 DSL` · `aw status`

## 脚本

Windsurf 终端可执行：

```bash
./scripts/aw init
./scripts/aw status
./scripts/aw dsl
```

流程真源不在 Windsurf 私有目录，而在 Git 的 **`agent-workflow/`**。
