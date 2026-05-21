# 协作与工作流

流程类 Markdown **正文**在 **`agent-workflow/`**（可复制到其他项目）。

→ **[调用真源（工具无关）](../../agent-workflow/INVOCATION.md)** · **[阶段 0](../../agent-workflow/PRODUCT_INPUT_WORKFLOW.md)** · **[脚本 aw](../../scripts/README.md)**

## 关键命令

| 命令 | 含义 |
|------|------|
| `aw dsl` / `aw plan` | 打印 prompt |
| `aw approve dsl` / `aw approve plan` | 将元数据标为 **已审** / **可执行** |
| `aw confirm <dsl> <plan>` | DSL **已审** + Plan **可执行** → 任务确认 + `ENGINEERING_INDEX.md` |
| `aw index` | 仅扫描刷新索引路径表（**不**等同任务确认） |
| `aw next` | 查看下一 AT-T*（须已有 Plan） |

跨会话：[handoff/](../handoff/) · [requirements/](../requirements/) · [dsl/](../dsl/) · [plans/](../plans/)
