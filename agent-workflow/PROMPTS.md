# 提示词大全（agent-workflow 包内）

本文件是工程师在真实项目里调用 AgentWorkflow 的提示词索引。完整暗色 HTML 手册见 [`AGENTWORKFLOW_MANUAL.html`](./AGENTWORKFLOW_MANUAL.html)。

## 基础模板

| 场景 | 说明 |
|------|------|
| DSL 路径 A/B/C | [`templates/prompts/PROMPT-DSL.md`](./templates/prompts/PROMPT-DSL.md) |
| Plan（DSL 已审后） | [`templates/prompts/PROMPT-PLAN.md`](./templates/prompts/PROMPT-PLAN.md) |

## 真实项目启动

```text
使用 agentworkflow。
当前项目路径：/path/to/project
当前是新项目接入阶段，不要写业务代码。
请按顺序完成：
1. 检查是否已安装 scripts/aw；没有则说明需要从 agentworkflow 源码安装
2. 执行 aw status、aw check config、aw rules review
3. 如果没有初始化，执行 aw init
4. 引导我确认：这是 GitHub 项目还是本地 Git 项目；构建目标是前端、后端还是前后端
5. 检查 reference/inputs/ 和 reference/manifest.yaml 是否存在
最后输出缺失项清单和下一步建议。
```

## 非全新项目接入：先盘点现状

```text
使用 agentworkflow。
当前项目路径：/path/to/existing-project
这是非全新项目，已经有一期代码 / 已进入研发阶段。
当前目标不是重建项目，而是把 AgentWorkflow 接入现有项目。

请先不要写业务代码，也不要生成新增需求的 Plan。
请按顺序完成：
1. 检查 scripts/aw 是否已安装；没有则说明安装方式
2. 执行 aw status、aw check config、aw rules review
3. 如果没有初始化，执行 aw init，但不得覆盖业务代码
4. 引导我确认：GitHub 项目还是本地 Git 项目；构建目标是前端、后端还是前后端；当前是维护、Bug 修复、二期开发还是联调阶段
5. 读取 package.json / pom.xml / build.gradle / README / 启动脚本 / 路由 / API 目录 / 测试目录等入口文件，禁止全仓无目标读取
6. 执行 aw context plan、aw file-index、aw service-catalog discover --write
7. 输出项目事实盘点：技术栈、启动命令、测试命令、主要模块、接口入口、已知风险、缺失配置

最后给出：
- 现状基线是否足够
- 还需要我补充哪些一期文档或口述说明
- 下一步是否进入“一期基线回填”或“增量 DSL 生成”。
```

## 非全新项目：一期基线回填

```text
使用 agentworkflow 为存量项目回填一期基线。
当前项目路径：/path/to/existing-project
一期需求状态：已完成 / 部分完成 / 不确定
下一步目标：维护 / Bug 修复 / 二期开发 / 联调

请基于现有代码、README、接口文档、测试、Git 状态和我补充的口述说明，生成“当前真实状态”：
1. 已实现能力清单
2. 已有页面 / 模块 / 接口 / 数据模型 / 权限边界
3. 已知 Bug、技术债、风险和未确认事项
4. 当前可运行命令和失败命令
5. 不应被二期误改的稳定边界

请落盘或建议落盘到：
- docs/handoff/PROJECT_HANDOFF.md
- docs/FILE_INDEX.md
- docs/SERVICE_CATALOG.md
- docs/requirements/ 中的一期基线 REQ
- docs/memory/ 中可复用的稳定结论

完成后不要写业务代码。
请问我是否确认这份一期基线；确认后再为下一期 / 当前增量需求生成 DSL。
```

## 生成 DSL

```text
使用 agentworkflow 生成 DSL。
参考资料已经放在 reference/inputs/，请先读取 reference/manifest.yaml。
请生成多文件 DSL suite，覆盖：
需求描述、页面/模块结构、交互行为、事件、前后端联动边界、权限、错误码、验收、非目标。
生成后请列出已覆盖需求点、仍需确认的问题、不允许进入研发的阻塞项。
不要写业务代码，不要编造 reference 路径。
```

## 非全新项目：增量 DSL

