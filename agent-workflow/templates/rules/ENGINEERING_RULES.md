# 工程规范（人类维护 · Agent 必读）

> 本文件记录框架、语言、代码规范、禁令和常见任务 SOP。`docs/PROJECT_CONFIG.md` 记录本项目实际栈与验证命令；本文件记录“怎么写代码”。如本文件与更具体目录规则冲突，以更具体、更靠近当前工作目录的规则为准。

## 优先级

1. 仓库书面约定优先：`docs/ENGINEERING_RULES.md`、`docs/PROJECT_CONFIG.md`、`AGENTS.md`、`CLAUDE.md`、`.github/copilot-instructions.md` 等。
2. DSL / Plan 决定本轮“做什么”；工程规范决定“怎么实现”。
3. 业务 / 权限 / 金额不明先问；工程惯例不全时可按本文件补全并声明假设。

## 项目概述

> 待填写：项目是什么、为谁解决什么问题。

## 技术栈

### 团队固定前端栈

- Vue 3 + Vite + TypeScript。
- Vue Router、Pinia、Axios。
- Element Plus、EleAdmin。
- ESLint + Prettier。
- Vue 代码默认使用 Composition API 与 `<script setup lang="ts">`；禁止 Vue 2 和 Options API，除非项目已有书面相反约定。

### 团队固定后端栈

| 技术 | 用途 | 默认版本 |
|------|------|----------|
| Java | 运行时 | 1.8 |
| Spring Boot | 应用框架 | 2.6.13 |
| Spring Cloud Alibaba | 微服务 | 2021.0.5.0 |
| Nacos | 注册 / 配置中心 | 2021.0.5.0 |
| Spring Cloud Gateway | 网关 | 3.1.4 |
| Spring Cloud LoadBalancer | 负载均衡 | 3.1.5 |
| Sentinel | 熔断限流 | 2021.0.5.0 |
| Seata | 分布式事务 | 2021.0.5.0 |
| Zipkin | 链路追踪 | 3.1.5 |
| Spring Boot Admin | 服务监控 | 2.6.8 |
| MyBatis-Plus | 持久化框架 | 3.5.2 |
| Redis | 缓存 | 7.0.11 |
| Kafka | 消息队列 | 2.8.0 |
| Elasticsearch | 搜索 / 日志 | 7.17 |
| Kibana | 数据可视化 | 7.17 |
| MinIO | OSS 文件服务 | 8.2.2 |
| Maven | 构建 / 仓库 | 3.5.4 |
| Oracle | 数据库 | 19c |
| Hutool | 工具包 | 5.8.7 |
| Druid | 数据库连接池 | 1.0.20 |
| XXL-JOB | 任务调度中心 | 2.4.0 |
| PageHelper Spring Boot | 分页 | 1.4.1 |
| DataX | ETL 工具 | 2.1.2 |

### 前端

- 框架 / 构建：Vue 3 + Vite
- 语言：TypeScript
- UI 组件库：Element Plus + EleAdmin
- 状态 / 路由：Pinia + Vue Router
- 数据请求：Axios，经统一 request/client 封装
- 样式方案：SFC scoped 样式 + 项目既有全局样式
- 禁用：待填写

### 后端

- 语言 / 运行时：Java 8
- 框架：Spring Boot 2.6.13 / Spring Cloud Alibaba 2021.0.5.0
- ORM / 数据访问：MyBatis-Plus 3.5.2，Mapper 默认继承 `com.fancy.database.mybatisplusutils.mpsqlInjector.MyBaseMapper`
- 数据库 / 缓存：Oracle 19c 或 MySQL 8.0；Redis 7.0.11
- 消息 / 任务：Kafka 2.8.0；XXL-JOB 2.4.0
- API 文档 / 契约：Swagger / Knife4j / OpenAPI，以项目既有实现为准
- 禁用：待填写

### 构建与部署

- 包管理 / 构建：前端 npm/pnpm/yarn 以项目 lockfile 为准；后端 Maven 3.5.4
- 容器 / 编排：待填写
- 环境配置：Nacos / application.yml / 环境变量，以项目实际为准

## 代码规范

### 通用

