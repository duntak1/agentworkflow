# 产品输入工作流（阶段 0）

**位置：** `agent-workflow/` 包内 · 在 [`AICODING_WORKFLOW.md`](./AICODING_WORKFLOW.md) 阶段 A 之前执行。

**目标：** Reference（人类放材料）→ DSL 草案 → **人类审 DSL** → Plan → 再进入 Karpathy 研发流。

---

## 目录约定（init 后）

| 路径 | 谁维护 | 用途 |
|------|--------|------|
| `reference/` | 人类 | 原始 PRD、设计导出、参考源码 |
| `reference/manifest.yaml` | 人类 | 输入清单 + 路径 A/B/C |
| `docs/dsl/` | 人类审、AI 起草 | 功能/页面规格真源 |
| `docs/plans/` | AI 起草、人类审 | 研发计划与 AT-T* |
| `docs/requirements/` | 人类 + AI | REQ 持久化 |
| `docs/PROJECT_CONFIG.md` | 人类 | 栈、验证命令（init 生成） |
| `docs/ENGINEERING_RULES.md` | 人类 + AI | 框架、语言、代码规范、禁令、SOP |

---

## 状态闸门

| 文档 | 状态 | 允许的操作 |
|------|------|------------|
| DSL | `草稿` | 人类修订；可重新 `draft-dsl` |
| DSL | `已审` | 允许 `draft-plan`；允许进入阶段 A 写代码 |
| Plan | `草稿` | 人类修订任务拆分 |
| Plan | `可执行` | Agent 按 AT-T* 实现 |

**硬规则：** DSL 非 `已审` 时，Agent **不得**写业务代码（除 init/文档）。

---

## 步骤

### 0.1 初始化（每个仓库一次）

```bash
./scripts/aw init
```

产出：`reference/`、`docs/dsl/` 模板、`docs/plans/` 模板、`docs/PROJECT_CONFIG.md`、`docs/ENGINEERING_RULES.md`。  
**任意 AI 工具**见 [`INVOCATION.md`](./INVOCATION.md)。

### 0.2 人类放置 Reference

1. 编辑 `reference/README.md` 与 `manifest.yaml`。
2. 材料放入 `reference/inputs/` 或 `reference/source/`。

### 0.3 生成 DSL 草案

```bash
./scripts/aw dsl    # 打印完整 prompt，贴入任意 Agent 对话
```

Agent 将产出写入 `docs/dsl/`（默认 `DSL_DRAFT.md`，见 `reference/manifest.yaml` 的 `output.draft_file`）。

### 0.4 工程师审 DSL

- 修正范围、验收、待确认。
- 生成审阅包：`./scripts/aw dsl review docs/dsl/DSL_DRAFT.md --write`
- 工程师按审阅包确认需求、页面、交互、事件、联动边界、验收是否完整。
- 元数据 **状态 → `已审`** 并进入 Plan 生成：`./scripts/aw approve dsl docs/dsl/DSL_DRAFT.md [--req REQ-...] --plan`
- 新建或更新 **REQ**（`aw req new <slug> "标题" --type 口述新增`），口述新增与研发中变更都写入 `docs/requirements/INDEX.md`，用“需求类型”区分；`--req` 可写入 DSL 关联字段。
- 研发中需求变更必须用 `./scripts/aw req change <AT-T> "摘要" --impact "..." --acceptance "..."` 记录到同一需求表，并回写 DSL / Plan / ATOMIC；之后重新 `aw task brief` / `aw task confirm`。

### 0.5 生成 Plan

```bash
./scripts/aw plan docs/dsl/DSL_xxx.md
```

产出 `docs/plans/PLAN_*.md` + `ATOMIC_TASKS_*.md`；AT-T 任务按 `Frontend / Backend / Fullstack / QA / Docs / Ops / Data` 标注领域。若人类指定“生成前端研发计划”或“生成后端研发计划”，使用 `--domain frontend|backend` 只拆对应领域任务，其他领域只作为依赖/边界记录。人类审后：`./scripts/aw approve plan docs/plans/PLAN_*.md`。

### 0.6 任务确认 → 工程师索引

DSL **已审** 且 Plan **可执行** 后：

```bash
./scripts/aw confirm docs/dsl/<已审文件>.md docs/plans/<可执行-plan>.md
```

须 **同时** 指定已审 DSL 与可执行 Plan；自动生成根目录 **`ENGINEERING_INDEX.md`**（人类交付路径索引，**勿 `@` 给 AI**）。  

仅扫描刷新路径表（**不**写入任务确认状态）：`./scripts/aw index`。
REQ / Bug / TP / DSL / Plan 写入命令会在成功后自动执行同等扫描刷新，保证新增交付文件进入 `ENGINEERING_INDEX.md`。

### 0.7 进入研发

按 [`AICODING_WORKFLOW.md`](./AICODING_WORKFLOW.md) 阶段 A→E；计划真源见 `docs/plans/`。

---

## 路径选择（A / B / C）

| 路径 | 条件 |
|------|------|
| **A** | 仅有 PRD / REQ / 规格 MD |
| **B** | 有 figmamake 等设计导出 MD |
| **C** | `reference/source/` 或 manifest 列出可参考源码 |

`./scripts/aw dsl` 根据 `manifest.yaml` 的 `dsl_path` 或 `inputs[].type` 自动选择。

---

## 与 DSL / 视觉的分工

- **DSL**：功能意图、页面结构、行为、验收锚点；**不含**主题 token 全文。
- **`CLAUDE.md` / `AGENT_RULES.md`**：技术栈、组件库用法、工程禁令。
- **调用真源**：[`INVOCATION.md`](./INVOCATION.md)；工具挂载见 [`adapters/`](./adapters/)。

---

## 相关文档

| 文档 | 用途 |
|------|------|
| [`templates/prompts/PROMPT-DSL.md`](./templates/prompts/PROMPT-DSL.md) | DSL 三条路径全文 |
| [`templates/prompts/PROMPT-PLAN.md`](./templates/prompts/PROMPT-PLAN.md) | Plan 生成 |
| [`PROMPTS.md`](./PROMPTS.md) | 提示词索引 |
| [`AICODING_WORKFLOW.md`](./AICODING_WORKFLOW.md) | 阶段 A–E |
