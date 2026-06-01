# agent-workflow / Skill 交接路线图

> **给下一个 AI 工具用**：本文档汇总「已做 / 未做 / 待做 / 怎么做」。  
> **仓库**：`/Users/mayan/Library/Mobile Documents/com~apple~CloudDocs/Project/项目/agentworkflow`  
> **最后更新**：2026-05-19（P0–P5 + 产品化收口已落地，`aw demo` / `e2e-smoke` 通过）

---

## 1. 项目目标（一句话）

打造**工具无关**的通用交付 Skill + CLI：  
`Reference → DSL（已审）→ Plan（可执行）→ confirm → AT-T 单任务研发（A→E）→ verify → done → commit`  
支持 Claude / Codex / Copilot / Cursor / Windsurf / Cline / Continue / QoderWork / TraeIDE / Lingma / OpenClaw / qclaw 等。

---

## 2. 仓库结构（真源）

| 路径 | 角色 |
|------|------|
| `agent-workflow/` | 流程与政策真源（INVOCATION、AICODING、adapters、templates） |
| `skill/` | Cursor Skill 真源（`SKILL.md`、`QUICKSTART.md`、`reference.md`） |
| `scripts/aw` | 统一 CLI 入口 |
| `scripts/*.sh` | 子命令实现 |
| `docs/` | 本 meta 仓的模板样例（业务仓由 `aw init` 生成） |
| `.cursor/skills/agent-workflow/` | `sync-skill.sh` 同步产物（可删可重建） |
| `dist/` | 构建产物（`.gitignore` 或发布用，勿当编辑真源） |

**同步命令（Cursor）：**

```bash
cd /path/to/agentworkflow
./scripts/sync-skill.sh          # → ~/.cursor/skills/agent-workflow + aw-delivery
./scripts/check-skill-source.sh
./scripts/e2e-smoke.sh
```

---

## 3. 端到端流程（当前可跑通）

```mermaid
flowchart LR
  A[aw install + init] --> B[reference + aw dsl]
  B --> C[aw dsl write / paste]
  C --> D[aw approve dsl]
  D --> E[aw plan + plan write]
  E --> F[aw approve plan]
  F --> G[aw check plan/config]
  G --> H[aw confirm]
  H --> I[aw next / task start]
  I --> J[aw paste task]
  J --> K[aw tp link optional]
  K --> L[aw verify]
  L --> M[aw task done]
  M --> N[aw commit]
```

**闸门（必须满足才能写业务代码 / 跑 next）：**

1. DSL 元数据 **状态 = 已审**
2. Plan 元数据 **状态 = 可执行**
3. 已执行 **`aw confirm <dsl> <plan>`**（生成 `ENGINEERING_INDEX.md` + `docs/.aw-workflow.json`）
4. 存在 **`ATOMIC_TASKS_<slug>.md`** 且含 AT-T 行

**pre-commit（业务仓）：** DSL 非已审时拦截 `frontend/`、`src/` 等（`SKIP_DSL_GATE=1` 可跳过）。

---

## 4. CLI 命令清单（已实现）

### 4.1 安装与初始化

| 命令 | 状态 | 说明 |
|------|------|------|
| `aw install [path] [--adapters]` | ✅ | 拷贝 `agent-workflow/` + `scripts/` + IDE 适配 |
| `aw init` | ✅ | `reference/`、`docs/dsl|plans|quality`、PROJECT_CONFIG 等 |
| `aw adapters --all\|…` | ✅ | Claude/Codex/Copilot/Cursor/Windsurf/Cline/Continue/QoderWork/TraeIDE/Lingma/OpenClaw/qclaw |
| `aw status` | ✅ | 状态 + 建议下一条命令 |
| `aw setup` | ✅ | 一键 install/init/adapters/CI/status/doctor |
| `aw doctor` | ✅ | 安装、闸门、适配器、CI、配置诊断 |
| `aw demo` | ✅ | 临时目录端到端演示；源码仓转入 `e2e-smoke` |
| `aw upgrade` | ✅ | 刷新 package/scripts/CI/adapters |
| `aw remove` | ✅ | dry-run/execute 移除集成 |
| `aw hooks` | ✅ | 安装 `.githooks` |

