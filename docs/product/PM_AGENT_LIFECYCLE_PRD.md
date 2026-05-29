# PM Agent 产品全生命周期管理 PRD

## 1. 背景

当前 agent-workflow 已经覆盖 Reference、DSL、Plan、任务确认、研发执行、验证、同步中心、Contract、VCS、交接和恢复等工程流程。但在真实产品研发中，产品经理往往不熟悉 Agent、CLI、同步中心和 DSL/Plan 的概念，容易出现以下问题：

- PM 不知道应该把 PRD、UI 规范、Pencil 设计稿、技术资料放在哪里。
- 前台前端、后台管理前端、后端三端任务拆分容易各自理解，导致接口和业务边界歧义。
- 新增需求或设计稿变更容易直接进入代码修改，绕过需求治理、DSL、Plan 和任务派发。
- 同步中心已有机制，但缺少一个面向 PM 的向导式入口、资料体检、看板和任务派发视图。
- 产品全生命周期缺少从立项、需求、设计、技术方案、研发、联调、测试、UAT、发布、指标验证到复盘的统一闭环。

## 2. 产品目标

新增 PM Agent 产品经理角色，让 agent-workflow 支持更完整的产品全生命周期管理。

核心目标：

- PM 不需要记忆底层命令，通过向导式流程完成项目资料导入、DSL/Plan 生成、三端任务派发和进度监控。
- 同步中心升级为项目资料中心、DSL/Plan 源头、任务调度中心和项目进度看板。
- Pencil 设计稿作为正式需求输入，支持同步到同步中心，并关联 REQ、DSL、Plan 和三端任务。
- 前台前端、后台管理前端、后端三端任务通过同步中心、任务看板、接口契约和集成矩阵统一同步。
- 新增需求和设计变更必须先进入 PM 治理流程，再更新 DSL/Plan/任务派发。
- 建立产品全生命周期 Gate，减少未评审、未冻结、未验收就进入研发或发布的风险。

## 3. 非目标

- 不让 PM Agent 直接编写业务代码。
- 不替代 Jira、Linear、飞书项目、GitHub Projects 等完整项目管理系统。
- 不默认全自动提交、合并、发布。
- 不让前端或后端 Agent 私自维护全局 DSL、全局 Plan 或产品需求事实源。
- 不要求 PM 学习所有 `aw` 子命令；CLI 是底层能力，PM 主要使用自然语言和向导。

## 4. 角色与职责

| 角色 | 职责 |
|------|------|
| PM Agent | 管理同步中心、参考资料、Pencil 设计稿、REQ、DSL、全局 Plan、三端 Plan、任务派发、看板、生命周期 Gate |
| 前台前端 Agent | 认领前台任务，读取设计稿、DSL、API Contract，实现前台页面和交互 |
| 后台管理前端 Agent | 认领后台管理任务，读取设计稿、DSL、API Contract，实现后台管理页面 |
| 后端 Agent | 认领后端任务，读取 DSL、API Contract、事件、权限和数据边界，实现接口、数据、权限和服务逻辑 |
| 工程师 / 技术负责人 | 确认 DSL、Plan、技术方案、接口契约、任务验收、Git/VCS/Release 操作 |
| PM / 产品负责人 | 提供 PRD、设计稿、业务规则，确认需求、设计、范围、验收和优先级 |

## 5. 同步中心目录

同步中心建议结构：

