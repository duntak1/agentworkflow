# Changelog

## [1.1.0] - 2026-05-19

### Added

- P3–P5 delivery improvements: L3 DSL/Plan apply, current AT-T status, TP checks, blocked tasks, TP summaries, config init, multi DSL/Plan selection, Windows notes, e2e TP execution, reusable CI workflow, and English invocation.
- Productized README/Skill positioning inspired by multi-agent tools: problem/solution framing, support matrix, proof metrics, and `aw demo`.

## [Unreleased]

### Added

- Add automation helpers for context enrichment, affected verification, contract diff logging, PR draft filling, and watch-based index refresh.

- Add Context Intelligence workflow with `aw context`, task-level Context Plans, code-reading budgets, CodeGraph fallback guidance, affected analysis, and task-start context gates.

- Add automatic Harness gates, frontend/backend contract workflow, GitHub PR lifecycle checks, multi-agent task locks, delivery scorecards, and recovery playbooks.

- Add multi-agent collaboration protocol with role assignment, handoff, and review records.

- Add delivery metrics, SLO, incident, runbook, and feature flag lifecycle checks to Engineering Harness workflows.

- Add security scan adapters, service catalog discovery, and release gate checks for Engineering Harness workflows.

- Add development-time plan change and task split commands with automatic audit records and policy diff gate.

- Add Engineering Harness control-plane tasks and aw audit, policy, security, service-catalog, and release commands with templates and checks.

- agent-workflow v1.0：工具无关 CLI `scripts/aw`（init / install / dsl / plan / confirm / check / req / next）
- 阶段 0：Reference → DSL → Plan → `aw confirm` → `ENGINEERING_INDEX.md`
- Cursor skill：`agent-workflow`（`sync-skill.sh`）
- Git hooks：`.githooks` + `pre-commit-verify.sh`
- CI：`.github/workflows/ci.yml`

### Changed

- Document closed-loop management for completeness, traceability, maintainability, and handoffability across the agent-workflow lifecycle.

- 移除 `examples/`、`EXAMPLES.md` 及示例 REQ/TP（`REQ-002`、`TP-001`）
- 全库通用化；Handoff / `REPOSITORY` 仅保留流程真源
- `aw index` 与 `aw confirm` 分离：仅 confirm 写入任务确认状态；索引快照区分「扫描 / 已确认」
- `aw confirm` 须同时指定 DSL + Plan；统一 DSL 输出名为 `DSL_DRAFT.md`
- 新增 `aw dev`；Cursor hooks 改为可选（`adapters/cursor-hooks/`）；preCompact 占位 REQ 标作废
- `aw approve dsl|plan`：一键改元数据状态；pre-commit 拦截未已审 DSL 时的业务代码路径
- 删除 preCompact 占位 REQ；补 `reference/inputs/prd.md` 占位
- skill 源码仓瘦身：移除 `docs/product/`、重复 stub、`ENGINEERING_INDEX` 与 init 实例文件（见 `.gitignore`）
- Skill 发布就绪：`skill/SKILL.md` 真源、`package/` 捆绑、`aw status`、`install-cursor-skill.sh`、`PUBLISH.md`、`LICENSE`
- `package/templates/` 随 install 拷贝；`e2e-smoke.sh`、`build-skill-archive.sh`、`release.yml`
- 多 IDE 适配：`aw adapters`（Claude/Codex/Copilot/Cursor/Windsurf/Cline/Continue）；`aw install --adapters`
- 研发执行环：`aw task start|done`、`aw paste task`、`aw verify`、`docs/.aw-workflow.json`；`aw next` 带 confirm 闸门
- P1：`aw check plan|config`、`aw paste plan-write`、`aw atomic list|use`、`aw commit`（验证 + 建议提交信息）
- P2：增强 `aw check dsl`（Plan/REQ 回链、manifest）；`aw dsl write`；`aw tp list|show|link`；Verify 支持 `TP:path` 与 `;` 组合
- P3：`aw check tp` 接入 `aw check all`；`aw status` 显示当前 AT-T 与 ATOMIC 文件；新增 `aw dsl apply` / `aw plan apply`；`install-cursor-skill.sh` 支持 URL 参数与 `AW_SKILL_REF`
- P4：REQ/DSL/Plan 关联校验增强；新增 `aw task blocked`；`aw paste task` 自动内嵌关联 TP 摘要
- P4：新增 `aw config init`、`aw dsl list/use`、`aw plan list/use` 与 Windows/WSL/Git Bash 说明
- P5：`aw verify --run-e2e`、可复用 GitHub Action、`skill/VERSION` 同步检查、英文 Invocation 副本
- 产品化收口：新增 `aw doctor`、`aw setup`、`aw upgrade`、`aw remove`，并加强 Skill/package/doc 命令一致性检查