- 新增模块前先确认目录归属和负责人。
- 禁止无目标全仓扫描。开始任何业务代码修改前，必须先生成或读取 `docs/context/tasks/CTX-<AT-T>.md`，并只读取 Context Plan 中列出的文件。
- 默认单任务上下文预算：最多 8 个业务文件、20 个 symbol、5 次精准搜索。需要扩大范围时，必须先在 Context Plan 的“扩大上下文记录”中写明原因和工程师确认。
- 读代码优先顺序：CodeGraph / `aw context` → `docs/context/CODE_CONTEXT_INDEX.md` → `docs/FILE_INDEX.md` → 精准 `rg` → 工程师确认。不得为了“了解项目”批量读取文件。
- 禁止读取 `.git`、`node_modules`、`dist`、`build`、`coverage`、`.next`、`.nuxt`、`target`、`vendor`、`tmp`、`logs` 等依赖、构建、缓存、生成或日志目录，除非工程师明确授权。
- 不引入未评审的新依赖、新中间件、新云服务。
- AI 生成或说明代码时必须标明完整文件路径；在真实仓库内执行任务时应直接修改文件，最终摘要列出变更文件和验证结果，不只给零散代码片段。
- 信息不足时，只能按企业后台通用工程默认补齐低风险工程细节，并声明假设；业务规则、权限、金额、安全、数据口径、外部系统行为不明时必须先问清楚。
- 成熟方案优先：能用项目既有工具、官方 SDK、成熟开源库、框架内置能力或行业通用实现解决的问题，不要手写脆弱实现。引入新依赖前必须说明候选方案、版本、许可证、安全风险、维护活跃度和替代方案，并取得工程师确认。
- 禁止直接复制来源不明的网上代码。可参考公开方案的设计思路，但实现必须符合本项目架构、代码风格、测试和许可证要求；引用算法、协议或关键兼容逻辑时，在注释或文档中标明依据来源和适用边界。
- 不改 `common/`、`framework/`、`generated/` 等共享或生成目录，除非任务明确授权。
- 不提交密钥、token、内部 URL、个人敏感信息。
- 注释原则：AI 写的代码必须让人类工程师能接手。复杂业务规则、非显而易见的边界条件、兼容逻辑、性能权衡、幂等/并发处理、外部系统约束和临时折中必须写注释；简单赋值、普通 getter/setter、直观分支不要写噪声注释。
- 注释应解释“为什么这样做”和“变更时要注意什么”，不要复述“代码正在做什么”。临时方案必须标明触发条件、风险、移除条件或关联任务/REQ/Bug。
- 新增公共函数、复杂 hook/usecase/service、跨模块联动入口时，必须用简短注释说明职责、输入输出约束、副作用和错误处理方式。
- 注释标记约定：`TODO` 表示临时方案或待完善；`REQ` 表示需求待确认/待补充；`BUG` 表示已知问题或临时修复；`AT-T` 表示关联任务、待重构或待优化。标记必须带简短原因、触发条件或关联编号。

### 前端

- 组件命名：`PascalCase`；函数/变量：`camelCase`；常量：`UPPER_SNAKE_CASE`。
- 页面 / 组件 / hooks / types / api / store 按项目既有目录放置。
- API 调用走统一 client / request 封装。
- 请求必须支持 token 注入、请求拦截、响应拦截、错误处理、文件上传和文件下载。
- 页面必须覆盖 loading、空态、错误态、确认提示和基础表单校验。
- TypeScript 默认严格约束；禁止 `any`，除非有项目兼容原因并在注释中说明边界和后续收敛计划。
- 禁止随意 `console.log`、未使用变量、未使用 import、重复造 UI 基础组件。
- Vue 项目默认优先使用 Vue 3 + Vite + TypeScript；如采用 Vue，应使用 `<script setup lang="ts">` 与 Composition API，禁止 Vue2 / Options API，除非项目已有相反约定。
- 企业后台模块默认按完整模块交付，不只输出零散片段。多文件输出时必须写明文件路径。
- 复杂逻辑放在 `<script setup>` 或 hooks 中，template 避免复杂表达式。
- SFC 样式默认使用 `scoped`，跨页面样式使用项目既有全局样式入口。
- import 顺序建议：Vue / 框架库 → 第三方库 → api / store / utils → types → 组件。
- ESLint / Prettier 建议基线：2 空格、单引号、保留分号、尾随逗号、优先 `const`。

### 后端

