# Policy Decisions（策略例外与审批记录）

用途：记录策略命中、人工审批、例外放行和后续动作。

## 记录规则

- 命中高风险路径、新依赖、生产变更、破坏性 API、数据库迁移时必须记录。
- 例外必须包含原因、风险、确认人、后续动作和关联对象。
- 不记录 secret；证据用路径或脱敏摘要。

## 流水（新在上）

| 时间 | 类型 | 关联 | 决策 | 风险 / 原因 | 后续动作 | 确认人 |
|------|------|------|------|-------------|----------|--------|
| 2026-05-22 16:50:00 | high_risk_change | task-confirmation-gate | Enforce hard task-start gate in CLI, Skill, Invocation, Agent rules, manual, and tests. | Core workflow behavior changed; prevents agents from bypassing engineer confirmation and context gate before coding. | Run e2e smoke, check-aw-all, reinstall local Codex skill, and push to GitHub. | user direction |
| 2026-05-20 14:57:33 | Engineering Harness enhancement | EH-P0-001..EH-P1-003 | Use lightweight file+CLI control plane before building a standalone management system. | Docs and CLI checks must stay synchronized. | Validate with e2e-smoke and check-aw-all. | user direction |
