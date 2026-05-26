---
name: agent-workflow
description: >-
  Tool-agnostic delivery pipeline (Reference → DSL → Plan → confirm → dev phases)
  for Claude Code, Codex, Copilot, Cursor, Windsurf, Cline, Continue, or any chat.
  Uses aw CLI, gates business code until DSL is reviewed, supports config setup,
  task lifecycle, TP/e2e verification, and multi-IDE adapters. Use for
  agent-workflow, aw init, 按 AI 工作流, 生成 DSL/Plan, 任务确认, verify, tp,
  config, Windsurf, Cline, Copilot, or DSL gates.
argument-hint: "setup | doctor | demo | capabilities | dashboard | memory | audit | policy | security | service-catalog | release | report | install | init | adapters | status | dsl | plan | confirm | config | task | verify | tp | commit | upgrade | remove"
---

# agent-workflow（工具无关）

**Version:** [VERSION](VERSION) · [QUICKSTART.md](QUICKSTART.md) · [reference.md](reference.md)

Works with **any** AI coding tool. Cursor Skill is **optional**; other tools use repo rules + `scripts/aw`.

## What this prevents

- Coding before requirements are reviewed.
- Invented paths, missing source material, or stale context after a new session.
- Overbuilt plans that do not map to executable tasks.
- Broad unrelated edits and unverifiable completion claims.

## Solution shape

`project content scanned → engineer confirms new/existing stage → engineer chooses sync center now / not needed / later → project kind + build target selected → if split frontend/backend: real repos + sync center ready → new project: Reference → DSL → Plan OR existing project: inventory → baseline → incremental DSL → incremental Plan → if split frontend/backend: shared DSL + collaboration Plan before local Plans → confirm → AT-T task → verify → changelog/git → handoff`

Closed-loop management is mandatory for every large requirement and every AT-T:

| Goal | Required trace |
|------|----------------|
| Completeness | REQ / DSL / Plan / ATOMIC / test plan cover requirement, structure, interactions, events, linkage boundaries, acceptance, and non-goals |
| Traceability | Every code diff maps back to REQ / DSL / Plan / AT-T; bugs map to `AI_BUG_LOG`; version-visible changes map to `CHANGELOG [Unreleased]` and optional Git commit |
| Maintainability | `docs/ENGINEERING_RULES.md`, mature-solution choice, focused code comments, tests, and `docs/FILE_INDEX.md` stay current with the implementation |
| Handoffability | `docs/handoff/PROJECT_HANDOFF.md`, `docs/memory/` when reusable, verification evidence, open risks, next steps, and commit/changelog status are current before context switch |
| Harness control | `aw gate`, `aw contract`, `aw github-pr`, `aw agents claim`, `aw score`, and `aw recover` make hooks, API contracts, PRs, agent locks, delivery scoring, and recovery checkable |
| Context control | `aw context` creates task-level Context Plans, enforces code-reading budgets, integrates optional CodeGraph, and prevents wasteful full-repo scans |

Do not mark work done until these four properties have evidence or an explicit documented exception.

Use `aw setup` for first-time project setup and `aw demo` when you need to prove the full install-to-verify path in a temporary repo.

When the user says “执行研发任务”, “开始开发”, “做下一个任务”, or equivalent, do **not** start coding immediately. First run or present `aw next` and `aw task brief <id>`, ask requirement questions, wait for the engineer's explicit confirmation, then record it with `aw task confirm <id> "已确认：..."`. Only after `aw context plan`, `aw context gate`, and `aw task start` may you request or use `aw paste task`.

Context continuity has two lanes:

| Lane | Use for | Do not use for |
|------|---------|----------------|
| Handoff (`docs/handoff/PROJECT_HANDOFF.md`) | Current goal, progress, blockers, next 1-3 steps | Long-term reusable facts |
| Memory (`docs/memory/`) | Stable decisions, preferences, reusable procedures, recurring risks, summarized chat episodes | Raw chat logs or transient task status |

