# 跨项目前后端同步教程

本文解释两个独立项目里的前端 Agent 和后端 Agent 如何通过 `aw sync` 同步状态。

适用场景：

- 前端和后端是两个仓库或两个独立项目目录。
- 两边各自有 Codex / Cursor / Claude 等 Agent 会话。
- 前端需要知道后端接口、权限、错误码、发布状态。
- 后端需要知道前端页面字段、交互、联动边界、验收变化。

不适用场景：

- 前后端在同一个仓库里。此时优先用 `aw agents assign` 划分目录边界即可。
- 只想拷贝代码文件。`aw sync` 同步的是工作流快照，不是代码合并工具。

## DSL / Plan 前置流程

双项目同步不是研发后期才使用。只要前后端是两个真实代码仓库，Agent 在 DSL 已审、准备拆 Plan 前，就必须先引导工程师完成仓库和同步中心建设。

推荐顺序：

```text
确认前后端双项目
→ 确认同电脑 / 不同电脑
→ 确认前端真实代码仓库路径 + 远程仓库地址
→ 确认后端真实代码仓库路径 + 远程仓库地址
→ 确认或创建 project-harness 同步中心
→ 前后端分别安装 agentworkflow 并 aw init / aw config init
→ 前后端分别 aw sync init 到同一个 project-harness
→ 共享 DSL 写入 project-harness/global/dsl/
→ 协作 Plan 写入 project-harness/global/plans/
→ 前端 / 后端分别生成本地派生 Plan
```

闸门：

- 前端真实仓库、后端真实仓库、同步中心未确认前，不得生成本地 Plan。
- 不同电脑开发时，`project-harness` 必须是单独远程 Git 仓库；双方先 clone / pull 最新同步中心，再拆 Plan。
- 双项目不能各自独立拆完全分离的 Plan。必须先有 `global/plans/` 协作 Plan，再派生本地 Plan。
- 如果 DSL 已审但真实代码仓库还没创建，Agent 应继续引导工程师创建仓库、配置 远程仓库地址和初始化 workflow，而不是把计划写进临时目录。

## 核心概念

`aw sync` 使用一个共享目录作为同步中心，建议叫 `project-harness`。

示例目录：

```text
workspace/
  project-harness/      # 同步中心，只放跨项目状态快照
  project-frontend/     # 前端项目
  project-backend/      # 后端项目
```

同步中心里会形成：

```text
project-harness/
  global/
    dsl/                # 前后端共同确认的共享 DSL 基线
    plans/              # 前后端共同确认的协作 Plan 基线
      TASK_BOARD.md     # 前后端共享任务看板
    contracts/          # 共享接口契约、字段、枚举、错误码、权限矩阵
    decisions/          # 跨端共同决策
  projects/
    frontend/
      MANIFEST.md
      docs/
        dsl/
        plans/
        requirements/
        handoff/
        agents/
        quality/test-plans/
        security/
        SERVICE_CATALOG.md
        PROJECT_CONFIG.md
        ENGINEERING_RULES.md
        FILE_INDEX.md
    backend/
      MANIFEST.md
      docs/
        ...
```

## 共享 DSL / 协作 Plan

前后端拆成两个项目时，不建议让前端和后端各自独立生成完全分离的 DSL 和 Plan 后直接开工。这样很容易出现歧义：

- 前端 DSL 认为字段是 `statusText`，后端 DSL 认为字段是 `status`。
- 前端 Plan 先做页面联调，后端 Plan 还没有安排接口。
- 前端把权限失败当空态，后端把权限失败当错误码。
- 两边都说“DSL 已确认”，但确认的不是同一份事实。

推荐做法：

| 层级 | 放在哪里 | 作用 | 谁能改 |
|------|----------|------|--------|
| 共享 DSL 基线 | `project-harness/global/dsl/` | 前后端共同事实：需求、页面/模块、交互、事件、接口边界、权限、错误码、验收、非目标。 | 工程师确认后修改 |
| 协作 Plan 基线 | `project-harness/global/plans/` | 跨端里程碑、依赖顺序、接口联调点、阻塞关系和验收门槛。 | 工程师确认后修改 |
| 共享任务看板 | `project-harness/global/plans/TASK_BOARD.md` | 汇总前端/后端已 push 的 ATOMIC 任务，让两个 Agent 同时知道双方计划、状态、依赖和验证方式。 | 自动生成，不手改 |
| 前端本地 DSL / Plan | `project-frontend/docs/dsl/`、`docs/plans/` | 前端执行派生：页面、路由、组件、状态、API client、前端 AT-T。 | 前端 Agent 按共享基线派生 |
| 后端本地 DSL / Plan | `project-backend/docs/dsl/`、`docs/plans/` | 后端执行派生：接口、权限、数据、事务、消息、后端 AT-T。 | 后端 Agent 按共享基线派生 |