- Controller / Router 只做参数校验和调度，业务逻辑放 Service / UseCase。
- 对外返回 DTO / VO / Schema，禁止直接暴露持久化 Entity。
- SQL 必须参数绑定；禁止拼接可执行 SQL。
- 禁止循环查库；使用批量查询、JOIN 或明确的性能方案。
- 禁止吞异常；必须记录日志或转换成业务错误。
- 日志禁止打印密码、token、完整证件号、银行卡等敏感字段。
- Spring Boot 项目默认按 Controller → Service → Mapper / Repository 分层；Controller 使用 `@Valid` 校验，接口保持 RESTful。
- MyBatis-Plus 项目 Mapper 优先继承团队基类（如 `MyBaseMapper`）；实体可继承团队基类（如 `BaseEntity`），以项目实际约定为准。
- 统一响应默认使用团队公共响应类（如 `com.fancy.common.result.CommonResponse<T>`）；异常默认走全局异常处理（如 `GlobalException` / `GlobalExceptionHandler`），以项目实际包名为准。
- Service 实现类涉及多表写入、关键状态变更、库存/订单/资金等场景时必须声明事务边界。
- 所有接口必须包含参数校验、权限/身份校验、异常处理和必要事务边界；HTTP 状态码按 RESTful 语义正确使用。
- API 文档使用 Swagger / Knife4j / OpenAPI 中项目既有方案；新增接口必须同步契约。
- Java 项目遵循团队 Java 规范；未声明时参考阿里巴巴 Java 开发手册。

## 前端模块规范（企业后台）

### 标准目录

```text
src/views/业务域/模块名/
├── index.vue
├── components/
│   ├── XxxFormModal.vue
│   └── XxxDetailDrawer.vue
├── hooks/
│   ├── useXxxTable.ts
│   └── useXxxForm.ts
└── types.ts

src/api/modules/xxx.ts
src/store/modules/xxx.ts（仅在多页面共享或复杂缓存时创建）
```

### 团队前端标准目录

```text
src/
├── api/
│   ├── modules/
│   └── index.ts
├── assets/
│   ├── images/
│   ├── icons/
│   └── styles/
├── components/
│   ├── business/
│   └── common/
├── layout/
├── router/
│   ├── index.ts
│   ├── static-routes.ts
│   └── dynamic-routes.ts
├── store/
│   └── modules/
├── types/
├── utils/
│   ├── request.ts
│   ├── auth.ts
│   ├── modal.ts
│   ├── download.ts
│   └── dict.ts
├── hooks/
├── views/
├── App.vue
└── main.ts
```

### 标准后台页面能力

- 列表：查询表单、查询/重置、表格、分页、loading、空数据。
- 表单：新增、编辑、回显、校验、提交 loading、成功后刷新列表。
- 操作：删除、批量删除（如需要）、状态切换、详情抽屉（如需要）。
- 交互：删除二次确认、成功/失败消息、按钮禁用、请求 loading。
- 权限：路由 meta、菜单显示、查询/新增/编辑/删除/导出等按钮权限。
- 路由：支持静态路由、动态路由和后端菜单生成路由；模块路由应包含 path、name、meta、菜单显示、权限标识、keepAlive、hidden 等信息。

### 前端命名建议

- API：`getXxxPage`、`getXxxList`、`getXxxDetail`、`createXxx`、`updateXxx`、`deleteXxx`、`batchDeleteXxx`、`exportXxx`。
- Store：`useUserStore`、`usePermissionStore` 等。
- Hooks：`useXxxTable`、`useXxxForm`、`usePagination`。
- Types：`XxxItem`、`XxxPageParams`、`XxxFormData`、`XxxDetail`、`XxxStatus`、`XxxOption`。

### 前端拆分边界

- `index.vue` 负责页面整体布局、查询区域、表格区域、工具栏、分页和页面级事件调度。
- `components/` 放新增/编辑弹窗、详情抽屉、选择器弹窗和页面局部业务组件。
- `hooks/` 放表格查询、分页、表单、列表操作、状态切换等逻辑。
- `types.ts` 放列表项、查询参数、表单、详情和枚举类型。
- `api/modules/xxx.ts` 放当前模块所有接口请求和请求/响应类型。
- 默认不强行创建 store；只有多页面共享状态、全局筛选、复杂缓存或跨组件复用时才创建。

## 后端模块规范（Spring / Cloud / Boot）

### 推荐输出顺序

1. `pom.xml` / 构建依赖。
2. `application.yml` / 配置文件。
3. 数据库建表 SQL、索引、约束、初始化数据（必要时含回滚）。
4. Entity / DTO / VO / Query / Form。
5. Mapper / Repository。
6. Service 接口与实现。
7. Controller。
8. 安全配置、JWT / 过滤器（若涉及认证）。
9. 统一响应、全局异常、错误码。
10. API 文档、启动说明、接口测试示例。

