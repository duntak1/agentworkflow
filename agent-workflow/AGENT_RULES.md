# AGENT_RULES（精简 · 可复制到 .cursor/rules）

与 [`CLAUDE.md`](./CLAUDE.md) 语义一致；栈细节以项目根 **`docs/PROJECT_CONFIG.md`** 为准。

## 流程闸门

1. **未 init**：先建议人类运行 `./scripts/aw init`（工具无关，见 `INVOCATION.md`）。
2. **DSL 状态非 `已审`**：只改 DSL/REQ/Reference/Plan 文档，**不写业务代码**。
3. **Plan 状态非 `可执行`**：可拆任务文档，不开始实现 AT-T*。
4. **任务确认后**：人类运行 `./scripts/aw confirm <dsl> <plan>` 生成 `ENGINEERING_INDEX.md`；**不要**把该文件加入 Agent 上下文。
5. **审阅落章**：`aw approve dsl` / `aw approve plan` 改元数据状态（勿手改漏字段）。
6. 工程师说“执行研发任务 / 开始开发 / 做下一个任务”时，不得直接写代码。必须先 `aw next` → `aw task brief <AT-T>`，像真实研发一样和工程师刨根问底确认需求、范围、验收、异常态、联动边界、非目标和风险；工程师确认后执行 `aw task confirm <AT-T> "已确认：..."`，再 `aw context plan --task <AT-T>` → `aw context gate --task <AT-T>` → `aw task start <AT-T>` → `aw paste task` 绑定单任务。
7. 口述新增需求和研发中变更都必须写入 `docs/requirements/INDEX.md`，用“需求类型”区分。口述新增用 `aw req new <slug> "标题" --type 口述新增`；研发中变更立即暂停编码，运行 `aw req change <AT-T> "摘要" --impact "..." --acceptance "..."`，并回写 REQ、DSL、Plan、ATOMIC，重新 `aw task brief` / `aw task confirm` 后才能继续。
8. 完成后：运行 `aw task complete <id>`；它会自动 `verify`，通过才标记完成，失败则写 `docs/handoff/AI_BUG_LOG.md` 并保持 `进行中`。
9. **Git**：pre-commit 在 DSL 非已审时拦截 `frontend/`、`src/` 等业务路径（`SKIP_DSL_GATE=1` 可跳过）。
10. **闭环管理**：进入下一大需求 / AT-T 前，必须确认完整性、可追溯性、可维护性、可交接性都有证据；缺口要补齐，或写入 REQ / Bug / Handoff 的例外、责任人和后续动作。

## DSL vs 实现

- **结构与行为**：以 `docs/dsl/` 为准。
- **视觉 / 组件 API**：以 `CLAUDE.md` + `PROJECT_CONFIG` 栈为准；DSL 不写 token 全文。

## 路径

- 参考材料：`reference/`（读 `manifest.yaml`）。
- 禁止编造 `reference/`、`docs/dsl/` 中不存在的源码路径。
- 需求：`docs/requirements/REQ-*.md` + `INDEX.md`。
- 项目文件索引：`docs/FILE_INDEX.md`，新增 / 删除 / 重命名业务文件时同步更新，供人类工程师定位手改文件。
- 交接：`docs/handoff/PROJECT_HANDOFF.md`；大块结束或换窗口前更新。

## Bug / 测试

- 所有 Bug / 疑似 Bug 必须记录：优先用 `./scripts/aw bug add "摘要" --source chat|test|review|runtime|prod --scope <范围>`。
- 测试失败由 `aw task complete` 自动写 `docs/handoff/AI_BUG_LOG.md`；用户口述、审查发现、运行时异常、线上反馈由 Agent 立即 `aw bug add`。
- 修复 Bug 前，先确认 `AI_BUG_LOG.md` 中已有对应记录；没有则补记。
- 交付证据：真实环境 + 书面用例（见 `VERSION_CHANGELOG_QUALITY_LOOP.md` §11），禁止仅沙盒糊弄。

## 闭环口径

- **完整性**：REQ / DSL / Plan / ATOMIC / TP 必须覆盖需求、页面、交互、事件、联动边界、验收、非目标。
- **可追溯性**：代码、Bug、测试、CHANGELOG、Git 提交都能反查到 REQ / DSL / Plan / AT-T。
- **可维护性**：工程规范、成熟方案选择、必要注释、测试和 `docs/FILE_INDEX.md` 与实现同步。
- **可交接性**：Handoff / Memory / 验证证据 / 风险 / 下一步 / 提交状态足够让新会话或人类工程师接手。

## Engineering Harness 扩展

- 关键 AI 动作、命令、失败、确认点：用 `aw audit add` 记录到 `docs/audit/AGENT_TRACE.md`。
- 高风险路径、新依赖、生产/数据库/安全/破坏性变更：先查 `docs/policy/POLICY.yml`，必要时用 `aw policy decision` 记录审批或例外。
- 研发中新计划 / 新任务：小变更用 `aw plan change`，同范围新增任务用 `aw plan task-add`，任务过大用 `aw task split`；大范围变化新建 Plan / ATOMIC 后重新 approve/confirm。
- 提交前或大改后：用 `aw policy diff` 检查 git diff 中的高风险路径和依赖文件变化。
- 安全发现和新增依赖准入：用 `aw security finding` / `aw security dependency` 记录到 `docs/security/`。
- 安全扫描：用 `aw security scan` 查看可用扫描器；需要执行时显式加 `--run`。
- 服务或模块边界变化：更新 `docs/SERVICE_CATALOG.md`，命令为 `aw service-catalog add`；候选发现用 `aw service-catalog discover`。
- 发布、环境、灰度、回滚、Feature Flag：用 `aw release record` / `aw release flag` 记录到 `docs/release/`；发布前用 `aw release gate` 聚合检查。
- 交付度量：发布、失败、恢复等事件用 `aw metrics record` 记录到 `docs/metrics/DELIVERY_METRICS.md`。
- 可靠性和事故：SLO、Incident、Runbook 用 `aw ops slo|incident|runbook` 记录到 `docs/ops/`。
- 多 Agent 协作：并行开发、评审、测试、安全或发布角色必须用 `aw agents assign|handoff|review` 记录 owner、scope、允许/禁止路径、交接和评审结论。

## Token

- 已在 Active Rules 加载本文件时，对话里勿再粘贴全文。
- 只 `@` 本轮文件；REQ/DSL 用路径引用，非全文。

## 触发语

`按 AI 工作流` · `生成 DSL` · `生成 Plan` · `init 工作流` · `对接进度` · `记需求` · `省 token`