```text
使用 agentworkflow 为存量项目生成增量 DSL。
当前项目路径：/path/to/existing-project
已确认的一期基线：docs/handoff/PROJECT_HANDOFF.md、docs/FILE_INDEX.md、docs/SERVICE_CATALOG.md、docs/requirements/
本次增量需求：<写清楚二期需求 / 维护需求 / Bug 修复目标>

请先读取一期基线和必要入口文件，再生成多文件 DSL suite。
DSL 必须区分：
1. 已有能力：只引用，不重新设计
2. 本次新增：需要实现
3. 本次变更：说明从旧行为改成什么
4. 本次修复：说明复现、期望、验收
5. 不改动边界：页面、接口、表结构、权限、数据口径、兼容性
6. 受影响文件候选：只列候选，不全仓扫描

生成后请列出与一期基线冲突的地方、需要工程师确认的问题、不允许进入研发的阻塞项。
不要直接生成 Plan，等待我确认 DSL。
```

## 生成 Plan

```text
DSL 已确认。
请先检查 docs/PROJECT_CONFIG.md：
1. 项目类型是 GitHub 还是本地 Git
2. 构建目标是前端、后端还是前后端
3. lint/test/build/e2e 命令是否配置
然后按 DSL 生成研发 Plan 和 ATOMIC_TASKS。
生成后不要直接写代码，等待我确认 Plan。
```

## 非全新项目：增量 Plan

```text
存量项目的增量 DSL 已确认。
请基于已审 DSL、一期基线和代码索引生成增量 Plan。

计划必须满足：
1. 只拆本次新增 / 变更 / 修复 / 联调任务，不把一期已完成能力重新拆为待开发
2. 每个 AT-T 写清楚受影响文件候选、不可改动边界、验证命令、回滚风险
3. 如果需要修改已有接口、DTO、数据库、权限或公共组件，必须标记为高风险并要求工程师确认
4. 如果是前后端分项目，必须同步到 project-harness 的 global/dsl、global/plans、TASK_BOARD
5. 如果信息不足，先列问题，不要猜测拆任务

生成后不要写代码。
等待我确认 Plan；确认后再执行 aw confirm，并刷新 ENGINEERING_INDEX.md 和 docs/FILE_INDEX.md。
```

## 仅前端项目

```text
你是 frontend-agent。
当前是仅前端项目：/path/project-frontend
使用 agentworkflow。
技术栈按 docs/ENGINEERING_RULES.md。
开始任务前：
1. aw status
2. aw next
3. aw task brief <AT-T>
4. 向我确认页面结构、字段、交互、权限、接口 mock/真实接口、验收标准
确认前不要写代码。
完成后：aw task complete、记录 bug/req change、aw handoff --write，并问我是否提交 Git。
```

## 仅后端项目

```text
你是 backend-agent。
当前是仅后端项目：/path/project-backend
使用 agentworkflow。
技术栈按 docs/ENGINEERING_RULES.md。
开始任务前：
1. aw status
2. aw next
3. aw task brief <AT-T>
4. 向我确认接口路径、入参、出参、权限、错误码、事务、数据表、验收标准
确认前不要写代码。
完成后：aw task complete、更新 SERVICE_CATALOG、记录 bug/req change、aw handoff --write，并问我是否提交 Git。
```

## 同电脑前后端两个项目

```text
使用 agentworkflow 的双项目同步。
当前电脑上有三个目录：
前端项目：/path/workspace/project-frontend
后端项目：/path/workspace/project-backend
同步中心：/path/workspace/project-harness

当前会话是 frontend-agent。
开始任务前先读取同步中心 global/dsl、global/plans 和 global/plans/TASK_BOARD.md，确认共享 DSL / 协作 Plan 基线和双方任务状态没有冲突。
每个前端任务开始前，先在前端项目执行 aw sync pull --from backend。
再执行 aw sync board，查看对方计划、任务、依赖、阻塞和联调点。
读取 docs/sync/inbox/backend 后再 task brief。
遇到接口字段、权限、错误码不明确时，写 agents handoff 给 backend-agent，并 aw sync push。
完成任务后 aw task complete、aw agents handoff、aw sync push，然后问我是否提交 Git。
```

