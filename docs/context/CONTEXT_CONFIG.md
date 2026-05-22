# CONTEXT_CONFIG

> 目标：限制 AI 读代码的范围，避免无目标全仓扫描和 token 浪费。

| 字段 | 内容 |
|------|------|
| **Backend** | auto |
| **Require Context Plan Before Coding** | yes |
| **Require Affected Analysis Before Complete** | yes |
| **Max Files Per Task** | 8 |
| **Max Symbols Per Task** | 20 |
| **Max Search Queries Per Task** | 5 |
| **Blocked Dirs** | .git,node_modules,dist,build,coverage,.next,.nuxt,target,vendor,tmp,logs |
| **Preferred Order** | codegraph -> CODE_CONTEXT_INDEX -> FILE_INDEX -> precise rg -> engineer confirmation |

## Backend 说明

- `auto`：优先使用 CodeGraph；不可用时降级到文件索引和精准搜索。
- `codegraph`：使用预索引代码图谱查 symbol、调用链、影响范围。
- `file-index`：使用 `docs/context/CODE_CONTEXT_INDEX.md` 和 `docs/FILE_INDEX.md`。
- `rg`：只允许精准关键词搜索，不允许全仓批量读取。

## 硬规则

- 修改业务代码前必须先生成 `docs/context/tasks/CTX-<AT-T>.md`。
- 只读取 Context Plan 中列出的文件。
- 需要扩大范围时，必须写入“扩大上下文记录”。
- 不允许读取 blocked dirs，除非工程师明确授权。