规则：

- `global/dsl/` 和 `global/plans/` 是跨项目共同基线。
- 本地 `docs/dsl/` 和 `docs/plans/` 是执行派生，不能与共同基线冲突。
- `aw sync push` 会发布本项目快照到 `projects/<project>/`，但不会自动改 `global/dsl/` 或 `global/plans/`。
- `aw sync push` 会自动刷新 `global/plans/TASK_BOARD.md`，让双方看到最新任务矩阵。
- 修改共享基线必须有工程师确认；修改后双方都要把影响回写到本项目 REQ / DSL / Plan / ATOMIC。
- 进入研发前，双方都要确认：共享 DSL 已审、协作 Plan 已确认、本地派生 Plan 可执行、共享任务看板无冲突。

查看共享基线路径：

```bash
./scripts/aw sync baseline
./scripts/aw sync board
```

每个业务项目里会形成：

```text
project-frontend/
  docs/sync/
    SYNC_CONFIG.md
    README.md
    inbox/      # 拉取到的其他项目快照，只读参考
    outbox/     # 本项目最近一次 push 的本地副本
```

## 重要边界

`aw sync pull` 不会覆盖本项目的 DSL、Plan、代码或流水。

它只把其他项目快照放到：

```text
docs/sync/inbox/<对方项目名>/
```

因此：

- 前端 pull 后，看到的是后端状态参考。
- 后端 pull 后，看到的是前端状态参考。
- 任何需求变更、接口变更、Bug、阻塞，都必须再通过本项目自己的 `aw req change`、`aw bug add`、`aw agents handoff` 等命令落账。
- 不要直接把 inbox 文件当成本项目真源。

## 第一次配置

### 1. 前端项目配置

进入前端项目：

```bash
cd workspace/project-frontend
./scripts/aw init
./scripts/aw sync init ../project-harness --project frontend --agent frontend-agent --role frontend
./scripts/aw sync status
```

结果：

- 创建 `docs/sync/SYNC_CONFIG.md`
- 创建 `docs/sync/inbox/`
- 创建 `docs/sync/outbox/`
- 初始化 `../project-harness/projects/`

### 2. 后端项目配置

进入后端项目：

```bash
cd workspace/project-backend
./scripts/aw init
./scripts/aw sync init ../project-harness --project backend --agent backend-agent --role backend
./scripts/aw sync status
```

## 每天开始任务前

前端 Agent 开始工作前：

```bash
cd workspace/project-frontend
./scripts/aw sync pull --from backend
./scripts/aw sync status
```

然后让 Agent 读取：

```text
../project-harness/global/plans/TASK_BOARD.md
docs/sync/inbox/backend/MANIFEST.md
docs/sync/inbox/backend/docs/handoff/
docs/sync/inbox/backend/docs/requirements/
docs/sync/inbox/backend/docs/plans/
docs/sync/inbox/backend/docs/agents/
docs/sync/inbox/backend/docs/SERVICE_CATALOG.md
```

后端 Agent 开始工作前：

```bash
cd workspace/project-backend
./scripts/aw sync pull --from frontend
./scripts/aw sync status
```

然后让 Agent 读取：

```text
../project-harness/global/plans/TASK_BOARD.md
docs/sync/inbox/frontend/MANIFEST.md
docs/sync/inbox/frontend/docs/handoff/
docs/sync/inbox/frontend/docs/requirements/
docs/sync/inbox/frontend/docs/plans/
docs/sync/inbox/frontend/docs/agents/
docs/sync/inbox/frontend/docs/SERVICE_CATALOG.md
```

## 完成任务后发布快照

前端完成一个任务后：

```bash
cd workspace/project-frontend
./scripts/aw task complete AT-T-FE-001
./scripts/aw agents handoff \
  --from frontend-agent \
  --to backend-agent \
  --scope AT-T-FE-001 \
  --done "前端页面字段和接口依赖已整理" \
  --todo "后端确认接口字段和错误码" \
  --risk "status 字段枚举仍待确认" \
  --evidence "docs/plans/ATOMIC_TASKS_FRONTEND.md; docs/handoff/PROJECT_HANDOFF.md" \
  --related AT-T-FE-001
./scripts/aw sync push --task AT-T-FE-001 --note "前端字段依赖已更新，等待后端确认 status 枚举。"
```

后端完成一个任务后：

