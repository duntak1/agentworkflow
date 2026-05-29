# CONTEXT_CONFIG

> 目标：限制 AI 读代码的范围，避免无目标全仓扫描和 token 浪费。

| 字段 | 内容 |
|------|------|
| **Backend** | auto |
| **Require Context Plan Before Coding** | yes |
| **Require Affected Analysis Before Complete** | yes |
| **Max Files Per Task** | 6 |
| **Max Symbols Per Task** | 12 |
| **Max Search Queries Per Task** | 3 |
| **Max Handoff Lines** | 120 |
| **Max Sync Inbox Events** | 20 |
| **Max Reference Files Per Pass** | 3 |
| **Blocked Dirs** | .git,node_modules,dist,build,coverage,.next,.nuxt,target,vendor,tmp,logs |
| **Preferred Order** | CodeGraph -> CODE_MAP -> CODE_CONTEXT_INDEX -> FILE_INDEX -> precise rg -> engineer confirmation |

## Backend 说明

- `auto`：优先使用 CodeGraph；不可用时降级到文件索引和精准搜索。
- `codegraph`：使用预索引代码图谱查 symbol、调用链、影响范围。
- `code-map`：使用 `docs/context/CODE_MAP.md` 的模块、Symbol、路由、测试和依赖线索。
- `file-index`：使用 `docs/context/CODE_CONTEXT_INDEX.md` 和 `docs/FILE_INDEX.md`。
- `rg`：只允许精准关键词搜索，不允许全仓批量读取。

## Token 预算说明

- 默认先读摘要：`aw status --json`、`aw next`、`aw task brief`、`aw sync inbox`、`aw code-map query`、`aw context plan`。
- 不默认读取 HTML 手册、`ENGINEERING_INDEX.md`、整个 `docs/sync/inbox/`、整个同步中心或完整历史 handoff。
- 大型需求 / 设计 / 参考源码先分片：每轮最多读取 3 个 reference 文件，产出 DSL/REQ 摘要后再继续下一片。
- 超过预算前，先写明“为什么需要更多上下文、准备读哪些文件、预期回答什么问题”，等待工程师确认。

## 硬规则

- 修改业务代码前必须先生成 `docs/context/tasks/CTX-<AT-T>.md`。
- 大型 / 已有项目接入后，必须先运行 `aw code-map build` 生成 `docs/context/CODE_MAP.md`；之后再按任务生成 Context Plan。
- 只读取 Context Plan 中列出的文件；默认候选文件不等于已授权读取全文。
- 需要扩大范围时，必须写入“扩大上下文记录”并等待工程师确认。
- 不允许读取 blocked dirs，除非工程师明确授权。
