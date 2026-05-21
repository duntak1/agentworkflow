# Plan 生成提示词（DSL 已审 → docs/plans/）

**前置：** 目标 DSL 元数据 **状态 = 已审**。

```text
你是技术负责人。请根据【输入】已审 DSL 生成可执行研发计划（Markdown）。

【输入】
- DSL 真源：@docs/dsl/<已审文件>.md
- 若为 DSL suite：同时读取 @docs/dsl/DSL_<slug>/INDEX.md、00-requirements、10-pages、20-interactions、30-events、40-boundaries、90-acceptance
- 关联 REQ：@docs/requirements/ 对应 REQ
- 计划骨架：@docs/plans/_TEMPLATE_PLAN.md
- 原子任务骨架：@docs/plans/_TEMPLATE_ATOMIC_TASKS.md

【输出】
1. docs/plans/PLAN_<slug>.md — 阶段、里程碑、验收、风险。
2. docs/plans/ATOMIC_TASKS_<slug>.md — AT-T* 表，每项含验证命令。

【规则】
- 任务粒度：单次 PR / 单次提交可完成。
- AT-T* 必须标注领域：Frontend / Backend / Fullstack / QA / Docs / Ops / Data。
- 前后端边界清楚时拆成独立任务；同一验收必须贯通 UI 与 API 时标 Fullstack，不要为了分类强拆。
- 每项验证必须可执行（命令或 TP 用例路径）。
- 不编写业务代码；只产出计划文档。
- 在 DSL 元数据回填「关联 Plan」路径。

【禁止】DSL 状态非「已审」时停止并提示人类先审 DSL。
```
