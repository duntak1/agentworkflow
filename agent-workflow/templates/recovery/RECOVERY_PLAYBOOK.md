# RECOVERY_PLAYBOOK

## 恢复场景

| 场景 | 命令 | 处理 |
|------|------|------|
| 上下文断裂 | `aw recover context` | 读取 handoff、memory、status、next |
| DSL/Plan 过期 | `aw recover plan` | 检查 REQ/DSL/Plan/ATOMIC 断链并给出修复路径 |
| 前后端不同步 | `aw recover sync` | pull 同步中心，检查 inbox、contracts、task board |
| 任务失败 | `aw recover failed-task --task AT-Txxx` | 记录 Bug，回到任务确认或拆分 |
| Git 冲突 | `aw recover conflict` | 停止编码，列冲突文件，要求工程师确认处理策略 |
| 需要回滚 | `aw recover rollback` | 查找 commit checkpoint、release record、handoff 风险 |

## 原则

- 不猜测恢复方向。
- 先记录，再修复。
- 需求变更必须回写 REQ / DSL / Plan / ATOMIC。
- 涉及前后端接口时必须更新 contract 和 sync center。
