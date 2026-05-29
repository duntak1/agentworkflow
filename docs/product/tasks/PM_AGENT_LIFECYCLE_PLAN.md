# 研发计划 — PM Agent 产品全生命周期管理

## 元数据

| 字段 | 内容 |
|------|------|
| **版本** | 0.1.0 |
| **状态** | 草稿 |
| **关联 PRD** | docs/product/PM_AGENT_LIFECYCLE_PRD.md |
| **关联 Atomic** | docs/product/tasks/PM_AGENT_LIFECYCLE_TASKS.md |
| **关联 REQ** | 待创建 |

## 目标

在 agent-workflow 中新增 PM Agent 产品经理角色和产品全生命周期管理能力，使 PM 能通过向导式流程管理同步中心、参考资料、Pencil 设计稿、DSL、Plan、三端任务派发、新增需求、项目看板和生命周期 Gate。

## 不在范围内

- 不实现完整 Web 项目管理系统。
- 不替代 Jira、Linear、飞书项目或 GitHub Projects。
- 不让 PM Agent 直接写业务代码。
- 不默认自动提交、合并或发布。
- 不一次性完成所有 CLI 自动化；先补齐规范、模板和核心命令。

## 阶段与里程碑

| 阶段 | 内容 | 验证 |
|------|------|------|
| P0 | PM Agent 角色、同步中心目录、Pencil 设计稿、三端任务和生命周期规范落入 skill 文档与模板 | `./scripts/check-docs-commands.sh`、人工审阅 |
| P1 | 新增 `aw pm` 基础命令：init、intake-check、dashboard、assignments、gate | `bash -n scripts/*.sh`、`./scripts/check-aw-all.sh` |
| P1 | 新增同步中心 PM 模板：product、references、design、requirements、dispatch、dashboard、lifecycle | `./scripts/aw pm init` 在临时目录生成完整结构 |
| P1 | 新增三端任务派发和看板刷新机制 | e2e smoke 增加 PM 流程覆盖 |
| P2 | Pencil 工具集成、设计稿导出/链接/变更影响分析 | Pencil 可用时执行导出验证；无 Pencil 时降级为文件登记 |
| P2 | 新增需求影响分析和自动派发草案 | 新增需求可生成 REQ、DSL/Plan 更新提示、任务草案和看板变更 |
| P2 | 生命周期 Gate 接入研发、联调、测试、UAT、发布、复盘 | `aw pm gate` 能阻断不满足阶段条件的流程 |
| P3 | 手册、HTML 页面、提示词大全更新 | 本地打开手册，检查 PM 场景和复制提示词 |

## 核心交付物

- `docs/product/PM_AGENT_LIFECYCLE_PRD.md`
- `docs/product/tasks/PM_AGENT_LIFECYCLE_PLAN.md`
- `docs/product/tasks/PM_AGENT_LIFECYCLE_TASKS.md`
- `skill/SKILL.md` PM Agent 规则更新
- `skill/reference.md` PM 命令说明
- `agent-workflow/INVOCATION.md` PM 使用流程
- `agent-workflow/AGENTWORKFLOW_MANUAL.html` PM 使用手册
- `scripts/aw-pm.sh` 或等价 CLI
- `agent-workflow/templates/pm/` 同步中心模板

## 验收

1. PM 可以通过自然语言或 `aw pm start` 得到清晰向导。
2. `aw pm init` 能创建同步中心 PM 目录和基础看板。
3. `aw pm intake-check` 能汇总 PRD、UI、Pencil、技术、接口、业务资料完整度。
4. Pencil 设计稿可以登记到同步中心，并关联 REQ。
5. 三端任务可以从 `TASK_BOARD.md` 和对应 `*_ASSIGNMENTS.md` 派发。
6. 新增需求可以先进入需求池，再生成影响分析和派发草案。
7. 生命周期 Gate 能表达并检查立项、需求、设计、技术方案、联调、测试、UAT、发布和复盘状态。
8. 手册中有 PM、前台前端、后台管理前端、后端的完整使用教程。

## 风险与依赖

- Pencil `.pen` 文件可能是加密格式，不能通过普通文本解析；需要 Pencil 工具支持或导出产物兜底。
- 同步中心目录扩展较大，需要避免让普通研发 Agent 每次读取全部资料。
- PM 自动化必须保留人工确认边界，不能让新增需求或设计变更直接进入编码。
- 三端任务派发需要和现有 `aw agents`、`aw sync`、`aw contract`、`aw task` 机制保持兼容。
