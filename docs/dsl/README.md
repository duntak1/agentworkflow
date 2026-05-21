# DSL / 页面说明

阶段 0 见 [`agent-workflow/PRODUCT_INPUT_WORKFLOW.md`](../../agent-workflow/PRODUCT_INPUT_WORKFLOW.md)。

## 模板（本目录）

| 文件 | 用途 |
|------|------|
| [`DSL_SPEC_TEMPLATE.md`](./DSL_SPEC_TEMPLATE.md) | 领域 / 产品级 DSL 骨架 |
| [`FRONTEND_PAGE_SPEC_TEMPLATE.md`](./FRONTEND_PAGE_SPEC_TEMPLATE.md) | 单路由页面规格 |

`aw init` 后在业务仓生成 `DSL_DRAFT.md`（默认名见 `reference/manifest.yaml`）。

## 命令

```bash
./scripts/aw dsl
./scripts/aw approve dsl docs/dsl/DSL_DRAFT.md
./scripts/aw plan docs/dsl/<已审>.md
```

提示词：`agent-workflow/templates/prompts/`