```text
project-harness/
  global/
    product/
      PRODUCT_BRIEF.md
      STAKEHOLDERS.md
      MVP_SCOPE.md
      SUCCESS_METRICS.md
      COMPETITOR_NOTES.md
    references/
      prd/
      ui/
      tech/
      api/
      business/
      assets/
      design/
        pencil/
          source/
          exports/
          screenshots/
          README.md
        DESIGN_INDEX.md
        DESIGN_REVIEW.md
        DESIGN_FREEZE.md
        DESIGN_QA.md
        DESIGN_CHANGELOG.md
      README.md
    requirements/
      INDEX.md
      BACKLOG.md
      PRIORITIZATION.md
      REVIEW_LOG.md
      ACCEPTANCE_RECORD.md
      changes/
    architecture/
      ARCHITECTURE_DECISION_RECORDS.md
      TECH_DESIGN.md
      DATA_MODEL.md
      AUTH_MODEL.md
      INTEGRATION_DESIGN.md
    dsl/
      INDEX.md
      DSL_REQUIREMENTS.md
      DSL_PAGES.md
      DSL_INTERACTIONS.md
      DSL_EVENTS.md
      DSL_BOUNDARIES.md
      DSL_ACCEPTANCE.md
    plans/
      GLOBAL_PLAN.md
      FRONTEND_PLAN.md
      ADMIN_FRONTEND_PLAN.md
      BACKEND_PLAN.md
      ATOMIC_TASKS.md
    dispatch/
      TASK_BOARD.md
      FRONTEND_ASSIGNMENTS.md
      ADMIN_ASSIGNMENTS.md
      BACKEND_ASSIGNMENTS.md
    contracts/
      API_CONTRACT.openapi.yaml
      API_CHANGELOG.md
      CONTRACT_TESTS.md
      INTEGRATION_MATRIX.md
    delivery/
      ITERATION_PLAN.md
      DAILY_SYNC.md
      DEPENDENCY_GRAPH.md
      REWORK_LOG.md
      DELIVERY_RISKS.md
    integration/
      INTEGRATION_PLAN.md
      MOCK_STRATEGY.md
      INTEGRATION_ISSUES.md
      INTEGRATION_ACCEPTANCE.md
    quality/
      TEST_STRATEGY.md
      TEST_CASES.md
      REGRESSION_PLAN.md
      UAT_RECORD.md
      QUALITY_REPORT.md
    release/
      RELEASE_PLAN.md
      GO_LIVE_CHECKLIST.md
      ROLLBACK_PLAN.md
      POST_RELEASE_REVIEW.md
    analytics/
      METRICS_PLAN.md
      EVENT_TRACKING.md
      FUNNEL.md
      METRICS_REVIEW.md
    knowledge/
      PRODUCT_KNOWLEDGE.md
      TECH_KNOWLEDGE.md
      FAQ.md
      DECISION_LOG.md
    dashboard/
      PROJECT_DASHBOARD.md
      LIFECYCLE_BOARD.md
      PROGRESS_BOARD.md
      BLOCKERS.md
      RISKS.md
      CHANGE_REQUESTS.md
      EXECUTIVE_SUMMARY.md
      DECISION_BOARD.md
    inbox/
    outbox/
```

目录原则：

- 核心目录使用英文，降低脚本、Git、CI、跨平台路径风险。
- 文档标题、说明、看板内容使用中文。
- 上传文件名可以使用中文。

## 6. PM 向导式流程

PM 使用自然语言或 `aw pm start` 进入向导。

向导菜单：

```text
你要做哪类工作？

1. 新项目立项
2. 已有项目接入
3. 上传/整理参考资料
4. 同步 Pencil 设计稿
5. 生成或更新 DSL
6. 生成三端研发计划
7. 派发任务给前台/后台/后端
8. 新增需求/需求变更
9. 查看项目进度看板
10. 查看阻塞和前后端对接问题
11. 进入测试 / UAT / 发布 / 复盘流程
```

PM Agent 应隐藏底层命令细节，自动完成：

- 同步中心检查和初始化。
- 资料目录创建。
- 参考资料扫描和体检。
- DSL 草案生成和摘要。
- Plan 草案生成和摘要。
- 三端任务派发草案。
- 项目看板刷新。
- 生命周期 Gate 检查。

## 7. 参考资料和资料体检

PM Agent 管理以下资料：

- PRD
- UI 规范
- Pencil 设计稿
- 页面截图
- 技术文件
- 接口资料
- 业务规则
- 权限说明
- 数据模型
- 竞品参考
- 旧项目说明

资料体检输出示例：

```text
已发现：
- PRD：2 份
- UI 规范：1 份
- Pencil 设计稿：3 份
- 技术资料：1 份
- 接口文档：缺失
- 权限规则：缺失

建议补充：
1. 后台菜单结构
2. 用户角色权限说明
3. 前后台共用接口边界
```

PM 可选择：

```text
1. 继续生成 DSL
2. 补充资料后再生成
3. 先生成草案，并标记缺失项
```

## 8. Pencil 设计稿治理

Pencil 设计稿是正式需求输入。

流程：

```text
产品在 Pencil 完成设计
→ PM Agent 导入/导出 Pencil
→ 写入同步中心 references/design/pencil/
→ 关联 REQ 文件
→ 更新 DSL
→ 更新 Plan
→ 派发三端任务
→ 前后端通过 Git / sync pull 拉取最新设计稿
```

要求：

- `.pen` 原始文件存放在 `source/`。
- 导出说明、截图、PDF、HTML 等可读产物存放在 `exports/` 或 `screenshots/`。
- `.pen` 原始文件不使用普通文本方式解析；应通过 Pencil 工具读取、截图或导出。
- 每份设计稿必须关联一个或多个 REQ。
- 设计稿变更必须写入 `DESIGN_CHANGELOG.md`。

