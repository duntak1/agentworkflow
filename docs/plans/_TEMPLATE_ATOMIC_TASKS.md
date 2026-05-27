# 原子任务词典 — <项目>

> 与 [`_TEMPLATE_PLAN.md`](./_TEMPLATE_PLAN.md) 配套。每项任务 **一提交**；状态列为准。

## 元数据

| 字段 | 内容 |
|------|------|
| **关联 Plan** | PLAN_*.md |
| **关联 DSL** | docs/dsl/DSL_*.md |

---

## 任务表

| ID | 领域 | 标题 | 状态 | 依赖 | 验证 |
|----|------|------|------|------|------|
| AT-T1-001 | Frontend | 示例：搭建路由骨架 | 待办 | — | `pnpm build` |

**验证列约定：** 可执行 shell 命令；可选 `; TP:docs/quality/test-plans/TP-….md`（`aw tp link <AT-T> <tp>`）。示例：`pnpm test; TP:docs/quality/test-plans/TP-20250101-001-login.md`

**状态枚举：** 待办 / 进行中 / 已完成 / 阻塞。不要手改为 `进行中` 或 `已完成` 绕过流程；`aw check plan` 会检查对应 AT-T 是否已有需求确认记录。

---

## AI 执行协议（摘要）

1. `./scripts/aw task brief <AT-T…>` → 和工程师沟通需求 → `./scripts/aw task confirm <AT-T…> "已确认：范围=...；验收=...；非目标=..."` → `./scripts/aw context plan --task <AT-T…>` → `./scripts/aw context gate --task <AT-T…>` → `./scripts/aw task start <AT-T…>` → `./scripts/aw paste task` → 阶段 A→E 写码。
2. 只改当前 AT-T* 范围；不猜需求；研发中需求变更先 `./scripts/aw req change <id> "摘要"`，回写 DSL / Plan / ATOMIC 并重新确认。
3. 验证与完成：`./scripts/aw task complete <id>`。
4. `task complete` 通过才会标记完成；失败会写 `docs/handoff/AI_BUG_LOG.md` 并保持 `进行中`。
5. 完成后询问工程师是否提交当前分支；需要跨会话继续时执行 `./scripts/aw handoff "完成 <id>" --write && ./scripts/aw handoff --check`。