### 4.2 阶段 0（产品输入）

| 命令 | 状态 | 说明 |
|------|------|------|
| `aw dsl [A\|B\|C]` | ✅ L1 | 打印 PROMPT（不自动写文件） |
| `aw dsl write` / `aw paste dsl-write` | ✅ L2 | Agent 落盘提示块 |
| `aw approve dsl <file>` | ✅ | 元数据 → 已审 |
| `aw check dsl` | ✅ | 状态、验收、Plan/REQ 链、manifest |
| `aw plan <dsl>` | ✅ L1 | Plan prompt |
| `aw plan write` / `aw paste plan-write` | ✅ L2 | Plan + ATOMIC 落盘提示 |
| `aw approve plan <file>` | ✅ | 元数据 → 可执行 |
| `aw check plan` | ✅ | Plan↔DSL↔ATOMIC、AT-T、TP 路径 |
| `aw check config` | ✅ | PROJECT_CONFIG 占位符 |
| `aw confirm <dsl> <plan>` | ✅ | 任务确认 + 索引 |
| `aw index` | ✅ | 仅扫描刷新索引（≠ confirm） |
| `aw req new` | ✅ | REQ + INDEX |
| `aw tp new` | ✅ | TP + INDEX |
| `aw tp list\|show\|link` | ✅ | TP 与 AT-T 绑定（Verify 列） |

### 4.3 研发执行环（P0）

| 命令 | 状态 | 说明 |
|------|------|------|
| `aw next` | ✅ | 下一 AT-T（带闸门） |
| `aw task start\|done\|show` | ✅ | 改 ATOMIC 表状态 |
| `aw paste task` | ✅ | 单任务 Agent 块（A→E） |
| `aw verify [--task AT-T]` | ✅ | PROJECT_CONFIG + Verify 列；支持 `TP:path` 与 `;` |
| `aw atomic list\|use` | ✅ | 多 Plan 时切换 ATOMIC 文件 |
| `aw commit [-m] [--execute]` | ✅ | verify + 建议提交信息（默认不 git commit） |

### 4.4 校验聚合

| 命令 | 状态 |
|------|------|
| `aw check all` | ✅ layout + dsl + plan + config + req |
| `aw check layout\|dsl\|plan\|config\|req\|tp` | ✅ 分项 |

### 4.5 Skill 发布

| 命令 / 文件 | 状态 |
|-------------|------|
| `sync-skill.sh` | ✅ |
| `check-skill-source.sh` / `check-skill-package.sh` | ✅ |
| `e2e-smoke.sh` | ✅ 含 task + tp link 全流程 |
| `build-skill-archive.sh` | ✅ |
| `.github/workflows/release.yml` | ✅ tag 发 Release |
| `PUBLISH.md` / `LICENSE` | ✅ |

---

## 5. 已删除 / 已瘦身（勿恢复 unless 明确要求）

- `examples/`、`EXAMPLES.md`、示例 REQ/TP
- `docs/product/` 大体积 mermaid 等
- 重复 stub、`ENGINEERING_INDEX` 实例（`.gitignore` 生成物）
- preCompact 占位 REQ 默认流程（hooks 改为可选）

---

## 6. 已知缺口与 Bug 修复史（避免重复踩坑）

| 问题 | 处理 |
|------|------|
| macOS `rm REFERENCE.md` 误删 `reference.md` | 已从 `sync-skill.sh` 去掉 |
| `awk END { exit 1 }` 导致 `aw task get_row` 恒失败 | 已改 `found` 标志 |
| `aw task done` 未 shift TASK_ID | 已修 |
| `aw verify` 裸 `aw` 找不到命令 | 自动 `./scripts/aw` |
| bash 3.2 `[[ =~ a\|b ]]` 解析错误 | 改显式 `==` |
| `init` 未拷贝 TP 模板导致 `aw tp new` 失败 | 已加 `templates/quality/test-plans/` |

---

## 7. 未做 / 待做（按优先级）

### P3 — 高价值（已推进）

