# 原子任务词典 — PM Agent 产品全生命周期管理

> 与 `PM_AGENT_LIFECYCLE_PLAN.md` 配套。状态列为准。任务 ID 使用 `PM-T` 前缀，避免和业务项目 AT-T 混淆。

## 元数据

| 字段 | 内容 |
|------|------|
| **关联 Plan** | docs/product/tasks/PM_AGENT_LIFECYCLE_PLAN.md |
| **关联 PRD** | docs/product/PM_AGENT_LIFECYCLE_PRD.md |

## 任务表

| ID | 优先级 | 领域 | 标题 | 状态 | 依赖 | 验证 |
|----|--------|------|------|------|------|------|
| PM-T0-001 | P0 | Product | 补充 PM Agent 角色边界和强约束到 skill 文档 | 待办 | PRD | `./scripts/check-docs-commands.sh` |
| PM-T0-002 | P0 | Docs | 补充同步中心 PM 目录规范和英文目录/中文说明原则 | 待办 | PRD | 人工审阅 |
| PM-T0-003 | P0 | Docs | 补充 Pencil 设计稿治理流程、REQ 关联和 DESIGN_CHANGELOG 规范 | 待办 | PRD | 人工审阅 |
| PM-T0-004 | P0 | Docs | 补充三端任务派发、TASK_BOARD、ASSIGNMENTS 和 INTEGRATION_MATRIX 规范 | 待办 | PRD | 人工审阅 |
| PM-T0-005 | P0 | Docs | 补充新增需求、设计变更、需求变更的 PM 治理流程 | 待办 | PRD | 人工审阅 |
| PM-T0-006 | P0 | Docs | 补充产品全生命周期 Gate 和生命周期看板规范 | 待办 | PRD | 人工审阅 |
| PM-T1-001 | P1 | CLI | 新增 `aw pm` 命令入口和 usage | 待办 | PM-T0-* | `bash -n scripts/aw-pm.sh scripts/aw` |
| PM-T1-002 | P1 | Templates | 新增 PM 同步中心模板目录 `agent-workflow/templates/pm/` | 待办 | PM-T0-002 | `./scripts/check-skill-package.sh` |
| PM-T1-003 | P1 | CLI | 实现 `aw pm init` 创建 product/references/design/requirements/dispatch/dashboard/lifecycle 文件 | 待办 | PM-T1-001, PM-T1-002 | 临时目录执行 `aw pm init` |
| PM-T1-004 | P1 | CLI | 实现 `aw pm intake-check` 扫描 PRD、UI、Pencil、tech、api、business 资料完整度 | 待办 | PM-T1-001 | 临时目录扫描样例资料 |
| PM-T1-005 | P1 | CLI | 实现 `aw pm dashboard --write` 汇总项目阶段、三端进度、阻塞和生命周期 Gate | 待办 | PM-T1-003 | 输出 dashboard 文件 |
| PM-T1-006 | P1 | CLI | 实现 `aw pm assignments --role frontend/admin/backend` 读取对应任务派发表 | 待办 | PM-T1-003 | 三个 role 均可输出 |
| PM-T1-007 | P1 | Gate | 实现 `aw pm gate` 基础检查：同步中心、DSL/Plan、设计冻结、技术方案、Contract、测试/UAT/Release 状态 | 待办 | PM-T1-003 | `aw pm gate` 正反例 |
| PM-T1-008 | P1 | E2E | 在 `e2e-smoke.sh` 中增加 PM 初始化、资料体检、看板、assignments、gate 覆盖 | 待办 | PM-T1-003..PM-T1-007 | `./scripts/e2e-smoke.sh` |
| PM-T2-001 | P2 | Pencil | 实现 `aw pm design init/import/link/change` 文件登记和 REQ 关联 | 待办 | PM-T1-003 | 样例 `.pen` 或占位文件可登记 |
| PM-T2-002 | P2 | Pencil | 接入 Pencil 工具导出/截图流程；不可用时降级为导出物缺失提醒 | 待办 | PM-T2-001 | Pencil 环境可用时验证 |
| PM-T2-003 | P2 | Requirements | 实现 `aw pm change` 新增需求影响分析草案 | 待办 | PM-T1-004 | 生成 REQ、影响端、候选任务 |
| PM-T2-004 | P2 | Dispatch | 实现 `aw pm dispatch` 从全局计划生成三端任务派发草案 | 待办 | PM-T1-006, PM-T2-003 | TASK_BOARD 和三端 assignments 更新 |
| PM-T2-005 | P2 | Contract | 将 INTEGRATION_MATRIX 与 `aw contract` gate 联动 | 待办 | PM-T2-004 | Contract gate 检查矩阵 |
| PM-T2-006 | P2 | Lifecycle | 扩展生命周期 Gate 到测试、UAT、发布、数据验证、复盘 | 待办 | PM-T1-007 | 生命周期正反例 |
| PM-T3-001 | P3 | Manual | 更新 HTML 手册：PM 向导、Pencil、三端派发、新增需求、生命周期看板 | 待办 | PM-T1/P2 | 本地浏览手册 |
| PM-T3-002 | P3 | Prompts | 更新提示词大全：PM、前台前端、后台管理前端、后端、多电脑协作场景 | 待办 | PM-T3-001 | 提示词一键复制可用 |
| PM-T3-003 | P3 | Package | 更新 skill package 检查，确保 PM CLI、模板和文档都被打包 | 待办 | PM-T1/P2/P3 | `./scripts/build-skill-archive.sh` |

## 执行顺序建议

1. 先完成 P0 文档和强约束，避免 CLI 实现方向跑偏。
2. 再完成 P1 CLI 骨架、模板、看板和 Gate，形成 PM 最小闭环。
3. 再做 P2 Pencil 深度集成、新增需求影响分析和三端派发自动化。
4. 最后做 P3 手册、提示词、打包和发布。

## AI 执行协议

1. 每个 PM-T 任务开始前，先向工程师确认范围、验收和非目标。
2. 涉及业务代码或脚本前，先生成 Context Plan，避免全仓扫描。
3. 所有新增命令必须补 `skill/reference.md`、`agent-workflow/INVOCATION.md`、HTML 手册和 package check。
4. 涉及 Pencil 的实现不得直接普通文本解析 `.pen` 文件。
5. 任务完成后运行相关检查，并记录是否需要 Git checkpoint。
