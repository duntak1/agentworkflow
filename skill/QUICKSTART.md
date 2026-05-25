# agent-workflow — 10 分钟上手（任意 AI 工具）

## 1. 装入工作流包

**方式 A — 从源码仓（任意 IDE）：**

```bash
git clone <repo> agentworkflow && cd your-app
/path/to/agentworkflow/scripts/aw install . --adapters
chmod +x scripts/aw scripts/*.sh
./scripts/aw setup
./scripts/aw demo      # 可选：在临时目录跑完整演示
./scripts/aw dashboard
./scripts/aw memory inject
./scripts/aw status --json
./scripts/aw capabilities --json
```

**方式 B — 仅 Cursor Skill（可选）：**

```bash
./scripts/sync-skill.sh   # 在 agentworkflow 源码仓执行
~/.cursor/skills/agent-workflow/scripts/aw install . --adapters
```

**方式 C — 从远程仓库安装 Cursor Skill（可选）：**

```bash
./scripts/install-cursor-skill.sh https://github.com/<you>/agentworkflow.git
~/.cursor/skills/agent-workflow/scripts/aw install . --adapters
```

## 2. 选择你的工具（已 `--adapters` 可跳过）

| 工具 | 命令 |
|------|------|
| 全部 | `aw adapters --all` |
| Claude Code | `aw adapters --claude` |
| Codex | `aw adapters --codex` |
| Copilot | `aw adapters --copilot` |
| Cursor | `aw adapters --cursor` |
| Windsurf | `aw adapters --windsurf` |
| Cline | `aw adapters --cline` |
| Continue | `aw adapters --continue` |
| 网页 / IM | `aw paste session` |

## 3. 阶段 0 → 研发

见 [reference.md](reference.md) 与安装后的 `agent-workflow/PRODUCT_INPUT_WORKFLOW.md`。

```bash
aw project scan                         # 先扫描项目内容，判断全新 / 已有
aw config init --project-stage 1|2       # 工程师确认后写入阶段
aw config init --project-kind 1|2        # GitHub 仓库 / 本地 Git 仓库
aw config init --build-target 1|2|3      # 前端 / 后端 / 前后端
# 若 build-target=3 且前后端分仓 / 双项目：先 aw sync init <project-harness> ...，再拆 Plan
aw dsl → aw check dsl → aw dsl review docs/dsl/DSL_DRAFT.md --write → aw approve dsl docs/dsl/DSL_DRAFT.md --plan
aw dsl suite feature "Feature title"  # 复杂项目：多维 DSL 套件
aw rules init && aw rules review && aw check rules
aw paste plan-write → aw approve plan docs/plans/PLAN_xxx.md
aw check plan && aw check config && aw check tp
aw confirm docs/dsl/DSL_DRAFT.md docs/plans/PLAN_xxx.md
aw status              # shows current AT-T when one is active
aw next
aw task brief AT-T1-001       # 开始前先沟通需求，不允许猜
aw task confirm AT-T1-001 "已确认：范围、验收、非目标清楚"
aw context plan --task AT-T1-001
aw context gate --task AT-T1-001
aw req new export-permission "口述新增：导出按钮需要权限控制" --type 口述新增 --impact "页面按钮、后端权限" --acceptance "无权限不可见"
aw task start AT-T1-001
aw paste task          # 单任务 Agent 提示块
aw req change AT-T1-001 "新增导出按钮权限控制" --impact "页面按钮、后端权限、验收用例" --acceptance "无权限不可见，有权限可导出"
aw task complete AT-T1-001     # 自动 verify；通过则完成，失败则写 AI_BUG_LOG
aw bug add "用户反馈保存后列表未刷新" --source chat --scope AT-T1-001
aw task blocked AT-T1-001     # optional: mark blocker
aw tp new <slug> "title"    # optional §11 用例
aw tp link AT-T1-001 <TP>   # Verify 列追加 TP:path
aw memory add decision "Use shadcn table" --type procedural --source "PLAN_xxx" --body "Reusable table pattern for this repo."
aw memory inject            # 新会话注入记忆摘要
```

定向拆任务：

```bash
aw approve dsl docs/dsl/DSL_DRAFT.md --plan --domain frontend  # 只拆前端计划/任务
aw approve dsl docs/dsl/DSL_DRAFT.md --plan --domain backend   # 只拆后端计划/任务
```

可自动落盘时：

```bash
aw dsl apply --file /tmp/DSL.md
aw plan apply --plan-file /tmp/PLAN.md --atomic-file /tmp/ATOMIC_TASKS.md --slug feature
```

多 DSL / Plan 时：

```bash
aw dsl list && aw dsl use docs/dsl/DSL_DRAFT.md
aw plan list && aw plan use feature
```

填写验证命令：

```bash
aw config init --frontend "React" --ui "shadcn/ui" --lint "pnpm lint" --test "pnpm test" --build "pnpm build" --e2e "pnpm test:e2e"
```

安装 CI：

```bash
aw ci install
```

快速证明能力：

```bash
aw demo
```

## 4. 换 IDE 时

同一仓库、同一 `docs/dsl/` 与 `docs/plans/`，只需在新 IDE 中 `@agent-workflow/INVOCATION.md` 或依赖已安装的适配文件。

## 5. 诊断 / 升级 / 移除

```bash
aw doctor
aw upgrade --adapters --ci
aw remove --adapters --ci        # dry-run
aw remove --adapters --ci --execute
```