| # | 项 | 为什么 | 怎么做（具体步骤） |
|---|-----|--------|-------------------|
| 3.1 | **`aw check tp`** | TP 与 INDEX 已有脚本但未进 `aw check` | ✅ 已接入 `check-aw-all.sh` 与 e2e |
| 3.2 | **L3 自动落盘 DSL/Plan** | 现在 L2 只靠 paste，Agent 易漏字段 | ✅ 已加 `aw dsl apply` / `aw plan apply`，支持文件/stdin、基础结构校验 |
| 3.3 | **`aw status` 显示当前 AT-T** | 多任务时人类迷失 | ✅ 已读 `.aw-workflow.json` 的 `current_task_id` + ATOMIC 行 |
| 3.4 | **`skill/reference.md` 扩充** | 现较短，新命令未全 dokumentiert | ✅ 已增加 CLI 速查，SKILL.md 仍保持递进 |
| 3.5 | **非 Cursor 一键安装 Skill** | 现需 clone + sync | ✅ `install-cursor-skill.sh` 支持本地路径、URL 参数、`AW_SKILL_REPO_URL`、`AW_SKILL_REF`，文档已补 |

### P4 — 体验与质量

| # | 项 | 怎么做 |
|---|-----|--------|
| 4.1 | REQ ↔ DSL ↔ Plan 三角校验 | ✅ `check-req` / `check-dsl` / `check-plan` 校验关联路径与已填写的反向链接 |
| 4.2 | `aw task blocked <id>` | ✅ ATOMIC 状态「阻塞」+ 当前任务保持在 workflow state |
| 4.3 | `aw paste task` 内嵌 TP 摘要 | ✅ 若 Verify 含 `TP:`，paste 自动附 `aw tp show` 摘要 |
| 4.4 | PROJECT_CONFIG 向导 | ✅ `aw config init` 支持参数填充与 package.json 脚本探测 |
| 4.5 | 多 DSL / 多 Plan 选择 | ✅ `aw dsl list/use`、`aw plan list/use`，Plan use 同步 ATOMIC |
| 4.6 | Windows 支持 | ✅ 新增 `agent-workflow/WINDOWS.md`，说明 WSL/Git Bash/PowerShell 调用方式 |

### P5 — 自动化与生态

| # | 项 | 怎么做 |
|---|-----|--------|
| 5.1 | Playwright 执行 TP | ✅ `aw verify --run-e2e` 对 TP 项执行 PROJECT_CONFIG 的 e2e/playwright 命令 |
| 5.2 | GitHub Action 模板 | ✅ 新增 `.github/workflows/agent-workflow-reusable.yml` |
| 5.3 | Skill 版本号与 CHANGELOG 对齐 | ✅ 新增 `skill/VERSION`，`check-skill-source` 校验与 `agent-workflow/VERSION` 一致 |
| 5.4 | 国际化 | ✅ 新增 `agent-workflow/INVOCATION.en.md` 英文副本 |

### P6 — 产品化与发布收口

| # | 项 | 怎么做 |
|---|-----|--------|
| 6.1 | README 问题/方案/支持矩阵 | ✅ 根 README 已补产品化第一屏、能力矩阵与验证范围 |
| 6.2 | `aw demo` | ✅ 新增 demo 子命令，源码仓复用 e2e smoke，业务包走临时目录演示 |
| 6.3 | CLI 版本显示 | ✅ `aw help` 动态读取 VERSION，不再写死 v1.0 |
| 6.4 | 发布包校验覆盖 demo | ✅ `check-skill-package.sh` 检查 `aw-demo.sh`、路由与文档 |

### P7 — 生态增强

