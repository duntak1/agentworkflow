# Agent Trace（AI 执行审计）

用途：记录 AI 在研发过程中的关键动作、决策、命令、结果、证据和人工确认点，便于复盘、交接、定位问题和追责。

## 维护规则

- 每个大需求 / AT-T 至少记录开始、需求确认、关键实现决策、验证、完成闭环。
- 重要命令、失败命令、人工确认、权限例外必须记录。
- 不记录 secret、token、完整敏感日志；只记录脱敏摘要和证据路径。

## 流水（新在上）

| 时间 | AT-T / REQ | 动作 | 决策 / 命令 / 结果 | 证据 | 确认人 |
|------|------------|------|--------------------|------|--------|
| 2026-05-20 14:57:13 | EH-P0-001 | Engineering Harness skill enhancement | Added audit/policy/security/service-catalog/release minimal control-plane docs and commands. | docs/handoff/ENGINEERING_HARNESS_TASKS.md | user-approved direction |
