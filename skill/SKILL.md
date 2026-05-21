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

`Reference → DSL 已审 → project kind + build target selected → Plan 可执行 → confirm → AT-T task → verify → changelog/git → handoff`

Closed-loop management is mandatory for every large requirement and every AT-T:

| Goal | Required trace |
|------|----------------|
| Completeness | REQ / DSL / Plan / ATOMIC / test plan cover requirement, structure, interactions, events, linkage boundaries, acceptance, and non-goals |
| Traceability | Every code diff maps back to REQ / DSL / Plan / AT-T; bugs map to `AI_BUG_LOG`; version-visible changes map to `CHANGELOG [Unreleased]` and optional Git commit |
| Maintainability | `docs/ENGINEERING_RULES.md`, mature-solution choice, focused code comments, tests, and `docs/FILE_INDEX.md` stay current with the implementation |
| Handoffability | `docs/handoff/PROJECT_HANDOFF.md`, `docs/memory/` when reusable, verification evidence, open risks, next steps, and commit/changelog status are current before context switch |

Do not mark work done until these four properties have evidence or an explicit documented exception.

Use `aw setup` for first-time project setup and `aw demo` when you need to prove the full install-to-verify path in a temporary repo.

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
| Reference | edit `reference/manifest.yaml` + `inputs/` |
| DSL | `aw dsl` → `aw dsl write` or `aw dsl apply` → `aw check dsl` → `aw dsl review` → `aw approve dsl --plan` |
| DSL suite | `aw dsl suite <slug> "title"` → fill requirements/pages/interactions/events/boundaries/acceptance → `aw dsl review docs/dsl/DSL_<SLUG>/INDEX.md --write` → `aw approve dsl docs/dsl/DSL_<SLUG>/INDEX.md --plan` |
| Project kind | Before task planning, ask the engineer to choose: `1 = GitHub repository` (`aw config init --project-kind 1 --github-url ...`) or `2 = local Git repository` (`aw config init --project-kind 2`); local Git repositories skip GitHub URL |
| Build target | After DSL review and before Plan, ask the engineer to choose: `1 = frontend`, `2 = backend`, `3 = fullstack`, then run `aw config init --build-target 1|2|3` |
| Plan | `aw plan <dsl>` → `aw paste plan-write` or `aw plan apply` → `aw approve plan` → `aw check plan` |
| Plan change | During development, use `aw plan change --summary "..."` for scope notes, `aw plan task-add --title "..."` for same-scope new AT-T, and `aw task split <id> --into "A; B"` when a task is too large |
| Engineering rules | `aw rules init` → `aw rules discover --write` to map key files → keep team defaults from frontend/backend/unified AI manuals, fill project-specific differences and comment principles → `aw rules review` → `aw check rules` |
| Confirm | `aw confirm <dsl> <plan>` → `ENGINEERING_INDEX.md` (humans only) |
| Dev | `aw status` → `aw next` → `aw task brief <id>` → discuss requirements → `aw task confirm <id> "已确认：..."` → `aw task start <id>` → `aw paste task` → `aw task complete <id>` |
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
| Agents | `aw agents assign|handoff|review ...` records multi-agent roles, ownership, handoffs, and review outcomes; use `aw agents gate` to detect blocking reviews and overlapping allowed paths, or `aw agents gate --strict` to block path conflicts |
| Cross-project sync | For split frontend/backend repos, configure a shared harness with `aw sync init <dir> --project <name> --agent <name>`; run `aw sync pull` before starting dependent work and `aw sync push --task <id>` after updating contracts, handoff, bugs, requirements, or verification |
| Traceability | `aw trace check` checks REQ → DSL/Plan, Plan → ATOMIC, AT-T → Verify/TP, Bug ledger, Changelog, and Harness records |

`aw index` = scan only, **not** confirm. REQ / Bug / TP / DSL / Plan write commands auto-refresh `ENGINEERING_INDEX.md` in scan mode after successful writes.

## Agent rules

1. DSL not **已审** → no business code under `src/`, `frontend/`, etc.
2. Never `@` `ENGINEERING_INDEX.md`.
3. Do not invent `reference/` or `docs/dsl/` paths.
4. Truth: `agent-workflow/INVOCATION.md` after install.
5. Before generating the development plan or AT-T task split, guide the engineer to choose project type and build target in `docs/PROJECT_CONFIG.md`: project type `1=GitHub repository` or `2=local Git repository`; build target `1=frontend`, `2=backend`, `3=fullstack`.
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

## Cursor-only (optional)

```bash
./scripts/sync-skill.sh   # ~/.cursor/skills/agent-workflow/
```

Other IDEs do **not** need this step.
