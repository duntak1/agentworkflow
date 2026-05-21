# 质量与交付闭环

| 文档 | 用途 |
|------|------|
| [`test-plans/README.md`](./test-plans/README.md) | 书面用例约定 |
| [`test-plans/INDEX.md`](./test-plans/INDEX.md) | TP 总表 |
| [`../agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md`](../agent-workflow/VERSION_CHANGELOG_QUALITY_LOOP.md) | §11 真实环境验证 |

## 交付闭环（摘要）

1. DSL **已审** + Plan **可执行**
2. 书面用例：`./scripts/aw tp new <slug> "标题"`
3. 实现后：`docs/PROJECT_CONFIG.md` 命令 + TP 在真实环境通过
4. PR 附验证证据；CHANGELOG `[Unreleased]`