```text
使用 agentworkflow 的双项目同步。
当前电脑上有三个目录：
前端项目：/path/workspace/project-frontend
后端项目：/path/workspace/project-backend
同步中心：/path/workspace/project-harness

当前会话是 backend-agent。
开始任务前先读取同步中心 global/dsl、global/plans 和 global/plans/TASK_BOARD.md，确认共享 DSL / 协作 Plan 基线和双方任务状态没有冲突。
每个后端任务开始前，先在后端项目执行 aw sync pull --from frontend。
再执行 aw sync board，查看对方计划、任务、依赖、阻塞和联调点。
读取 docs/sync/inbox/frontend 后再 task brief。
遇到页面字段、交互、联动边界不明确时，写 agents handoff 给 frontend-agent，并 aw sync push。
完成任务后 aw task complete、更新 SERVICE_CATALOG、aw agents handoff、aw sync push，然后问我是否提交 Git。
```

## 不同电脑前后端两个项目

```text
使用 agentworkflow 的跨电脑双项目同步。
同步中心是单独 GitHub 仓库 project-harness。
本机本地路径：/path/workspace/project-harness
当前项目路径：/path/workspace/project-frontend-or-backend
当前会话是 frontend-agent 或 backend-agent。

开始任务前：
1. 进入 project-harness 执行 git pull
2. 读取 project-harness/global/dsl、project-harness/global/plans 和 TASK_BOARD.md，确认共享基线和双方任务状态
3. 回到当前项目执行 aw sync pull --from <peer>
4. 执行 aw sync board
5. 读取 docs/sync/inbox/<peer>
6. aw task brief 当前 AT-T，并向我确认需求

完成任务后：
1. aw task complete 当前 AT-T
2. aw agents handoff 给对方 agent
3. aw sync push --task 当前 AT-T
4. 进入 project-harness 执行 git add / commit / push，但 Git 提交前必须问我确认。
```

## 变更、Bug、收尾

```text
当前事件会影响其他 Agent。
请使用通用同步事件，不要只写聊天结论：

./scripts/aw sync event \
  --type complete|change|block|question|contract|bug|decision|handoff \
  --task <AT-T> \
  --to <peer-agent> \
  --summary "事件摘要" \
  --impact "影响页面 / 接口 / 字段 / 权限 / 测试" \
  --acceptance "采纳或验收标准" \
  --risk "对方不处理的风险" \
  --evidence "证据路径"

执行后请总结：
1. 写入的 SYNC_EVENTS
2. 写入的 agents handoff
3. sync push / sync board 结果
4. 是否需要提交并 push project-harness
Git commit / push 前必须问我确认。
```

```text
当前出现研发中需求变更：
变更内容：<写清楚变更>
来源：工程师口述 / 产品补充 / 联调发现 / Bug 修复 / 技术约束
影响范围：<页面、接口、任务、测试、发布>
请使用 aw req change 记录，并回写 DSL、Plan、ATOMIC_TASKS。
如果影响当前任务，请重新 task brief 并等待我确认后再继续编码。
```

```text
当前需求变更会影响其他 Agent。
请使用 aw sync change 编排完整同步，不要只在聊天里说明：

./scripts/aw sync change <AT-T> "变更摘要" \
  --to <peer-agent> \
  --impact "影响页面 / 接口 / 字段 / 权限 / 测试" \
  --acceptance "新的验收标准" \
  --risk "对方不采纳时的风险"

执行后请总结：
1. 本项目 REQ / DSL / Plan / ATOMIC 回写结果
2. 已写入的 agents handoff
3. sync push 和 sync board 结果
4. 是否需要提交并 push project-harness
Git commit / push 前必须问我确认。
```

```text
完成当前 AT-T。
请按顺序执行：
1. aw task complete <AT-T>
2. 如果失败，写 AI_BUG_LOG 并保持任务未完成
3. 如果通过，更新 handoff / agents handoff / report
4. 如果是双项目，执行 aw sync push --task <AT-T>
5. 写入 changelog
6. 问我是否提交 Git，不要自动 commit。
```
