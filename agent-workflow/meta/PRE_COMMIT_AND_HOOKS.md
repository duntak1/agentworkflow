# 提交前自动校验与记录（Git Hooks）

目标：**在 `git commit` 之前**自动跑约定校验与（若工程存在）测试；**禁止**在改了流程/脚本等政策路径却不更新 **`agent-workflow/CHANGELOG.md`**（对外条目真源；仓库根 `CHANGELOG.md` 可为入口摘要）的情况下提交。

---

## 一次性安装（每名开发者、每个克隆）

仓库根目录执行：

```bash
./scripts/install-git-hooks.sh
```

会将 `core.hooksPath` 设为 **`.githooks`**（仅作用于本仓库）。

---

## pre-commit 做什么

由 **`scripts/pre-commit-verify.sh`** 实现：

1. **`scripts/check-req-index.sh`** — 每个 `REQ-*.md` 必须在 `docs/requirements/INDEX.md` 中有链接。  
2. **`scripts/check-test-plan-index.sh`** — 每个 `docs/quality/test-plans/TP-*.md` 必须在同目录 **`INDEX.md`** 中有链接（无 TP 文件时校验自动通过）。  
3. **`scripts/`、`.githooks/`** 下 `*.sh` 的 `bash -n` 语法检查。  
4. **`.cursor/hooks/precompact_handoff.py`** — Python `ast` 语法检查（不写 `.pyc`）。  
5. **`.cursor/hooks/ai_bug_autolog.py`** — 同上（若存在）。  
6. **CHANGELOG 门禁**：若暂存文件命中「约定路径」（根目录政策入口、`agent-workflow/`、`docs/`、`scripts/`、`.github/workflows/`、Hooks、`.githooks/`、常见前后端代码路径等），**必须同时暂存 `agent-workflow/CHANGELOG.md`**（根目录 `CHANGELOG.md` 仅为入口时可不修改）。  
   - **豁免**：`docs/handoff/`（日常交接）、`docs/requirements/`、`local/`、纯自动生成快照文件名等（见脚本内 `case`）。  
   - 临时跳过（不推荐）：`SKIP_CHANGELOG_GATE=1 git commit ...`
7. **测试 / 构建（存在依赖时）**：  
   - **仓库根**：有 `package.json` 且已安装 `node_modules`：`pnpm run --if-present test` + `lint`（或 npm 等价）。  
   - **应用子目录（如 `frontend/`、`web/`）**：暂存路径命中且存在 `package.json` + `node_modules` 时，执行该目录 **test** + **build**（以子项目 scripts 为准）。  
     - 跳过：`SKIP_FRONTEND_VERIFY=1 git commit …`（不推荐）。  
   - **Maven**：有 `pom.xml` 且本机有 `mvn`：`mvn -q test`。  
   - 跳过全部工程侧校验：`SKIP_PRE_COMMIT_TESTS=1 git commit …`

环境变量 **`FORCE_FULL_PRE_COMMIT=1`**（由 **`scripts/commit-gate.sh`** 设置）：即使当前 **没有 git 暂存**，也会继续跑上述工程测试（并跳过 CHANGELOG 门禁），便于提交前自检。

---

## 与 `commit-gate` / `git-safe-commit` 的关系

| 脚本 | 作用 |
|------|------|
| [`scripts/commit-gate.sh`](../../scripts/commit-gate.sh) | 跑 `pre-commit-verify.sh`，写 **`local/test-reports/*.md`**；若 **`AI_BUG_LOG.md`** 流水含 `open`/`investigating`，再跑第二轮；可选 **`COMMIT_GATE_FAIL_ON_OPEN_BUGS=1`** 有 open 则直接失败。 |
| [`scripts/git-safe-commit.sh`](../../scripts/git-safe-commit.sh) | `commit-gate` 通过后执行 **`git commit`**；可将 **`--no-verify`** 传给 git（gate 仍会执行）。可选 **`--bump-patch`**。 |

---

## post-commit 做什么

写入 **`local/commit-autolog.jsonl`**（**已被 `.gitignore`**）：一行 JSON，含 `hash`、`subject`、`ts`。用于本机审计；**不会**自动 push。

---

## 诚实边界

| 期望 | 现实 |
|------|------|
| **包内 `CHANGELOG.md` 正文自动生成** | **不会**。门禁只保证「该提交时带着已编辑的包内 CHANGELOG」；内容仍须人写（或由发行工具在发版时汇总）。 |
| **`docs/quality/test-plans/*.md` 自动执行** | **不会**。它们是文档；可用 **`aw tp new`** 生成；断言由业务仓测试框架执行（见 `PROJECT_CONFIG`）。 |
| **根据 Bug 流水自动修代码** | **不会**。`commit-gate` 仅在存在 `open`/`investigating` 时**重复跑同一套校验**；修复仍须人工。 |
| **CI 与本地完全一致** | CI 运行 `SKIP_PRE_COMMIT_TESTS=1` 的 `pre-commit-verify.sh`（无暂存，主要跑静态校验）；与本地「有暂存时」的 CHANGELOG 门禁略有差异属正常。 |

---

## 变更记录

- TP 与 `INDEX.md`、`check-test-plan-index`、`COMMIT_GATE_FAIL_ON_OPEN_BUGS`：见 [`scripts/README.md`](../../scripts/README.md)。
- `commit-gate` / `git-safe-commit`、`FORCE_FULL_PRE_COMMIT`、`new-test-plan`、`REPO_VERSION`：同上。
- 初版：`.githooks` + `pre-commit-verify.sh` + `post-commit` 审计。
