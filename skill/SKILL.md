---
name: agent-workflow
description: >-
  Lean, tool-agnostic delivery pipeline (Reference → DSL → Plan → confirm → dev)
  for Claude Code, Codex, Copilot, Cursor, Windsurf, Cline, Continue, or any chat.
  Uses aw CLI, gates business code until DSL/Plan/task/context are confirmed,
  and keeps token usage low through staged context reading. Use for agent-workflow,
  启动 aw, @aw, aw start, aw init, 按 AI 工作流, 生成 DSL/Plan, 任务确认,
  省 token, verify, tp, config, Windsurf, Cline, Copilot, or DSL gates.
argument-hint: "start | setup | doctor | demo | capabilities | dashboard | memory | audit | policy | security | service-catalog | release | report | install | init | adapters | status | dsl | plan | confirm | config | context | task | verify | tp | commit | upgrade | remove"
---

# agent-workflow（运行时精简版）

**Truth:** [package/INVOCATION.md](package/INVOCATION.md) after install.
**Reference:** [reference.md](reference.md).
**Manual:** [package/AGENTWORKFLOW_MANUAL.html](package/AGENTWORKFLOW_MANUAL.html) for humans; do not load it into model context unless the user asks.

## Runtime Rule

This skill is a **workflow gate**, not a documentation bundle. Keep context small:

- Read only this `SKILL.md` at skill activation.
- Read `package/INVOCATION.md` only when a step is ambiguous or a command is needed.
- Read `reference.md` only for command lookup.
- Never read the HTML manual as AI context by default.
- Prefer CLI summaries (`aw status`, `aw next`, `aw task brief`, `aw context plan`, `aw sync inbox`) over opening full ledgers.

## Startup

When the user says `启动 aw`, `@aw`, `aw start`, or equivalent:

1. Declare AgentWorkflow active.
2. Ask the role before any scan or coding:
   - `1=产品`
   - `2=前端`
   - `3=后端`
   - `4=全栈`
3. After role confirmation, run/present `aw project scan`, summarize `docs/PROJECT_SCAN.md`, and ask the engineer to confirm `new` vs `existing`.
4. Ask sync-center decision and record it with `aw config init --sync-center 1|2|3`.
5. Ask code hosting provider and build target.

`全栈` means frontend/backend code is in one repository by default, build target `3=fullstack`; sync center is optional unless the engineer confirms split repos, different computers, or PM-managed collaboration.

## Token Budget

Default budgets per AT-T:

| Context | Budget |
|---------|--------|
| Business files | 6 files |
| Symbols | 12 symbols |
| Precise searches | 3 searches |
| Handoff read | latest summary only, not whole history |
| Sync inbox read | relevant peer/event only, not all snapshots |
| Reference docs | manifest + explicitly cited files only |

Do not exceed a budget without saying why and asking the engineer to confirm the expansion. Never do an aimless full-repo scan. Avoid generated/cache/dependency/build/log directories: `.git`, `node_modules`, `dist`, `build`, `coverage`, `.next`, `.nuxt`, `target`, `vendor`, `tmp`, `logs`.

Use this lean order:

```bash
./scripts/aw status --json
./scripts/aw next
./scripts/aw task brief <AT-T>
./scripts/aw context plan --task <AT-T>
./scripts/aw context gate --task <AT-T>
```

Read only files listed in `docs/context/tasks/CTX-<AT-T>.md`. Prefer CodeGraph / `aw code-map` / `aw context` symbol, caller/callee, impact, and affected-test queries. If CodeGraph is unavailable, use `CODE_MAP`, `CODE_CONTEXT_INDEX`, `FILE_INDEX`, and precise `rg`.

Code map is automatic by default. `aw context plan`, `aw task start`, `aw task complete`, `aw watch index`, and `aw gate pre-commit` refresh/check `docs/context/CODE_MAP.md` unless `AW_CODE_MAP_AUTO=0` is set for an explicit exception. Before coding in existing or large projects, query the map instead of scanning the repo:

```bash
./scripts/aw code-map build
./scripts/aw code-map query "<feature|symbol|route>"
./scripts/aw code-map impact "<symbol|route>"
```

`CODE_MAP.md` is a locator index, not permission to read full files. Convert findings into the task Context Plan and wait for confirmation before opening file contents.

## Required Gates

