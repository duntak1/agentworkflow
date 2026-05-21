# 功能测试用例（书面）

**交付闭环总览**（脚本、门禁、§11 顺序）：[`docs/quality/README.md`](../README.md)。

按 [`agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md`](../../agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md) **§11**：每个完成的功能须有**全面书面用例**，并可在 PR/Issue 中引用本目录下的 Markdown。

**脚手架**：`./scripts/aw tp new <slug> "标题"`（或 `./scripts/new-test-plan.sh`），从 [`_TEMPLATE.md`](./_TEMPLATE.md) 生成 **`TP-YYYYMMDD-NN-<slug>.md`**，并更新 **[索引 `INDEX.md`](./INDEX.md)**。

建议文件名：`YYYY-MM-简述.md` 或与 Issue 编号挂钩；**每个 TP 文件须在 `INDEX.md` 中有链接**（`scripts/check-test-plan-index.sh` / pre-commit 会校验）。

每份用例建议包含：**前置条件、主路径步骤、分支与边界、权限/角色、错误与恢复、回归要点**；并在 PR 中注明真实环境验证方式（Playwright/Cypress/手工表等）及证据链接。