Promote handoff conclusions into memory only when they are likely to be reused across future tasks. Do not store secrets.
When the user asks to remember a conversation, use `aw memory chat` to store a concise episode summary with decisions, follow-ups, open questions, and related REQ/DSL/Plan/AT-T paths; formal requirements still go through `aw req new|change`.

New session resume flow:

```bash
./scripts/aw handoff --check
./scripts/aw memory inject
./scripts/aw status
./scripts/aw next
```

Read `agent-workflow/INVOCATION.md`, `docs/handoff/PROJECT_HANDOFF.md`, `docs/requirements/INDEX.md`, and relevant `docs/memory/` entries. Do not read `ENGINEERING_INDEX.md` into AI context.

## Core coding principles

| Principle | What it prevents |
|-----------|------------------|
| Think before coding | Hidden assumptions, unclear authority, guessing business rules |
| Simplicity first | Over-engineering, premature abstractions, bloated patches |
| Mature solutions first | Fragile hand-rolled code where proven libraries, SDKs, or framework features exist |
| Surgical changes | Unrelated edits, accidental refactors, noisy diffs |
| Goal-driven execution | Vague success criteria, unverified “it works” claims |

Detailed workflow: `agent-workflow/AICODING_WORKFLOW.md` phases A-E.

## Supported tools (pick what you use)

| Tool | Setup |
|------|--------|
| Claude Code | `aw adapters --claude` → `CLAUDE.md` |
| OpenAI Codex | `aw adapters --codex` → `AGENTS.md` |
| GitHub Copilot / VS Code | `aw adapters --copilot` |
| Cursor | `aw adapters --cursor` + optional `sync-skill` |
| Windsurf | `aw adapters --windsurf` → `.windsurfrules` |
| Cline | `aw adapters --cline` → `.clinerules` |
| Continue | `aw adapters --continue` |
| Any chat | `aw paste session` |

**All tools:** `./scripts/aw adapters --all` after `aw install`.
Diagnostics and lifecycle: `aw doctor`, `aw demo`, `aw capabilities`, `aw capabilities --json`, `aw dashboard`, `aw memory`, `aw setup`, `aw upgrade`, `aw remove`.

## First time in a project

```bash
# From skill bundle OR source repo:
/path/to/scripts/aw install . --adapters   # copies agent-workflow/ + IDE stubs

chmod +x scripts/aw scripts/*.sh
./scripts/aw init
./scripts/aw status
./scripts/aw dashboard
./scripts/aw memory inject
./scripts/aw status --json
./scripts/aw capabilities --json
```

Proof path:

```bash
./scripts/aw demo
```

## Workflow (gates)