### 团队后端标准结构

```text
com.xxx.project/
├── controller/
├── service/
│   └── impl/
├── mapper/
├── pojo/
│   ├── entity/
│   ├── dto/
│   └── vo/
├── config/
├── exception/
├── common/
│   ├── result/
│   └── exception/
└── util/
```

### Spring 技术栈参考

- Java：默认 Java 8。
- Spring Boot：默认 2.6.13。
- Spring Cloud Alibaba：默认 2021.0.5.0。
- ORM：默认 MyBatis-Plus 3.5.2。
- 数据库：默认 Oracle 19c 或 MySQL 8.0，以项目为准。
- 常用组件：Redis、Kafka、MinIO、Knife4j、Maven、Hutool、XXL-JOB、PageHelper，按需启用，禁止无评审引入。

### 数据库字段建议

- 表名和字段命名遵循团队约定；若团队采用大写下划线，应保持一致。
- 审计字段可包含：`CREATE_USER_ID`、`CREATE_USER_NAME`、`CREATE_TIME`、`MODIFY_USER_ID`、`MODIFY_USER_NAME`、`MODIFY_TIME`。
- 必要时包含逻辑删除、版本号、租户字段、状态字段，须与项目既有基类一致。
- Entity 字段必须有字段说明注释；MyBatis-Plus 注解使用 `@TableName`、`@TableId`、`@TableField` 等项目既有方式。

## 安全底线

- 写接口必须校验身份与权限。
- 默认鉴权方案：JWT + RBAC；若项目使用其他方案，必须在 `docs/ENGINEERING_RULES.md` 写明替代方案和入口文件。
- 敏感字段清单至少包含：手机号、身份证、银行卡、token、内部 ID、密码、密钥、验证码、个人隐私字段。
- 日志必须屏蔽敏感信息，返回数据必须按角色和场景脱敏。
- 生产环境 CORS 禁止 `*`，除非有明确评审例外。
- CORS 必须使用白名单；文件上传必须使用类型、大小和路径白名单。
- 金额使用定点数 / `BigDecimal` / 数据库 `DECIMAL`，禁止浮点。
- 批量 `UPDATE` / `DELETE` 必须有约束条件和评审。
- 上传文件必须校验类型、大小和存储边界。
- 涉及资金、库存、订单、关键状态必须考虑幂等和并发。

## 依赖准入

- 优先使用项目已有成熟依赖，禁止重复造轮子。
- 仅允许官方可信源或团队认可的私有仓库源。
- 许可证白名单：MIT、Apache-2.0、BSD。
- 许可证黑名单：GPL、AGPL、CC-BY-SA 等强传染或不适合商用闭源交付的许可证，除非完成法务/工程审批并留痕。
- 新增第三方依赖必须记录用途、版本、许可证、安全风险、维护状态、替代方案和审批结论；必要时写入 `docs/security/DEPENDENCY_REVIEW.md`。

## 数据库约定

- 表结构应包含主键、审计字段、必要索引和注释。
- 迁移脚本必须入库；提供回滚 SQL 或说明不可逆风险。
- 大表查询必须分页且有上限；避免无约束 `SELECT *`。
- 索引命名建议：`idx_` / `uk_`。

## 常见任务 SOP

### 新增前端页面

1. 确认路由、菜单、权限入口。
2. 页面和组件放在约定目录，优先使用既定 UI 库。
3. API 调用走统一 client，类型放在约定位置。
4. 实现 loading、空态、错误态、表单校验、确认与消息提示。
5. 按 `docs/PROJECT_CONFIG.md` 执行 lint / test / build / e2e。

### 新增后端接口

1. 定义请求 / 响应 DTO 或 Schema。
2. Controller 使用 `@RestController`、`@RequestMapping`、`@Valid`，只做参数校验和调度。
3. Service 承载业务逻辑；持久化走 Repository / Mapper。
4. Mapper 继承团队基类；复杂查询必须考虑分页、关联查询优化和 N+1 风险。
5. 更新 Swagger / OpenAPI / Knife4j 或项目契约。
6. 必要时补迁移 SQL、回滚 SQL、集成测试。

### 数据库变更

1. 迁移脚本入库。
2. 同步实体、映射、DTO / VO。
3. 补充回滚或风险说明。
4. 跑真实集成验证或团队认可的替代环境。

### 后台 CRUD 模块

