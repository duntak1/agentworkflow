# BRANCH_POLICY

## 分支规范

| 类型 | 命名 |
|------|------|
| 需求 | `feature/REQ-xxxx-short-title` |
| 任务 | `task/AT-Txxx-short-title` |
| 修复 | `fix/BUG-xxxx-short-title` |
| 发布 | `release/vx.y.z` |

## Gate

- 新分支前：确认项目类型、GitHub URL、DSL/Plan 状态。
- PR 前：运行 `aw github-pr gate`。
- 合并前：确认 CI、review、release、rollback、contract、score。
