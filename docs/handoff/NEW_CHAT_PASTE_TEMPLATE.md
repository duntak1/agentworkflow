# 新会话首条消息 · 粘贴模板（通用）

> **用途：** 新开任意 Agent 窗口时，将下方 **「新会话首条消息」** 代码块整段复制为第一条用户消息。  
> **维护（人类）：** 更新 **§维护核对**；与 `docs/plans/ATOMIC_TASKS_*.md`、`PROJECT_HANDOFF.md` 一致。  
> **勿 @：** `ENGINEERING_INDEX.md`（仅供人类）。

---

## 维护核对

| 项 | 当前值 |
|----|--------|
| 近期已完成 | （填写） |
| 下一步主线 | （填写；可 `./scripts/aw next`） |
| 活跃 DSL | docs/dsl/ |
| 活跃 Plan | docs/plans/ |

---

## 新会话首条消息（整段复制）

```
【会话接续 · agent-workflow】

1) 先读：agent-workflow/INVOCATION.md、docs/handoff/PROJECT_HANDOFF.md、docs/requirements/INDEX.md
2) 勿读：ENGINEERING_INDEX.md（人类索引）
3) 闸门：DSL 非「已审」不写业务代码；验证见 docs/PROJECT_CONFIG.md
4) 计划：docs/plans/ 原子任务表；当前任务运行 ./scripts/aw next 查看
5) 变更：agent-workflow/CHANGELOG.md [Unreleased]；REQ 用 ./scripts/aw req new
6) 近期已完成：（见上表）
7) 下一步：（见上表）

本回合只做：（由人类填写一条 AT-T* 或一句话目标）
```

---

也可运行：`./scripts/aw paste session`