```bash
cd workspace/project-backend
./scripts/aw task complete AT-T-BE-001
./scripts/aw agents handoff \
  --from backend-agent \
  --to frontend-agent \
  --scope AT-T-BE-001 \
  --done "接口路径、入参、出参、错误码已实现" \
  --todo "前端联调并确认空态和错误态展示" \
  --risk "分页最大 pageSize 需要产品确认" \
  --evidence "docs/SERVICE_CATALOG.md; docs/handoff/PROJECT_HANDOFF.md" \
  --related AT-T-BE-001
./scripts/aw sync push --task AT-T-BE-001 --note "后端接口契约已更新，前端可开始联调。"
```

## 接口变更怎么处理

例如前端发现需要新增字段 `avatarUrl`。

前端项目中：

```bash
./scripts/aw req change AT-T-FE-001 "用户列表需要新增 avatarUrl 字段" \
  --impact "影响用户列表头像展示；依赖后端接口返回 avatarUrl" \
  --acceptance "接口返回 avatarUrl 时前端展示头像；为空时展示默认头像"
./scripts/aw bug add "后端用户列表接口缺少 avatarUrl 字段" --source chat --scope AT-T-FE-001
./scripts/aw sync push --task AT-T-FE-001 --note "新增 avatarUrl 字段需求，等待后端确认。"
```

也可以使用编排入口一次完成本项目变更落账、跨 Agent handoff、同步和看板刷新：

```bash
./scripts/aw sync change AT-T-FE-001 "用户列表需要新增 avatarUrl 字段" \
  --to backend-agent \
  --impact "影响后端用户列表接口、前端用户列表展示、接口契约" \
  --acceptance "接口返回 avatarUrl；前端正常显示头像" \
  --risk "后端不补字段会阻塞前台验收"
```

`aw sync change` 会自动执行：

1. `aw req change`
2. `aw agents handoff`
3. `aw sync push`
4. `aw sync board`
5. 输出 `project-harness` 的 Git 提交建议

它不会自动执行 `git commit` / `git push`，跨电脑同步仍需工程师确认。

后端项目中：

```bash
./scripts/aw sync pull --from frontend
./scripts/aw req change AT-T-BE-001 "按前端同步新增 avatarUrl 字段" \
  --impact "用户列表接口响应增加 avatarUrl；不影响旧字段" \
  --acceptance "响应体包含 avatarUrl；为空时返回 null 或空字符串需确认"
./scripts/aw task brief AT-T-BE-001
```

后端不要直接把前端 inbox 的 REQ 当成自己的 REQ；要在后端项目中重新落账，这样后端 DSL / Plan / ATOMIC 才能保持可追溯。

## 阻塞怎么处理

如果前端依赖后端接口，但后端未确认：

```bash
./scripts/aw task blocked AT-T-FE-001
./scripts/aw agents handoff \
  --from frontend-agent \
  --to backend-agent \
  --scope AT-T-FE-001 \
  --done "页面结构已完成" \
  --todo "等待后端确认 /api/users 响应字段" \
  --risk "字段不一致会导致联调返工" \
  --evidence "docs/sync/inbox/backend/MANIFEST.md" \
  --related AT-T-FE-001
./scripts/aw sync push --task AT-T-FE-001 --note "前端阻塞：等待后端确认 /api/users 响应字段。"
```

后端开始前：

```bash
./scripts/aw sync pull --from frontend
./scripts/aw task brief AT-T-BE-001
```

## 两个 Codex 会话怎么说

前端 Codex 会话：

```text
使用 agentworkflow。
当前项目是 frontend，使用 agent 团队和 aw sync。
开始任务前先执行 aw sync pull --from backend，读取 docs/sync/inbox/backend。
如果后端接口、字段、权限、错误码不明确，先记录阻塞，不要猜。
完成任务后写 handoff / bug / req，再执行 aw sync push --task 当前 AT-T。
```

后端 Codex 会话：

```text
使用 agentworkflow。
当前项目是 backend，使用 agent 团队和 aw sync。
开始任务前先执行 aw sync pull --from frontend，读取 docs/sync/inbox/frontend。
如果前端字段、页面交互、联动边界不明确，先记录阻塞，不要猜。
完成任务后写接口契约、handoff / bug / req，再执行 aw sync push --task 当前 AT-T。
```

## 推荐执行节奏

每个 AT-T 开始前：

```bash
./scripts/aw sync pull --from <peer>
./scripts/aw sync inbox --from <peer>
./scripts/aw agents gate
./scripts/aw task brief <AT-T>
```

工程师确认后：

```bash
./scripts/aw task confirm <AT-T> "已确认：范围=...；验收=...；非目标=..."
./scripts/aw task start <AT-T>
```