1. 明确实体字段、唯一约束、状态枚举和权限点。
2. 后端提供创建、详情、分页、更新、删除、导出（如需要）接口。
3. 前端提供查询、表格、分页、新增/编辑弹窗、删除确认、状态切换、详情（如需要）。
4. 所有接口定义请求/响应类型；密码等敏感字段必须加密或脱敏。
5. 验证覆盖主路径、空数据、校验失败、删除取消/确认、接口失败。

### 登录认证

1. 登录接口返回 token 和必要用户信息。
2. 密码使用项目约定算法加密，禁止明文或弱哈希；若采用团队默认方案，优先确认国密 2/4 或 BCrypt 的项目约定。
3. Token 验证、过期、退出登录和失败处理必须完整。
4. 前端请求拦截器注入 token，响应拦截器处理 401 / 403 / 过期。
5. 后端补安全配置、用户详情服务、JWT 工具、过滤器和异常处理。

### 文件上传下载

1. 限制文件大小、类型和存储路径。
2. 生成唯一文件名，保存文件元信息。
3. 支持单文件上传、批量上传、下载、删除、列表查询。
4. 处理文件不存在、大小超限、类型不允许、存储失败等异常。
5. 前端提供上传 loading、进度/结果提示、下载错误处理。

## Git 提交

### 提交前流程

1. 确认当前 AT-T 已完成需求沟通、代码实现和验证；未完成不得混入下一任务代码。
2. 运行 `./scripts/aw task complete <AT-T>` 或 `./scripts/aw verify --task <AT-T>`；无 AT-T 时运行 `./scripts/aw verify` 和 `./scripts/commit-gate.sh`。
3. 若验证失败、人工发现问题或用户反馈异常，必须先用 `./scripts/aw bug add ...` 记录到 `docs/handoff/AI_BUG_LOG.md`，修复并复测后再提交。
4. 若本轮有口述新增或研发中变更，确认 `docs/requirements/INDEX.md`、DSL、Plan、ATOMIC 已回写；必要时运行 `./scripts/aw index` 和 `./scripts/aw file-index`。
5. 执行 `git diff` 和 `git diff --cached` 自查，只提交本任务相关文件；不要把无关格式化、调试日志、临时文件、密钥或本地配置混入提交。
6. 使用 `./scripts/aw commit --task <AT-T> -m "<type>(<AT-T>): <description>"` 生成/校验提交信息。AI 默认只建议提交命令；只有工程师明确确认或传入 `--execute` 时才执行 `git commit`。
7. 提交后确认 hook / CI 通过；若失败，记录 Bug 或修复任务，不得口头忽略。

### 阶段性提交提醒

- 每完成一个大需求、阶段性需求或 AT-T 任务并验证通过后，Agent 必须询问工程师是否提交当前分支，方便后期按提交点回滚。
- 如果工程师同意，先运行 `./scripts/aw commit --task <AT-T>` 生成建议和验证结果，再由工程师确认是否追加 `--execute` 真正提交。
- 如果工程师选择暂不提交，必须在 `docs/handoff/PROJECT_HANDOFF.md` 记录“未提交原因、当前风险、下一步提交时机”。

### 提交信息格式

格式：`<type>(<scope>): <description>`，优先使用 AT-T 作为 scope，例如 `feat(AT-T1-003): add export permission gate`。

- `feat` 新功能
- `fix` 修复
- `refactor` 重构
- `docs` 文档
- `chore` 构建/依赖

### 禁止项

- 禁止跳过验证提交，除非工程师明确说明原因，并在提交说明或 handoff 中记录风险。
- 禁止把多个无关 AT-T 合并到一个提交。
- 禁止提交 secret、`.env` 本地文件、构建产物、缓存目录、个人 IDE 配置和无关大文件。

## 关键文件

| 路径 | 说明 |
|------|------|
| 待填写 | 权限入口 |
| 待填写 | 路由入口 |
| 待填写 | 统一 API Client |
| 待填写 | 全局异常处理 |
| 待填写 | 统一响应封装 |
| 待填写 | 安全配置 |
| 待填写 | 数据库迁移目录 |
| 待填写 | CI/CD 配置 |
| 待填写 | 构建配置 |

## 待确认

- [ ] 技术栈已填写。
- [ ] 禁用技术 / 禁改目录已填写。
- [ ] 前端目录规范已填写。
- [ ] 后端分层 / DTO / 异常 / 日志规范已确认。
- [ ] 本地验证命令已同步到 `docs/PROJECT_CONFIG.md`。