| Stage | Hard rule |
|-------|-----------|
| DSL | DSL status not `已审` → no business code |
| Plan | Plan status not `可执行` → no business code |
| Confirm | Run `aw confirm <dsl> <plan>` before AT-T execution |
| Task start | `aw next` → `aw task brief <id>` → ask scope / acceptance / non-goals → `aw task confirm <id> "已确认：范围=...；验收=...；非目标=..."` |
| Context | `aw context plan --task <id>` → engineer reviews allowed files → `aw context gate --task <id>` |
| Coding | Only after `aw task start <id>` may you request/use `aw paste task` or edit business code |
| Completion | `aw task complete <id>` verifies; failed verification logs Bug and keeps task open |
| Checkpoint | Completed AT-T needs Git decision, compact/handoff evidence, and `docs/FILE_INDEX.md` refresh when business files changed |

When the user says “执行研发任务”, “开始开发”, “做下一个任务”, or equivalent, do **not** start coding. Start with `aw next` and `aw task brief`.

## Context Continuity

| Lane | Use for | Do not use for |
|------|---------|----------------|
| Handoff (`docs/handoff/PROJECT_HANDOFF.md`) | Current goal, progress, blockers, next 1-3 steps | Long-term reusable facts |
| Memory (`docs/memory/`) | Stable decisions, preferences, reusable procedures, recurring risks, summarized chat episodes | Raw chat logs or transient task status |

Use `aw compact "focus" --write --snapshot` before Codex context compaction, new chats, model switches, long pauses, or after a large requirement/AT-T batch. Add `--memory-summary` only for reusable decisions or follow-ups. Do not store secrets.

New session lean resume:

```bash
./scripts/aw handoff --check
./scripts/aw memory inject
./scripts/aw status --json
./scripts/aw next
```

Read handoff/memory selectively. Do not read `ENGINEERING_INDEX.md` into AI context; it is for human engineers.

## DSL / Plan / PM

- DSL suite: `aw dsl suite <slug> "title"` creates multi-file DSL coverage for requirements, pages, interactions, events, boundaries, and acceptance.
- `aw dsl review <dsl> --write` creates the engineer review package before `aw approve dsl`.
- `aw approve dsl <dsl> --plan` may guide Plan generation; PM/three-side projects should use `aw pm plan --write` before dispatch.
- `aw plan change`, `aw plan task-add`, and `aw task split` handle development-time changes without bloating the active task.
- Product-led work uses `aw pm start` and `aw pm init <project-harness>`; PM owns shared references, Pencil intake, shared DSL/Plan, dispatch, dashboard, and lifecycle gates.

## Cross-Project Sync

For split frontend/backend repositories:

- Configure sync center with `aw sync init <project-harness> --project ... --agent ... --role ...`.
- Start dependent work with `aw sync pull` + `aw sync gate --task <id>`.
- Read only `aw sync inbox --from <peer>` summaries and relevant event/contract files.
- `aw sync pull` imports read-only inbox files; never treat inbox as local truth until adopted through REQ / Bug / Plan / Handoff.
- API changes use `aw contract change`, `aw contract test`, and `aw contract gate`.
- Multi-agent implementation uses `aw agents claim`, `aw agents heartbeat`, and `aw agents gate --strict`.

## Engineering Principles

| Principle | Meaning |
|-----------|---------|
| Think before coding | Clarify authority, scope, acceptance, and non-goals |
| Simplicity first | Keep changes small and directly tied to the AT-T |
| Mature solutions first | Prefer proven libraries, SDKs, framework features, and official patterns |
| Surgical changes | Avoid unrelated refactors and noisy diffs |
| Goal-driven execution | Verify against real project commands and recorded acceptance |

Also maintain completeness, traceability, maintainability, and handoffability. Use `aw audit`, `aw policy`, `aw security`, `aw service-catalog`, `aw release`, `aw trace check`, `aw metrics summary`, `aw ops gate`, `aw report handoff`, `aw report release`, `aw score record`, and `aw recover ...` when the task touches risk, production, dependencies, services, release, multi-agent work, or handoff.

## File / Bug / Git Rules

- Record spoken new requirements with `aw req new`; record development-time changes with `aw req change`, then update DSL/Plan/ATOMIC before continuing.
- Every bug or suspected bug goes to `aw bug add`.
- Update `docs/FILE_INDEX.md` when adding/deleting/renaming business files.
- Ask before Git commit/push. Use `aw commit --task <id> --changelog "..."`; do not commit automatically.
- Comment AI-written code for non-obvious business rules, boundaries, tradeoffs, side effects, and temporary decisions; avoid obvious comments.

## Pencil

Pencil design files are formal inputs. Store `.pen` sources under `global/references/design/pencil/source/`, exports under `exports/`, screenshots under `screenshots/`, and changes in `DESIGN_CHANGELOG.md`. Do not parse encrypted `.pen` files as plain text; use Pencil tooling or exported artifacts.
