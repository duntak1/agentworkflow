# Agent Roles（多 Agent 协作角色）

用途：定义 AI / 人类工程师在研发、评审、测试、安全、发布中的职责边界，避免并行工作互相覆盖或无人负责。

## 角色矩阵

| 角色 | 适用任务 | 允许修改 | 禁止修改 | 必须产出 |
|------|----------|----------|----------|----------|
| Developer Agent | 实现已确认 AT-T | 当前任务相关代码、测试、必要文档 | 无关重构、未确认需求、他人负责文件 | diff、验证、audit、handoff |
| Reviewer Agent | 代码审查 | 评审意见、Bug/风险记录 | 未经确认直接大改代码 | review 结论、阻断项、建议 |
| Tester Agent | 测试与复测 | 测试计划、测试代码、Bug 记录 | 业务实现范围外改动 | TP、测试结果、复测证据 |
| Security Agent | 安全审查 | security findings、dependency review、policy decision | 绕过策略、删除证据 | 安全结论、依赖准入、风险 |
| Release Agent | 发布与回滚 | release record、environment、metrics、handoff | 未确认生产部署 | 发布门禁、回滚方案、验证 |

## 协作规则

- 每个 Agent 必须有明确 owner、scope、allowed paths、blocked paths、handoff target。
- 并行 Agent 不得修改彼此拥有的文件；需要交叉修改时先记录 handoff / policy decision。
- 完成时必须写入 `AGENT_HANDOFFS.md`，有评审则写入 `AGENT_REVIEWS.md`。