REQ 关联设计稿示例：

```markdown
## 关联设计稿

| 类型 | 路径 | 说明 |
|------|------|------|
| Pencil 源文件 | `global/references/design/pencil/source/favorite-flow.pen` | 商品收藏流程图 |
| 导出截图 | `global/references/design/pencil/screenshots/favorite-flow.png` | 前台收藏交互 |
| 导出说明 | `global/references/design/pencil/exports/favorite-flow.md` | 页面结构与交互摘要 |
```

设计变更记录示例：

```markdown
| 时间 | 设计稿 | 变更内容 | 影响需求 | 影响任务 | 状态 |
|------|--------|----------|----------|----------|------|
| 2026-05-29 | favorite-flow.pen | 收藏按钮从详情页移到列表页 | REQ-001 | FE-T021, BE-T019 | 待确认 |
```

## 9. DSL 和 Plan 生成

DSL 由 PM Agent 统一生成和维护。

DSL 文件覆盖：

- 需求描述
- 用户角色
- 页面结构
- 页面字段
- 交互行为
- 事件流
- 前后端联动边界
- API 依赖
- 权限边界
- 数据状态
- 异常状态
- 验收标准
- 非目标

DSL 生成后，PM Agent 需要输出摘要供 PM/工程师确认：

```text
本次识别到：
- 用户角色：游客、注册用户、管理员
- 前台页面：登录、首页、商品详情、订单
- 后台页面：商品管理、订单管理、用户管理
- 核心事件：登录、下单、支付、审核、上下架
- 前后端接口边界：18 个
- 待确认问题：6 个
```

Plan 分两层：

- `GLOBAL_PLAN.md`：全局协作计划，描述产品功能拆分、三端边界、依赖关系、接口契约、联调顺序、里程碑和风险。
- `FRONTEND_PLAN.md`、`ADMIN_FRONTEND_PLAN.md`、`BACKEND_PLAN.md`：三端研发计划，描述各端任务、关联 REQ、关联 DSL、依赖任务、依赖接口、验收标准和测试要求。

## 10. 三端任务派发与同步

三端任务通过同步中心统一派发和管理：

```text
dispatch/TASK_BOARD.md
dispatch/FRONTEND_ASSIGNMENTS.md
dispatch/ADMIN_ASSIGNMENTS.md
dispatch/BACKEND_ASSIGNMENTS.md
```

任务字段：

```text
任务ID
所属端
关联REQ
关联DSL
关联Plan
关联设计稿
依赖任务
依赖接口
负责人Agent
状态
输入
输出
验收标准
阻塞原因
最后同步时间
```

任务状态：

```text
待确认
待认领
已认领
需求澄清中
进行中
等待对接
等待后端
等待前端
等待后台
联调中
待验证
已完成
阻塞
废弃
```

三端 Agent 标准工作方式：

```text
aw sync pull
aw pm assignments --role frontend/admin/backend
aw agents claim <TASK-ID>
aw task start <TASK-ID>
执行任务
aw task checkpoint <TASK-ID>
aw sync push --task <TASK-ID>
```

## 11. 前后端对接

前后端对接以接口契约为唯一事实源。

核心文件：

```text
contracts/API_CONTRACT.openapi.yaml
contracts/API_CHANGELOG.md
contracts/CONTRACT_TESTS.md
contracts/INTEGRATION_MATRIX.md
```

`INTEGRATION_MATRIX.md` 示例：

```markdown
| 功能 | 页面 | 前台任务 | 后台任务 | 后端任务 | API | 状态 | 阻塞 |
|------|------|----------|----------|----------|-----|------|------|
| 商品列表 | /products | FE-T010 | ADMIN-T004 | BE-T008 | GET /products | 等待后端 | BE-T008 未完成 |
```

接口变化流程：

```text
提出接口需求
→ 更新 API_CONTRACT
→ 更新 API_CHANGELOG
→ 前后端确认
→ 生成/更新对应任务
→ contract gate 通过后进入研发
```

## 12. 新增需求和需求变更

新增需求不能直接派给某端改代码，必须先进入 PM Agent 治理流程。

流程：

```text
PM 提出新增需求
→ PM Agent 记录 requirements/INDEX.md
→ 判断影响范围
→ 关联 Pencil / PRD / UI 资料
→ 更新 DSL
→ 更新 GLOBAL_PLAN
→ 更新三端 Plan
→ 生成新增任务
→ 更新 TASK_BOARD
→ 更新看板
→ 通知相关 Agent 拉取同步中心
```

需求类型：

