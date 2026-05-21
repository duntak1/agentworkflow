# 仓库说明 / 团队真源（通用模板）

> **本仓库定位：** **agent-workflow** 通用 AI 交付工作流包（工具无关）。  
> 根目录 [`README.md`](../README.md) 为短入口。技术栈与命令见 [`CLAUDE.md`](./CLAUDE.md)、[`docs/PROJECT_CONFIG.md`](../docs/PROJECT_CONFIG.md)。

---

## 团队真源（首次立项务必填写）

```text
Issue 系统：GitHub Issues（可改为 Jira / 飞书等）
Issue ID 写法：Fixes #123 / Refs #456
版本权威字段路径：________________（例：package.json version）
合并必备 CI：GitHub Actions「CI」workflow：已启用 □ / 未启用 □
默认分支名：main □   master □   其他：________
```

本地验证命令（**同步进 [`CLAUDE.md`](./CLAUDE.md) 与 `docs/PROJECT_CONFIG.md`**）：

```text
安装：________________
Lint：________________
Test：________________
Build：________________
```

---

## 文档导航

| 路径 | 用途 |
|------|------|
| 业务仓 `ENGINEERING_INDEX.md` | **人类工程师索引**（`aw confirm` 生成，勿给 AI） |
| [`INVOCATION.md`](./INVOCATION.md) | **工具无关调用真源** |
| [`PRODUCT_INPUT_WORKFLOW.md`](./PRODUCT_INPUT_WORKFLOW.md) | 阶段 0 |
| [`AICODING_WORKFLOW.md`](./AICODING_WORKFLOW.md) | 阶段 A–E |
| [`VERSION_CHANGELOG_QUALITY_LOOP.md`](./VERSION_CHANGELOG_QUALITY_LOOP.md) | 质量闭环 §11 |
| [`docs/handoff/PROJECT_HANDOFF.md`](../docs/handoff/PROJECT_HANDOFF.md) | 交接快照 |
| [`docs/requirements/INDEX.md`](../docs/requirements/INDEX.md) | REQ 总表 |
| [`docs/dsl/README.md`](../docs/dsl/README.md) | DSL |
| [`docs/plans/README.md`](../docs/plans/README.md) | 研发计划 |
| [`../scripts/README.md`](../scripts/README.md) | `aw` CLI |

---

## 脚本

见 [`../scripts/README.md`](../scripts/README.md)。常用：`./scripts/aw init` · `aw confirm` · `aw hooks` · `aw sync-skill`

---

## 对话触发语

`按 AI 工作流` · `aw init` · `生成 DSL` · `生成 Plan` · `任务确认` · `对接进度` · `记需求`