完成后：

```bash
./scripts/aw task complete <AT-T>
./scripts/aw agents handoff ...
./scripts/aw sync push --task <AT-T> --note "..."
./scripts/aw sync board
```

`aw sync push` 会自动刷新同步中心 `global/plans/TASK_BOARD.md`。`aw sync board` 用于显式查看共享任务看板。两边 Agent 开始任务前都应读这个看板，确认：

- 自己当前 AT-T 是否依赖对方未完成任务。
- 对方是否已经进入联调或阻塞。
- 前端 / 后端本地 ATOMIC 是否和共享协作 Plan 的顺序冲突。
- 是否需要先写 handoff / bug / req change，而不是继续编码。

## 通用跨端事件

不只需求变更需要同步。跨端协作中的问题、阻塞、接口契约、Bug、任务完成、共同决策和交接，都应该用统一事件机制记录和同步：

```bash
./scripts/aw sync event \
  --type complete|change|block|question|contract|bug|decision|handoff \
  --task <AT-T> \
  --to <peer-agent> \
  --summary "事件摘要" \
  --impact "影响范围" \
  --acceptance "验收或采纳标准" \
  --risk "不处理的风险" \
  --evidence "证据路径"
```

事件类型建议：

| 类型 | 何时使用 | 自动动作 |
|------|----------|----------|
| `complete` | 完成会解除对方依赖的任务 | 写事件、handoff、push、board |
| `change` | 需求、字段、权限、状态、验收变化 | `aw req change`、handoff、push、board |
| `block` | 当前任务被对方接口/决策/字段阻塞 | `aw task blocked`、handoff、push、board |
| `question` | 需要对方确认字段、错误码、权限、联动边界 | 写事件、handoff、push、board |
| `contract` | 接口契约、DTO、枚举、错误码、权限矩阵变化 | 写事件、handoff、push、board |
| `bug` | 跨端 Bug 或疑似 Bug | `aw bug add`、handoff、push、board |
| `decision` | 跨端共同决策 | 写事件、handoff、push、board |
| `handoff` | 普通交接 | 写事件、handoff、push、board |

查看对方同步来的事件：

```bash
./scripts/aw sync pull --from <peer>
./scripts/aw sync inbox --from <peer>
```

`aw sync event` 不会自动执行 Git 提交或 push。跨电脑协作时，它会输出 `project-harness` 的 Git 提交建议，仍需工程师确认。

进入下一项前：

```bash
./scripts/aw sync check
./scripts/aw trace check
./scripts/aw handoff --check
```

## 常见问题

### 是否需要一个真正的 Git 仓库做 project-harness？

不强制。可以是普通本地目录，也可以是 GitHub 仓库。

如果前后端是两个团队协作，建议把 `project-harness` 做成 GitHub 仓库，便于审计、回滚和多人同步。

### pull 会不会把后端 DSL 覆盖到前端？

不会。`pull` 只写入 `docs/sync/inbox/<project>/`。

前后端共同 DSL / 协作 Plan 不靠 `pull` 覆盖本地文件，而是放在同步中心 `global/dsl/` 和 `global/plans/`。双方 Agent 读取它作为共同基线，再分别回写本项目的派生 DSL / Plan。

### push 会不会推代码？

不会。`push` 只推工作流快照，不推业务代码。

### API contract 放哪里？

当前推荐放在以下任一位置，并随 `sync push` 一起发布：

- `docs/SERVICE_CATALOG.md`
- `docs/dsl/` 的边界或事件文件
- `docs/requirements/`
- `docs/handoff/PROJECT_HANDOFF.md`

如果项目需要更正式的接口契约，可新增 `docs/contracts/`，并在后续扩展 `aw sync` 纳入同步范围。

### 单仓库前后端还需要 aw sync 吗？

通常不需要。单仓库直接用：

```bash
./scripts/aw agents assign --role developer --owner frontend-agent --allowed frontend/ --blocked backend/
./scripts/aw agents assign --role developer --owner backend-agent --allowed backend/ --blocked frontend/
./scripts/aw agents gate --strict
```

## 最小可跑示例

```bash
mkdir -p demo/frontend demo/backend demo/project-harness

cd demo/frontend
./scripts/aw init
./scripts/aw sync init ../project-harness --project frontend --agent frontend-agent --role frontend
./scripts/aw sync push --task AT-T-FE-001 --note "frontend ready"

cd ../backend
./scripts/aw init
./scripts/aw sync init ../project-harness --project backend --agent backend-agent --role backend
./scripts/aw sync pull --from frontend
cat docs/sync/inbox/frontend/MANIFEST.md
./scripts/aw sync check
```