| Step | Command |
|------|---------|
| Project scan | At startup and before build planning, run `aw project scan`; review `docs/PROJECT_SCAN.md` with the engineer. Do not ask new/existing from a blank slate; scan first, then ask for confirmation |
| Project stage | After scan, ask the engineer to confirm `1 = new project` (`aw config init --project-stage 1`) or `2 = existing/brownfield project` (`aw config init --project-stage 2`). Do not generate DSL/Plan or code before this is confirmed |
| Sync center decision | Immediately after project stage confirmation, ask whether to establish a sync center: `1=use/create sync center` (`aw config init --sync-center 1 --sync-center-path <path>`), `2=not needed` (`aw config init --sync-center 2`), or `3=decide later` (`aw config init --sync-center 3`, Plan remains blocked) |
| Reference | edit `reference/manifest.yaml` + `inputs/` |
| DSL | `aw dsl` → `aw dsl write` or `aw dsl apply` → `aw check dsl` → `aw dsl review` → `aw approve dsl --plan` |
| DSL suite | `aw dsl suite <slug> "title"` → fill requirements/pages/interactions/events/boundaries/acceptance → `aw dsl review docs/dsl/DSL_<SLUG>/INDEX.md --write` → `aw approve dsl docs/dsl/DSL_<SLUG>/INDEX.md --plan` |
| Project kind | Before task planning, ask the engineer to choose the repository provider: `1=GitHub`, `2=local Git`, `3=GitLab`, `4=Bitbucket`, `5=Gitee`, `6=GitCode`, `7=Gitea`, `8=Forgejo`, `9=GitLab CE`, `10=Gerrit`, `11=Alibaba Cloud Codeup`; remote providers use `aw config init --project-kind <n> --repo-url <url>`, local Git skips remote URL |
| Build target | After DSL review and before Plan, ask the engineer to choose: `1 = frontend`, `2 = backend`, `3 = fullstack`, then run `aw config init --build-target 1|2|3` |
| Split frontend/backend repos | Before Plan, ask whether frontend/backend are in one repo or two; if two, ask same computer vs different computers, real frontend repo path/repository URL, real backend repo path/repository URL, and `project-harness` path/repository URL. `aw project gate` blocks Plan generation until repos and sync center are ready |
| Sync center before local Plans | For split repos, put shared DSL in `project-harness/global/dsl/`, collaboration Plan in `project-harness/global/plans/`, then derive frontend/backend local Plans in each real code repo |
| Plan | `aw plan <dsl>` → `aw paste plan-write` or `aw plan apply` → `aw approve plan` → `aw check plan` |
| Plan change | During development, use `aw plan change --summary "..."` for scope notes, `aw plan task-add --title "..."` for same-scope new AT-T, and `aw task split <id> --into "A; B"` when a task is too large |
| Engineering rules | `aw rules init` → `aw rules discover --write` to map key files → keep team defaults from frontend/backend/unified AI manuals, fill project-specific differences and comment principles → `aw rules review` → `aw check rules` |
| Confirm | `aw confirm <dsl> <plan>` → `ENGINEERING_INDEX.md` (humans only) |
| Dev | `aw status` → `aw next` → `aw task brief <id>` → discuss requirements → `aw task confirm <id> "已确认：..."` → `aw context plan --task <id>` → review allowed files → `aw context gate --task <id>` → `aw task start <id>` → `aw paste task` → `aw task complete <id>` |
| Test plans | `aw tp new` → `aw tp link <id> <TP>` → `aw check tp` |
| Bug ledger | `aw bug add "summary" --source chat|review|runtime|prod --scope <id-or-module>`; every bug/suspected bug must be logged |
| Requirements | `aw req new <slug> "title" --type 口述新增` and `aw req change <id> "summary"` both write `docs/requirements/INDEX.md`; use 需求类型 to distinguish spoken new requirements vs development changes |
| File index | Update `docs/FILE_INDEX.md` when adding/deleting/renaming business files so human engineers can find files to review or hand-edit |
| Commit checkpoint | After every large requirement / AT-T completes, ask the engineer whether to commit the current branch for rollback; `aw commit --task <id> --changelog "..."` records `[Unreleased]` and suggests, `--execute` only after confirmation |
| Handoff | run `aw handoff "focus"` for a draft, `aw handoff "focus" --write` after review to backup + overwrite `docs/handoff/PROJECT_HANDOFF.md`, and `aw handoff --check` before new sessions |
| Memory | `aw memory add <slug> "title" --body "..."`; for conversation continuity use `aw memory chat <slug> "title" --summary "..."`; then `aw memory inject` |
| Closed-loop check | Before moving to the next large requirement / AT-T, run `aw trace check` where useful and confirm completeness, traceability, maintainability, and handoffability evidence; document any exception in Bug / REQ / handoff |
| Audit | `aw audit add --task <id> --action "..." --result "..."` records key AI actions, decisions, commands, verification results, and human confirmations |
| Policy | `aw policy check`, `aw policy diff`, and `aw policy gate --strict`; high-risk changes, new dependencies, production/deploy/database/security actions require a policy decision or explicit confirmation |
| Security | `aw security finding ...` and `aw security dependency ...` record vulnerabilities, suspected security issues, and new dependency reviews; `aw security scan` detects/suggests installed scanners and `--run` executes them |
| Service catalog | `aw service-catalog add ...` maintains `docs/SERVICE_CATALOG.md`; `aw service-catalog discover` prints candidate services/modules, entry/API/data/dependency/run/observability hints, and `--write` appends candidates |
| Release | `aw release record ...` and `aw release flag ...` maintain environment, rollout, rollback, CHANGELOG/tag, verification, and feature flag records; `aw release gate` runs pre-release checks plus ops/agents/metrics/report gates |
| Reports | `aw report handoff|release` prints engineer-readable Harness summaries; add `--write` to save under `docs/reports/`; use `aw report check --strict` before handoff/release gates |
| Metrics | `aw metrics record ...` tracks DORA/flow signals; use `aw metrics summary` before release or handoff to summarize delivery health |
| Ops | `aw ops slo|incident|incident-close|runbook ...` maintains SLO, incident, recovery, and runbook records; use `aw ops gate` before release/handoff |
| Hook / Gate automation | `aw hooks install` enables Git hooks; `aw gate pre-commit|task|pr|release` runs lifecycle gates for DSL, REQ, TP, Contract, Agent locks, Trace, Score, and Release |
| Code context | `aw context init|status|plan|query|impact|affected|gate` manages CodeGraph/file-index-backed task context, allowed-read files, symbol/impact lookup, and affected-test notes |
| Automation helpers | `aw context enrich`, `aw verify --affected`, `aw contract diff --write`, `aw github-pr fill`, and `aw watch index` automate context enrichment, affected validation, contract diffs, PR drafts, and index refresh |
| API contracts | `aw contract init|change|test|diff|gate` maintains OpenAPI, API changelog, mock-server notes, schema diff, and contract-test evidence for frontend/backend alignment |
| GitHub PR loop | `aw github-pr branch|draft|review|gate` records branch policy, PR checklist, review outcomes, Contract/Score/Release readiness, and rollback notes |
| Agents | `aw agents assign|claim|heartbeat|release|handoff|review ...` records roles, task locks, heartbeats, ownership, handoffs, and review outcomes; use `aw agents gate --strict` to block path conflicts or expired/missing locks |
| Cross-project sync | For split frontend/backend repos, configure a shared harness with `aw sync init <dir> --project <name> --agent <name>`; run `aw sync pull` before starting dependent work and `aw sync push --task <id>` after updating contracts, handoff, bugs, requirements, or verification |
| Traceability | `aw trace check` checks REQ → DSL/Plan, Plan → ATOMIC, AT-T → Verify/TP, Bug ledger, Changelog, and Harness records |
| Delivery score | `aw score record --scope <REQ|AT-T|pr|release>` writes a 0-100 score across requirements, DSL/Plan, task confirmation, verification, Bug, file index, contract, Git/release, and handoff |
| Recovery | `aw recover context|plan|sync|failed-task|conflict|rollback` gives deterministic recovery paths for context loss, stale plans, frontend/backend drift, failed tasks, conflicts, and rollback |

