# 通用对话（无专用规则文件）

适用于：网页 ChatGPT、企业 IM 机器人、任意不支持项目规则的界面。

## 步骤

1. 仓库内执行：`./scripts/aw init`
2. 执行：`./scripts/aw paste session` → 复制输出到对话首条
3. 用 `@` / 上传附件 挂上：`agent-workflow/INVOCATION.md`、`reference/manifest.yaml`、本轮 `docs/dsl/` 或 REQ
4. DSL：`./scripts/aw dsl` → 复制 prompt 块 → 贴入对话 → 让人类保存到 `docs/dsl/`
5. Plan：`./scripts/aw plan docs/dsl/<file>.md`

## 限制

- 无自动 pre-commit / Hook；人类自行跑 `docs/PROJECT_CONFIG.md` 中的命令。
- 每次新会话需重新粘贴 `paste session` 块。
