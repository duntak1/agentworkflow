# Reference（人类参考材料区）

本目录存放**本轮需求**的原始参考，供 Agent 生成 `docs/dsl/` 草案时 `@` 引用。**不替代** DSL 真源——定稿规格在 `docs/dsl/`。

## 放什么

| 子目录 / 文件 | 用途 |
|---------------|------|
| `inputs/` | PRD、会议纪要、设计导出 Markdown、截图说明等 |
| `source/` | 可选：参考工程源码快照或子模块（迁移类路径 C） |
| `manifest.yaml` | 本轮启用的参考清单与输入路径（见 `manifest.yaml.example`） |

## 不放什么

- 密钥、`.env`、生产数据库导出
- 与当前需求无关的整个 monorepo（只 `@` 必要路径）

## 操作步骤

1. 复制 `manifest.yaml.example` → `manifest.yaml`，填写 `inputs` 与 `path`（`A` | `B` | `C`）。
2. 将材料放入 `inputs/` 或 `source/`。
3. 运行：`./scripts/aw dsl`（或 Cursor skill **`agent-workflow`** / 别名 `aw-delivery`）。
4. 人类审阅 `docs/dsl/*.md`，将元数据 **状态** 改为 `已审` 后再生成 Plan。

## Git

- 小文件、无敏感信息：**可提交** `manifest.yaml` 与 `inputs/*.md`。
- 大体量源码参考：用 submodule / `.gitignore` + 文档说明路径。
