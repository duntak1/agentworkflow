# AI 辅助编码工作流（Karpathy Guidelines 落地版）

本流程将 [Karpathy Guidelines](https://x.com/karpathy/status/2015883857489522876)（见本地 skill：`karpathy-guidelines`）映射为**可重复执行的步骤**，与本目录 **`CLAUDE.md` / `AGENTS.md`**（仓库根另有同名 **入口文件**）**并行适用**：仓库约定优先；本文负责「怎么和 AI 协作才不翻车」。

**取舍：** 明显琐事可跳过部分检查项；涉及权限、金额、库表、安全时**不得简化**。与「简单优先」冲突时以 **`CLAUDE.md` 禁令与安全底线** 为准。

**配套：** 版本、`CHANGELOG`、Git、Bug、复测等留痕与门禁见 [`VERSION_CHANGELOG_QUALITY_LOOP.md`](./VERSION_CHANGELOG_QUALITY_LOOP.md)。

**真源：** Issue 系统、版本字段、CI、本地验证命令以 **[`REPOSITORY.md`](./REPOSITORY.md)**（根目录 [`README.md`](../README.md) 为短入口）为准；维护者落地勾选见 [`REPO_LANDING_CHECKLIST.md`](./REPO_LANDING_CHECKLIST.md)。

---

## 与产品 DSL（`docs/dsl/`）的分工

- **阶段 0（产品输入）**：见 [`PRODUCT_INPUT_WORKFLOW.md`](./PRODUCT_INPUT_WORKFLOW.md) — `reference/` → `docs/dsl/` → 人类审 **已审** → `docs/plans/`。
- **`docs/dsl/`**：固化 **功能意图、页面结构、行为状态、验收锚点**；**不含**设计风格、主题 token 全文。
- **本包 `AGENT_RULES` / `CLAUDE`**：技术栈、组件用法、工程禁令（见 `docs/PROJECT_CONFIG.md` 与 `docs/ENGINEERING_RULES.md`）；写界面代码时对齐 **视觉**，再对照 DSL **结构与行为**。

---

## 端到端时间线（人类 + AI，推荐顺序）

按任务类型选一列执行；**从左到右尽量不打乱顺序**（Hotfix 见质量文档中的收窄条款）。

| 阶段 | 功能 / 较大改动 | Bug 修复 | 纯文档 / 无关行为配置 |
|------|-----------------|----------|------------------------|
| **0a. Reference** | `./scripts/aw init`（首次）；人类填充 `reference/` + `manifest.yaml` | — | — |
| **0b. DSL** | `./scripts/aw dsl` → 人类审阅 → 状态 **已审** | — | — |
| **0c. Plan** | `./scripts/aw plan docs/dsl/…md` → 人类标 **可执行** → `aw confirm` | — | — |
| **1. 入口** | 需求/Issue 描述 + 假设清单（阶段 A） | 建 Bug 单或补全环境/复现（见 Issue 模板） | 建 Issue 或直接 PR（团队定） |
| **2. 验收** | 目标、非范围、验收标准、验证命令（阶段 B） | 期望/实际行为写死；验证方式可复现 | 写明「无行为变更」则跳过测试条款 |
| **3. 协作** | AI：最短方案说明 → 再允许改代码（阶段 C/D） | 优先失败测试→修复（覆盖不了则手工步骤进 Issue） | 人类或 AI 直接改，保持手术式 |
| **4. 验证** | **§11**：书面用例齐全 + 真实浏览器/应用或集成环境按用例通过（见 `VERSION_CHANGELOG_QUALITY_LOOP.md`） | 同左 + Bug 在同级真实环境下 **不可复现** | 声明无行为变更时可仅抽检文档链接 |
| **5. 留痕** | `[Unreleased]` 按需更新（见质量文档 §「CHANGELOG 触发」） | `Fixed` + `Fixes #id` | `Changed` 一条或注明仅文档 |
| **6. 评审** | PR + Code Review；按需 UAT | PR；关联 Issue | 轻量 review |
| **7. 合并后** | 按发布节奏 bump/tag（见质量文档 §3） | Issue 关闭注明验证版本/tag | 无 |

**合成一句话：** 先能把「什么叫做完」说清楚并落到**命令 + 全面用例 + 真实环境证据**，再写代码；合并前 **diff 可追溯 + §11 验证留痕 + 评审勾选**；进入下一项前确认**完整性 / 可追溯性 / 可维护性 / 可交接性**四项闭环。

---

## 总览：一条主线

```
澄清意图 → 写清验收标准与全面用例 → 最小方案 → 小步提交 → 自动化 + 真实环境验证 → 留痕与评审 → 再下一刀
```

---

## 阶段 A — 想清楚再写（Think Before Coding）

**强制前置：** 每个 AT-T 子任务开始写代码前，先运行 `./scripts/aw task brief <AT-T>` 输出需求沟通包。Agent 必须像真实研发一样追问用户问题、边界、验收、异常态、联动和非目标；不允许猜测需求。工程师明确确认后，运行 `./scripts/aw task confirm <AT-T> "已确认：..."`，再 `./scripts/aw task start <AT-T>`。

**目的：** 不让 AI（也不让自己）在模糊需求上盲写。

| 动作 | 产出 |
|------|------|
| 写出**假设列表**（业务、权限、边界） | 若有不确定项 → **先问人/查文档**，禁止猜规则 |
| 存在多种理解时 | **列出选项**让负责人选，禁止静默选一种 |
| 发现更简单路径 | 在对话里**明说**并说明取舍 |
| 卡住时 | **点名哪里不清楚**，再问；不要堆代码试探 |
| 口述新增需求 | 运行 `aw req new <slug> "标题" --type 口述新增 --impact "..." --acceptance "..."`，进入统一需求表 |
| 研发中需求变化 | **暂停编码**，运行 `aw req change <AT-T> "摘要" --impact "..." --acceptance "..."`，进入同一需求表（需求类型=研发中变更），回写 REQ / DSL / Plan / ATOMIC 后重新确认 |

**对话里可复制的一句：**  
「请先列出你对需求的假设与不确定点；选项多于一种时请列出让我选，不要默认。」

---

## 阶段 B — 目标驱动（Goal-Driven Execution）

**目的：** 把「做好」变成**可验证**的句子。

把任务改写成下面格式（贴在 Issue / 对话开头）：

```text
目标：<一句话业务结果>
不在范围内：<明确不写什么>

验收标准（必须可检查）：
1. …
2. …

验证方式：
- 命令：…（lint / unit / build …）
- **真实环境：** 浏览器（Playwright/Cypress 等）或目标客户端 / 后端集成环境（见 `VERSION_CHANGELOG_QUALITY_LOOP.md` §11）
- **书面用例：** Issue、`docs/quality/test-plans/…` 或与自动化 describe 映射表（须覆盖主路径、边界、错误态）

契约/文档（若适用）：OpenAPI / README / 迁移脚本路径 …
```

**弱验收示例（要避免）：**「正常工作」「体验好一点」。  
**强验收示例：**「提交非法字段 X 时接口返回 400 且 message 含 …」「图表在空数据时展示占位文案」。

多步骤时，用**带验证锚点**的小计划（每条后面是能跑的检查）：

```text
1. <步骤> → 验证：<命令或断言>
2. <步骤> → 验证：<命令或断言>
```

---

## 阶段 C — 先简单后复杂（Simplicity First）

**目的：** 最少代码解决问题，拒绝「顺便重构」。

实现前自问：

- [ ] 是否超出本次验收范围？→ 砍掉
- [ ] 是否在为单次使用造抽象？→ 内联或延后
- [ ] 是否加了未要求的配置/开关？→ 删除
- [ ] 是否在处理「理论上不可能」的分支？→ 删掉过度防御
- [ ] 若删掉一半行数仍能过验收？→ **重写更短版本**

**Senior test：** 资深同事会不会说「搞复杂了」？会则简化。

---

## 阶段 D — 手术式改动（Surgical Changes）

**目的：** diff 只服务当前需求，便于 review 与回滚。

- [ ] **不**顺手改相邻注释、格式、命名（除非本任务必需）
- [ ] **不**重构「看着不爽」但未坏的代码
- [ ] 风格与文件内现有代码**一致**
- [ ] 发现无关死代码 → **只提醒**，不擅自删
- [ ] 仅删除/整理**因本次修改**产生的无用 import、变量、函数

**自测：** 每一行变更能否追溯到「验收标准里的某一条」或「Bug 复现消除」？不能则收回。

---

## 阶段 E — 验证闭环（Loop Until Verified）

**目的：** AI 生成 ≠ 完成；必须经工具测试 + **真实环境**盖章（默认强制，见 `VERSION_CHANGELOG_QUALITY_LOOP.md` **§11**）。

建议顺序：

1. **一键完成**：优先执行 `./scripts/aw task complete <AT-T>`；它会读取任务 Verify 列与 `PROJECT_CONFIG`，验证通过才置为 `已完成`，验证失败自动记录 `docs/handoff/AI_BUG_LOG.md` 并保持 `进行中`。
2. **本地命令**：构建 / 单测 / lint（以 [`REPOSITORY.md`](./REPOSITORY.md)、[`CLAUDE.md`](./CLAUDE.md) 末尾命令为准；若仍为占位，**先在子项目填真实命令**）。
3. **真实环境与全面用例**：按 §11 在浏览器、目标应用或集成进程中执行**书面用例**；禁止仅以简易沙盒结果为唯一证据。
4. **缺陷**：可自动化层优先 **失败测试 → 修复 → 绿**；例外见 **§13**（仍须最小真实环境证据或登记债务）。
5. **不通过**：把**失败日志 + 当前假设**贴回对话，回到阶段 B 收紧验收，再改一小步。
6. **记录**：所有 Bug / 疑似 Bug 必须进入 [`docs/handoff/AI_BUG_LOG.md`](../docs/handoff/AI_BUG_LOG.md)。测试或校验命令失败时由 `aw task complete` 追加来源 `test`；用户口述、审查发现、运行时异常、线上反馈用 `./scripts/aw bug add "摘要" --source chat|review|runtime|prod --scope <范围>`。

完成一个大需求或 AT-T 后、开始下一项代码前，执行四项闭环自检：

| 闭环目标 | 最低要求 |
|----------|----------|
| 完整性 | REQ / DSL / Plan / ATOMIC / TP 已覆盖需求、页面、交互、事件、联动边界、验收、非目标 |
| 可追溯性 | 代码 diff、Bug、测试、CHANGELOG、Git 提交可反查到 REQ / DSL / Plan / AT-T |
| 可维护性 | 工程规范、成熟方案选择、必要注释、测试、`docs/FILE_INDEX.md` 已同步 |
| 可交接性 | Handoff / Memory（如可复用）/ 验证证据 / 风险 / 下一步 / 提交状态已更新 |

缺任一项时，补齐后再继续；如必须例外，写入 REQ / Bug / Handoff，并注明责任人与后续动作。

---

## Token / 上下文预算（真实写代码时）

目标：**少重复、少附件、少闲聊**，把额度用在「当前文件的 diff + 验收」上。与 **Karpathy「手术式」**一致：范围越小，通常越省 token。

### 文档怎么引用（分层，避免每条消息堆全文）

| 层级 | 文件 | 何时用 |
|------|------|--------|
| 最薄 | `AGENT_RULES.md` | 日常改代码默认规则面；已在 IDE Rules 挂载则 **勿在对话再 `@`/粘贴** |
| 路由 | `AGENTS.md` | **刻意短小**：Codex 等默认入口 + 链接表；**不再**承载长栈/长输出细则（省 token） |
| 详版 | `CLAUDE.md` | 库表/金额/安全/命令不明时 **只打开相关章节**，勿默认整文件复读 |

**Cursor / 带 Project Rules 的工具：** 若 `AGENT_RULES` 已在 **Active Rules** 里加载，对话里 **不要再粘贴** `AGENT_RULES.md` / `CLAUDE.md` 全文——直接写任务与 `@` 源码路径即可。

### 对话里少烧 token 的习惯

- **附件**：只 `@` **本轮要改的文件**（或 1～3 个邻居）；不要 attach 整个 `src/`；Composer 里无关文件主动 **Remove from context**。  
- **需求**：一句话目标 + **验收 3 条以内** + **验证命令一行**；历史背景用 `PROJECT_HANDOFF.md` / `REQ-…` **路径引用**，避免粘贴 REQ 全文（很长时）。  
- **§11 用例**：贴 **`docs/quality/test-plans/xxx.md` 路径**或「用例标题 checklist」，除非评审需要再展开全文。  
- **日志**：只贴 **几十行内**相关栈 + **文件:行号**；禁止把完整 CI、`pnpm build` 上万行输出塞进对话（用文件或 CI 链接）。  
- **迭代**：拆成 **小步**（每步可运行验证），避免单条消息要求「把整个模块重写」。  
- **输出**：要求 AI **先给最短方案再改代码**（阶段 C）可减少无效大段生成。

### 与「全面测试」怎么兼得

§11 要真实环境验证，不等于每次对话都要 **全文复述**用例：**链接 + 本轮需覆盖的子集** 即可；完整证据放在 PR / CI 报告链接。

---

## 会话交接与需求存档（跨上下文）

用于缓解 **AI 上下文长度限制** 与「做完即忘」问题。

| 机制 | 路径 | 何时做 |
|------|------|--------|
| **上下文压缩（Handoff）** | [`docs/handoff/PROJECT_HANDOFF.md`](../docs/handoff/PROJECT_HANDOFF.md) | 大块工作结束、**切换模型/新开窗口前**覆盖更新；写法见 [`HANDOFF_GUIDE.md`](../docs/handoff/HANDOFF_GUIDE.md) |
| **需求持久化（REQ）** | [`docs/requirements/`](../docs/requirements/) | 口述新增和研发中变更都进入 `docs/requirements/INDEX.md`，用“需求类型”区分；研发中的范围、验收、交互、接口、数据、权限、事件联动或测试口径变更，运行 `aw req change` 并回写 DSL / Plan / ATOMIC |
| **项目文件索引（FILE_INDEX）** | [`docs/FILE_INDEX.md`](../docs/FILE_INDEX.md) | 新增 / 删除 / 重命名业务文件时更新一行说明，方便人类工程师定位 AI 代写后需要手改或重点审阅的文件 |

**新会话可复制：**

```text
请先阅读：docs/handoff/PROJECT_HANDOFF.md 与 docs/requirements/INDEX.md。
本轮任务：<一句话>
```

**单人迭代补充：** 接到用户级需求后，**优先**落 REQ（可与 Issue 并行），合并 PR 时在描述中写 `Refs REQ-…`。

---

## 单人迭代模板（日常）

| 次序 | 做什么 |
|------|--------|
| 1 | 建/更新 **Issue**（功能或 Bug） |
| 2 | 写清目标 + 验收 + **全面用例** + 验证命令与真实环境方式（阶段 B） |
| 3 | 列假设与待确认点（阶段 A） |
| 4 | 让 AI 给出**最短**方案说明，再允许写代码（阶段 C） |
| 5 | 实现后跑约定命令；再跑 **§11** 真实环境与全面用例（阶段 E） |
| 6 | PR 附 **用例与验证证据**（报告链接或手工勾选表） |
| 7 | **CHANGELOG** `[Unreleased]` 按需一条（见质量文档触发表） |
| 8 | 四项闭环自检：完整性 / 可追溯性 / 可维护性 / 可交接性 |
| 9 | 提交前 **diff** 自查（阶段 D）；**PR** 勾选自检清单 |
| 10 | Review 通过 → 合并；发布流按质量文档 §3 bump/tag |

---

## 相关文档

| 文档 | 用途 |
|------|------|
| [`REPOSITORY.md`](./REPOSITORY.md) | **团队真源**（Issue、版本字段、CI、本地命令）；根 `README.md` 入口 |
| [`CLAUDE.md`](./CLAUDE.md) | 技术栈、禁令、SOP |
| [`VERSION_CHANGELOG_QUALITY_LOOP.md`](./VERSION_CHANGELOG_QUALITY_LOOP.md) | 版本、`CHANGELOG`、Git、Bug、**§11**、Hotfix、§2.1 分支策略 |
| [`PRODUCT_INPUT_WORKFLOW.md`](./PRODUCT_INPUT_WORKFLOW.md) | 阶段 0：Reference → DSL → Plan |
| [`docs/dsl/README.md`](../docs/dsl/README.md) | **DSL** 模板与闸门（[`docs/dsl/`](../docs/dsl/)） |
| [`../scripts/README.md`](../scripts/README.md) | init / draft-dsl / draft-plan |
| [`REPO_LANDING_CHECKLIST.md`](./REPO_LANDING_CHECKLIST.md) | 维护者一次性配置与门禁自检 |
| [`docs/quality/test-plans/`](../docs/quality/test-plans/) | 书面功能用例目录 |
| [`PROJECT_HANDOFF.md`](../docs/handoff/PROJECT_HANDOFF.md) | 压缩上下文、对接进度（交接真源） |
| [`INDEX.md`](../docs/requirements/INDEX.md) | 需求记录索引 |

本节 **「Token / 上下文预算」** 可与 skill `karpathy-guidelines` 并行：简单 + 手术式本身就是在省无效 token。

---

## 变更记录

- 初版：Karpathy 四块（想清楚 / 简单 / 手术式 / 目标驱动）。
- 优化：端到端时间线；与质量闭环对齐；验收模板增加契约/文档位；单人迭代嵌入 Issue/CHANGELOG/PR。
- 再优化：指向 `REPOSITORY.md`（团队真源）与 `REPO_LANDING_CHECKLIST.md`。
- 测试策略：与质量文档 **§11** 对齐——每功能全面用例 + 真实浏览器/应用或集成环境，禁止简易沙盒作为唯一交付证据。
- 跨会话：`docs/handoff/`（交接压缩）+ `docs/requirements/`（REQ 持久化）。
- Token：`AGENT_RULES` / `AGENTS` / `CLAUDE` 分层引用；附件与日志收窄；与 §11 用「路径 + 子集」而非全文堆砌。
- 目录：与本包内其它流程 Markdown 一并置于 **`agent-workflow/`**（见包内 [`README.md`](./README.md)）。