`aw index` = scan only, **not** confirm. REQ / Bug / TP / DSL / Plan write commands auto-refresh `ENGINEERING_INDEX.md` in scan mode after successful writes.

## Agent rules

1. DSL not **已审** → no business code under `src/`, `frontend/`, etc.
2. Never `@` `ENGINEERING_INDEX.md`.
3. Do not invent `reference/` or `docs/dsl/` paths.
4. Truth: `agent-workflow/INVOCATION.md` after install.
5. Before generating DSL/Plan or AT-T task split, run `aw project scan`, summarize `docs/PROJECT_SCAN.md`, and let the engineer confirm whether the project is new or existing. Immediately ask whether to establish a sync center and record the answer with `aw config init --sync-center 1|2|3`; `3=pending` blocks Plan. Then guide the engineer to choose code hosting provider and build target in `docs/PROJECT_CONFIG.md`: `1=GitHub`, `2=local Git`, `3=GitLab`, `4=Bitbucket`, `5=Gitee`, `6=GitCode`, `7=Gitea`, `8=Forgejo`, `9=GitLab CE`, `10=Gerrit`, `11=Codeup`; build target `1=frontend`, `2=backend`, `3=fullstack`. For every non-local provider, record `--repo-url <url>`.
5a. If build target is `fullstack` and frontend/backend are split repos or dual projects, build the sync center first with `aw sync init <project-harness> --project ... --agent ... --role ...`. `aw plan`, `aw approve dsl --plan`, and `aw plan apply` are blocked until `aw project gate` passes. Shared DSL and collaboration Plan live in the sync center before local frontend/backend Plans are derived.
6. Before every AT-T starts, clarify requirements with the engineer, ask until scope/acceptance/non-goals are explicit, and wait for confirmation. Do not guess.
7. Record spoken new requirements and development changes in `docs/requirements/INDEX.md` with a 需求类型. If requirements change during development, stop coding and run `aw req change`; update DSL/Plan/ATOMIC before continuing.
7a. Development-time plan changes: small same-goal changes update the active Plan/ATOMIC with `aw plan change` or `aw plan task-add`; oversized tasks use `aw task split`; major scope/architecture/delivery-batch changes generate a new Plan/ATOMIC and require approval/confirm again.
8. When adding, deleting, or renaming business files, update `docs/FILE_INDEX.md` with a one-line responsibility and recent related task/REQ/Bug.
9. Prefer mature solutions over hand-written code when project tools, official SDKs, stable open-source libraries, framework features, or industry-standard implementations fit. Ask before adding dependencies; check license, security, maintenance, and project fit.
10. Comment AI-written code for human handoff: explain non-obvious business rules, boundaries, tradeoffs, side effects, and temporary decisions; avoid comments that merely restate obvious code.
11. After every large requirement or AT-T completes and verifies, ask the engineer whether to commit the current branch. Before commit, add a traceable `[Unreleased]` entry with `aw changelog add` or `aw commit --changelog "..."`. Do not commit automatically; if they decline, record the reason and rollback risk in handoff.
12. Maintain the four-property delivery loop: completeness, traceability, maintainability, and handoffability. If any property is missing, either fix the missing artifact before continuing or record an explicit exception, owner, and follow-up in the appropriate ledger.
13. For Engineering Harness control, use `aw audit`, `aw policy`, `aw security`, `aw service-catalog`, `aw release`, `aw trace`, `aw metrics`, `aw ops`, `aw agents`, and `aw sync` when a task touches high-risk code, dependencies, service boundaries, deployment, feature flags, reliability, incidents, multi-agent handoff, split frontend/backend repositories, or production behavior.
14. In split frontend/backend repositories, `aw sync pull` is a read-only inbox import and must happen before dependent work; `aw sync push` publishes this project's workflow snapshot after contract, REQ, Bug, Handoff, Agent, or verification changes. Never treat pulled inbox files as local truth without engineer confirmation.
15. Frontend/backend API changes must go through `aw contract change` and `aw contract test`; breaking changes stay blocked until both sides confirm and the contract gate passes.
16. Multi-agent implementation requires `aw agents claim` before coding and `aw agents heartbeat` during long work; missing, expired, or conflicting locks block strict gates.
17. Before PR/release handoff, run `aw gate pr`, `aw github-pr gate`, `aw contract gate`, and `aw score record`; recover with `aw recover ...` instead of guessing when a gate fails.
18. No aimless full-repo scans. Before business-code edits, create/read `docs/context/tasks/CTX-<AT-T>.md`; only read files listed there, and expand context only after recording the reason and engineer confirmation.
19. Default context budget per AT-T is 8 business files, 20 symbols, and 5 precise searches. Do not read dependency/build/cache/generated/log directories such as `.git`, `node_modules`, `dist`, `build`, `coverage`, `.next`, `.nuxt`, `target`, `vendor`, `tmp`, or `logs`.
20. Prefer CodeGraph / `aw context` symbol, caller/callee, impact, and affected-test queries over bulk file reads. If CodeGraph is unavailable, use `CODE_CONTEXT_INDEX`, `FILE_INDEX`, and precise `rg` as fallback.

## Cursor-only (optional)

```bash
./scripts/sync-skill.sh   # ~/.cursor/skills/agent-workflow/
```

Other IDEs do **not** need this step.
