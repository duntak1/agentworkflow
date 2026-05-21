# HOOKS（自动 Gate / 自动化触发）

> 目标：把关键流程从“Agent 自觉执行”升级为“命令 / Git Hook / CI 可检查”。

## Hook 策略

| 触发点 | 推荐动作 | 阻断条件 |
|--------|----------|----------|
| `pre-commit` | `aw gate pre-commit` | DSL 未审却修改业务代码；trace 断链；高风险策略未确认 |
| `post-commit` | 记录 commit checkpoint | 不中断 |
| AT-T 完成前 | `aw gate task --task AT-Txxx` | 未确认需求、未跑验证、Bug 未记录 |
| PR 前 | `aw gate pr` | PR 清单、review、release、contract、score 不达标 |
| Release 前 | `aw release gate --strict-report` | 安全、策略、ops、报告不完整 |

## 自动刷新

- `aw gate index-refresh`：刷新 `docs/FILE_INDEX.md` 与 `ENGINEERING_INDEX.md`。
- `aw hooks install`：安装 Git hooks。
- `aw hooks check`：检查 hooks 是否启用。

## 例外记录

所有跳过 Gate 的情况必须写入：

- `docs/audit/AGENT_TRACE.md`
- `docs/handoff/PROJECT_HANDOFF.md`
- 如涉及风险，写入 `docs/policy/POLICY_DECISIONS.md`