| # | 项 | 怎么做 |
|---|-----|--------|
| 7.1 | 机器可读状态 | ✅ `aw status --json` 输出 DSL/Plan/confirm/AT-T/next |
| 7.2 | 能力摘要 | ✅ `aw capabilities` / `aw capabilities --json` 输出版本、适配器、核心命令与证明路径 |
| 7.3 | Codex plugin metadata | ✅ 新增 `.codex-plugin/plugin.json` 作为原生插件入口元数据 |
| 7.4 | 终端 dashboard | ✅ `aw dashboard` 只读聚合当前状态、能力与机器可读入口 |
| 7.5 | Marketplace metadata | ✅ 新增 `.agents/plugins/marketplace.json`，repo-root local entry 指向当前仓库 |
| 7.6 | Plugin metadata check | ✅ `aw check plugin` 校验 plugin/marketplace JSON、版本、entry、policy，并提示发布 TODO |
| 7.7 | Agent memory layer | ✅ `aw memory init/add/list/search/show/archive/inject` 文件化记忆，支持来源、置信度、生命周期与敏感信息检查 |
| 7.8 | Multi-file DSL suite | ✅ `aw dsl suite` 生成需求、页面、交互、事件、联动边界、验收多维 DSL 套件 |

### 明确不做（除非用户改需求）

- 在 meta 仓恢复「示例业务代码」
- 默认开启 preCompact 占位 REQ
- 未审 DSL 时自动写 `src/`（闸门必须保持）

---

## 8. 给下一个 AI 的「第一条任务」建议

复制以下 prompt 到新工具：

```text
阅读 @docs/handoff/AGENTWORKFLOW_ROADMAP.md 与 @agent-workflow/INVOCATION.md。

目标：从 P7 后继续做发布信息收口：补齐 plugin TODO URL/email，保持完整验证与 dist 构建。

约束：
- 真源在 agent-workflow/ 与 scripts/，改完跑 ./scripts/e2e-smoke.sh
- 更新 skill/SKILL.md（<500 行）、CHANGELOG、sync-skill.sh
- 不要恢复 examples/ 或削弱 DSL 已审闸门
```

---

## 9. 测试清单（每次改 scripts 必跑）

```bash
cd /path/to/agentworkflow
chmod +x scripts/*.sh
./scripts/check-skill-source.sh
./scripts/e2e-smoke.sh
# 若在业务仓验证：
./scripts/aw install . --adapters
./scripts/aw init
./scripts/aw status
./scripts/aw check all
```

---

## 10. 关键文件索引（改哪里）

| 要改… | 文件 |
|--------|------|
| 新子命令 | `scripts/aw` case + 新 `scripts/aw-*.sh` |
| 任务表逻辑 | `scripts/_aw-task-lib.sh` |
| Verify 解析 | `scripts/_aw-verify-lib.sh`、`aw-verify.sh` |
| 闸门 | `aw_gate_coding_ready` in `_aw-task-lib.sh` |
| 模板 | `agent-workflow/templates/**` |
| Cursor Skill 文案 | `skill/SKILL.md`、`QUICKSTART.md` |
| 流程文档 | `agent-workflow/INVOCATION.md`、`PRODUCT_INPUT_WORKFLOW.md` |
| IDE 规则 | `agent-workflow/adapters/*`、`install-aw-adapters.sh` |
| e2e | `scripts/e2e-smoke.sh` |

---

## 11. Skill 合格标准（自检表）

- [ ] `skill/SKILL.md` frontmatter + <500 行，指向 QUICKSTART/reference
- [ ] `sync-skill.sh` 后 `check-skill-package.sh` 全绿
- [ ] `e2e-smoke.sh` 全绿（install → init → dsl/plan/confirm → task → tp → verify）
- [ ] 任意 IDE：`aw install --adapters` 后有入口文件
- [ ] INVOCATION 与 `aw help` 命令一致
- [ ] 无 `examples/` 回流、无 case-insensitive `rm` 陷阱

---

## 12. 版本里程碑建议

| 版本 | 内容 |
|------|------|
| **v1.0** | P0–P2：CLI 全流程 + 多 IDE + Skill 发布 + e2e |
| **v1.1**（当前） | P3–P7：check tp、status 增强、L3 apply、生命周期命令、产品化 README、`aw demo`、`aw status --json`、`aw capabilities`、Codex plugin metadata、`aw dashboard`、marketplace metadata |
| **v1.2** | 能力摘要自动化扩展、真实发布 URL 收口 |

---

*本文档由 agent-workflow 维护会话生成，供换工具续作。*