```text
口述新增
研发中变更
缺陷修复
体验优化
技术调整
接口调整
权限调整
数据模型调整
设计稿变更
```

## 13. 产品全生命周期

agent-workflow 需要从工程交付流程升级为产品全生命周期流程：

```text
立项
→ 需求
→ 设计
→ 技术方案
→ DSL
→ Plan
→ 派发
→ 研发
→ 联调
→ 测试
→ UAT
→ 发布
→ 数据验证
→ 复盘
→ 交接
```

生命周期 Gate：

| Gate | 规则 |
|------|------|
| 立项未确认 | 不生成 DSL |
| 需求未评审 | 不生成正式 Plan |
| 设计未冻结 | 不派发前端正式任务 |
| 技术方案未确认 | 不派发后端正式任务 |
| API 契约未确认 | 不进入前后端联调 |
| 测试计划未生成 | 不允许任务标记完成 |
| UAT 未通过 | 不允许发布 |
| 上线 checklist 未完成 | 不允许 release |
| 复盘未记录 | 项目不能关闭 |

## 14. 看板

PM Agent 维护以下看板：

```text
dashboard/PROJECT_DASHBOARD.md
dashboard/LIFECYCLE_BOARD.md
dashboard/PROGRESS_BOARD.md
dashboard/BLOCKERS.md
dashboard/RISKS.md
dashboard/CHANGE_REQUESTS.md
dashboard/EXECUTIVE_SUMMARY.md
dashboard/DECISION_BOARD.md
```

看板内容：

- 项目阶段
- DSL 状态
- Plan 状态
- 前台前端进度
- 后台管理前端进度
- 后端进度
- 接口契约状态
- 联调状态
- 当前阻塞
- 新增需求
- 需求变更
- Bug 数量
- 待认领任务
- 进行中任务
- 已完成任务
- Agent 心跳
- 最近同步时间
- 生命周期 Gate 状态

## 15. 自动化与确认边界

可自动执行：

- 创建同步中心目录。
- 扫描参考资料。
- 导入/导出 Pencil 设计稿。
- 生成资料清单。
- 生成 DSL 草案。
- 生成 Plan 草案。
- 生成任务派发表。
- 更新看板。
- 汇总阻塞。
- 汇总三端状态。
- 生成新增需求影响分析。

必须人工确认：

- DSL 正式通过。
- Plan 正式派发。
- 新增需求进入研发。
- 影响范围确认。
- 设计稿变更是否生效。
- 接口 breaking change。
- 删除或废弃任务。
- Git 提交、合并、发布。

## 16. 建议 CLI

PM 专用：

```bash
aw pm start
aw pm init
aw pm intake
aw pm intake-check
aw pm design init
aw pm design import
aw pm design export
aw pm design link
aw pm design change
aw pm dsl
aw pm plan
aw pm dispatch
aw pm dashboard
aw pm blockers
aw pm lifecycle
aw pm backlog
aw pm prioritize
aw pm review
aw pm design-freeze
aw pm tech-review
aw pm iteration
aw pm integration
aw pm uat
aw pm release
aw pm postmortem
aw pm gate
```

三端常用：

```bash
aw pm assignments --role frontend
aw pm assignments --role admin
aw pm assignments --role backend
```

## 17. 强约束

1. PM Agent 是同步中心资料、全局 DSL、全局 Plan、任务派发和生命周期看板的治理角色。
2. 同步中心存在时，DSL、Plan、任务派发以同步中心为事实源。
3. 前台、后台、后端 Agent 不允许私自修改全局 DSL 和全局 Plan。
4. Pencil 设计稿必须关联 REQ。
5. 设计稿变更必须进入 `DESIGN_CHANGELOG.md`。
6. 新增需求必须先进入 `requirements/INDEX.md`。
7. 新增需求必须更新 DSL、Plan、TASK_BOARD 和看板。
8. 前后端对接必须走 API Contract。
9. 三端任务必须从 `TASK_BOARD.md` 派发和认领。
10. 任务完成必须回写同步中心和看板。
11. 前端任务开始前必须读取关联设计稿导出物。
12. 后端任务开始前必须读取关联事件、接口、边界说明。
13. PM 不需要记命令，优先通过向导式流程操作。
14. 生命周期 Gate 未通过时，禁止进入下一阶段。

## 18. 验收标准

- PM Agent 需求文档、Plan 和原子任务已创建。
- 目录结构、Pencil、三端任务、前后端对接、新增需求、生命周期 Gate 和看板均有明确规范。
- 后续实现任务可按 P0/P1/P2 分批落地。
- 不破坏现有 agent-workflow 的 DSL/Plan/Task/Gate 机制。
