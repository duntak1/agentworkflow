# Engineering Index（工程师索引）

> **自动生成：** `aw confirm` = 任务确认并刷新索引；`aw index` = 仅扫描刷新路径表（**不**等同任务确认）。人类可在各表格末尾手工追加行。

## 读者声明（重要）

- **仅供人类工程师使用。** 本文件用于在仓库里快速找到 **变更记录、需求、Bug、测试、CI 执行、交接进度、安全** 等**交付向**路径。
- **请勿给 AI 读：** 不要把本文件加入 Agent / Codex / Copilot / Cursor 的上下文，不要 `@ENGINEERING_INDEX.md`，也不要写入 IDE「项目规则」。协作与编码约定请以仓库根 **`CLAUDE.md` / `AGENTS.md` / `AGENT_RULES.md`**（入口）及 **`agent-workflow/`** 内政策正文为准。
- **本索引刻意不收「规则类」文档**（例如：详细协作流程、编码禁令全文、Hook/门禁细则、Agent 挂载说明、§11 全文约定等）。需要时请通过上述 Agent 入口或 [`agent-workflow/REPOSITORY.md`](./agent-workflow/REPOSITORY.md) 中的文档导航查找。

---

## 任务快照

| 字段 | 内容 |
|------|------|
| **快照类型** | {{SNAPSHOT_KIND}} |
| **索引刷新** | {{INDEX_REFRESH_AT}} |
| **任务确认** | {{TASK_CONFIRMED_AT}} |
| **关联 DSL** | {{DSL_FILE}} |
| **DSL 状态** | {{DSL_STATUS}} |
| **关联 Plan** | {{PLAN_FILE}} |
| **Plan 状态** | {{PLAN_STATUS}} |

---

## 快速入口

| 用途 | 路径 |
|------|------|
| **本索引** | [`ENGINEERING_INDEX.md`](./ENGINEERING_INDEX.md) |
| **仓库根说明（短）** | {{ROW_README}} |
| **团队真源** | [`agent-workflow/REPOSITORY.md`](./agent-workflow/REPOSITORY.md) |
| **项目配置（栈 / 验证命令）** | {{ROW_PROJECT_CONFIG}} |
| **项目文件索引（人类维护）** | {{ROW_FILE_INDEX}} |
| **工作流调用（工具无关）** | [`agent-workflow/INVOCATION.md`](./agent-workflow/INVOCATION.md) |

---

## 更新日志

| 用途 | 路径 |
|------|------|
| **变更记录正文** | [`agent-workflow/CHANGELOG.md`](./agent-workflow/CHANGELOG.md) |
| **根目录入口** | {{ROW_CHANGELOG}} |

---

## Reference / DSL / Plan（阶段 0）

| 用途 | 路径 |
|------|------|
| **人类参考材料区** | [`reference/README.md`](./reference/README.md) |
| **输入清单** | [`reference/manifest.yaml`](./reference/manifest.yaml) |
| **阶段 0 流程** | [`agent-workflow/PRODUCT_INPUT_WORKFLOW.md`](./agent-workflow/PRODUCT_INPUT_WORKFLOW.md) |
| **统一 CLI** | [`scripts/README.md`](./scripts/README.md) · `./scripts/aw` |

## DSL / 页面说明

| 用途 | 路径 |
|------|------|
| **目录说明** | [`docs/dsl/README.md`](./docs/dsl/README.md) |
{{DSL_ROWS}}

---

## 研发计划

| 用途 | 路径 |
|------|------|
| **计划目录** | [`docs/plans/README.md`](./docs/plans/README.md) |
{{PLAN_ROWS}}

---

## 需求（REQ）

| 用途 | 路径 |
|------|------|
| **需求总表** | [`docs/requirements/INDEX.md`](./docs/requirements/INDEX.md) |
| **新建 REQ 模板** | [`docs/requirements/_TEMPLATE.md`](./docs/requirements/_TEMPLATE.md) |
{{REQ_ROWS}}

---

## Bug / 缺陷

| 用途 | 路径 |
|------|------|
| **会话 Bug / 测试失败流水** | [`docs/handoff/AI_BUG_LOG.md`](./docs/handoff/AI_BUG_LOG.md) |
{{ROW_BUG_ISSUE}}

---

## 测试与质量（用例与 PR）

| 用途 | 路径 |
|------|------|
| **书面用例目录** | [`docs/quality/test-plans/README.md`](./docs/quality/test-plans/README.md) |
| **书面用例索引（TP）** | [`docs/quality/test-plans/INDEX.md`](./docs/quality/test-plans/INDEX.md) |
| **`docs/quality/`** | [`docs/quality/README.md`](./docs/quality/README.md) |
{{TP_ROWS}}
{{ROW_PR_TEMPLATE}}

---

## CI 与本地校验脚本

| 用途 | 路径 |
|------|------|
{{CI_ROWS}}
| **工作流 CLI** | [`scripts/aw`](./scripts/aw) |
| **语义版本（若存在）** | {{ROW_REPO_VERSION}} |

---

## 进度与交接 · 上下文压缩

| 用途 | 路径 |
|------|------|
| **当前进度快照** | [`docs/handoff/PROJECT_HANDOFF.md`](./docs/handoff/PROJECT_HANDOFF.md) |
| **交接指南** | [`docs/handoff/HANDOFF_GUIDE.md`](./docs/handoff/HANDOFF_GUIDE.md) |
| **自动草稿（preCompact）** | {{ROW_LAST_SNAPSHOT}} |
| **新开窗口粘贴** | {{ROW_PASTE_NEW_CHAT}} |
| **`docs/handoff/` 索引** | [`docs/handoff/README.md`](./docs/handoff/README.md) |

---

## 应用代码（若已落地）

> 业务文件级定位请维护 [`docs/FILE_INDEX.md`](./docs/FILE_INDEX.md)。新增 / 删除 / 重命名业务文件时，同步更新对应小节的一行说明。

{{APP_ROWS}}

---

## 安全

| 用途 | 路径 |
|------|------|
| **根目录摘要** | {{ROW_SECURITY_ROOT}} |
| **正文** | [`agent-workflow/SECURITY.md`](./agent-workflow/SECURITY.md) |

---

*维护（人类）：交付类新文件可手工在本索引补一行；规则类文档勿堆入。任务确认后运行 `./scripts/aw confirm` 刷新动态段。*
