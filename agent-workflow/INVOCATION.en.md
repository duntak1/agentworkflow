# Invocation Guide (Tool-Agnostic)

This repository uses `agent-workflow` as the source of truth for Claude Code, OpenAI Codex, GitHub Copilot, Cursor, Windsurf, Cline, Continue, or any chat tool.

## Flow

```text
install/init -> reference/ -> DSL reviewed -> choose project kind + build target -> Plan executable -> aw confirm -> ENGINEERING_INDEX.md -> aw next -> code one AT-T -> verify -> changelog/git -> compact / handoff
```

Project kind:

- Choose repository provider before planning: `1=GitHub`, `2=local Git`, `3=GitLab`, `4=Bitbucket`, `5=Gitee`, `6=GitCode`, `7=Gitea`, `8=Forgejo`, `9=GitLab CE`, `10=Gerrit`, `11=Alibaba Cloud Codeup`.
- For remote providers, run `aw config init --project-kind <n> --repo-url <repository-url>`; local Git uses `aw config init --project-kind 2`.

Build target:

- `1 = frontend`
- `2 = backend`
- `3 = fullstack`

## Closed-Loop Management

Before marking a large requirement or AT-T complete, evidence must exist for:

| Goal | Evidence |
|------|----------|
| Completeness | REQ / DSL / Plan / ATOMIC / test plan cover requirements, page structure, interactions, events, linkage boundaries, acceptance, and non-goals |
| Traceability | Code diff, bugs, tests, CHANGELOG, and Git commits can trace back to REQ / DSL / Plan / AT-T |
| Maintainability | Engineering rules, mature-solution choice, necessary comments, tests, and `docs/FILE_INDEX.md` are current |
| Handoffability | Handoff / reusable memory / verification evidence / risks / next steps / commit and changelog status are current |

If any item is missing, fix it before continuing or document the exception, owner, risk, and follow-up in REQ / Bug / Handoff.

## CLI

```bash
./scripts/aw install . --adapters
./scripts/aw init
./scripts/aw memory inject
./scripts/aw config init --project-kind 1 --repo-url https://github.com/<owner>/<repo>
# or: ./scripts/aw config init --project-kind 2
./scripts/aw config init --build-target 1
./scripts/aw rules init && ./scripts/aw rules discover --write && ./scripts/aw rules review # Keep team defaults; fill project differences.
./scripts/aw dsl
./scripts/aw dsl apply --file /tmp/DSL.md
./scripts/aw dsl review docs/dsl/DSL_DRAFT.md --write
./scripts/aw approve dsl docs/dsl/DSL_DRAFT.md --plan
./scripts/aw plan docs/dsl/DSL_DRAFT.md
./scripts/aw plan apply --plan-file /tmp/PLAN.md --atomic-file /tmp/ATOMIC_TASKS.md --slug feature
./scripts/aw approve plan docs/plans/PLAN_feature.md
./scripts/aw confirm docs/dsl/DSL_DRAFT.md docs/plans/PLAN_feature.md
./scripts/aw next
./scripts/aw task brief AT-T1-001
./scripts/aw task confirm AT-T1-001 "confirmed: scope=...; acceptance=...; non-goals=..."
./scripts/aw context plan --task AT-T1-001
./scripts/aw context gate --task AT-T1-001
./scripts/aw task start AT-T1-001
./scripts/aw paste task
./scripts/aw task complete AT-T1-001
```

## Gates

1. Do not edit business code until DSL metadata status is `已审`.
2. Before Plan generation, choose project kind and build target in `docs/PROJECT_CONFIG.md`.
3. Do not start AT-T implementation until Plan metadata status is `可执行` and `aw confirm <dsl> <plan>` has run.
4. When the engineer says "execute development task", "start development", or "do the next task", do not code immediately. First run `aw next` and `aw task brief <AT-T>`, ask requirement questions, and wait for explicit engineer confirmation.
5. Before every AT-T coding prompt, the hard gate is `aw task confirm` with scope / acceptance / non-goals → `aw code-map query|impact` → `aw context plan` → `aw context gate` → `aw task start` → `aw paste task`. If any step is missing, do not read broadly, generate a coding prompt, or edit business code.
6. Record spoken requirements with `aw req new`; record development-time changes with `aw req change`, then re-run task brief/confirm/context gate.
7. Every bug or suspected bug must be logged with `aw bug add` or by `aw task complete` on failed verification.
8. `ENGINEERING_INDEX.md` is for humans; do not paste it into AI context.
9. Do not move to the next large requirement or AT-T until the closed-loop check is complete.

## New Session Resume

Run:

```bash
./scripts/aw handoff --check
./scripts/aw memory inject
./scripts/aw status
./scripts/aw next
```

Read:

1. `agent-workflow/INVOCATION.md`
2. `docs/handoff/PROJECT_HANDOFF.md`
3. `docs/requirements/INDEX.md`
4. relevant `docs/memory/` entries

Do not read `ENGINEERING_INDEX.md` into AI context.

## Context Continuity

| Layer | Purpose |
|-------|---------|
| Compact | One-shot Codex/new-chat continuity: `aw compact "focus" --write --snapshot` |
| Handoff | Current goal, status, blockers, next steps: `aw handoff "focus" --write` |
| Memory | Stable decisions, preferences, recurring risks: `aw memory add` |
| Chat memory | Summarized conversation continuity: `aw memory chat` |
| Requirements | Formal spoken requirements and changes: `aw req new|change` |

Codex native context compaction cannot be listened to directly by the skill. AgentWorkflow's linkage command is `aw compact`; run it before Codex compaction, tool/model switches, long pauses, new chats, or after a large requirement / AT-T batch:

```bash
./scripts/aw compact "current focus" --write --snapshot
```

It writes/checks `docs/handoff/PROJECT_HANDOFF.md`, writes `docs/handoff/LAST_AUTO_SNAPSHOT.md`, and writes `docs/handoff/PASTE_IN_NEW_CHAT.txt`.

When the user asks to remember the conversation:

```bash
./scripts/aw compact "current focus" --write --snapshot \
  --memory-summary "conversation summary" \
  --memory-decisions "confirmed decisions" \
  --memory-todos "follow-ups" \
  --memory-open "open questions" \
  --memory-related "REQ / DSL / Plan / AT-T / paths"

# or directly:
./scripts/aw memory chat <slug> "title" \
  --summary "conversation summary" \
  --decisions "confirmed decisions" \
  --todos "follow-ups" \
  --open "open questions" \
  --related "REQ / DSL / Plan / AT-T / paths"
```

## Useful Commands

| Command | Purpose |
|---------|---------|
| `aw status` | Show DSL, Plan, confirm state, ATOMIC, current AT-T |
| `aw check all` | Run layout, DSL, Plan, config, rules, REQ, TP, docs, plugin, memory checks |
| `aw config init` | Fill project kind, build target, remote repository URL, stack, and verification commands |
| `aw rules init|discover|review|check` | Generate/discover/review/check engineering rules with team frontend/backend/unified AI defaults plus project-specific differences |
| `aw dsl suite` | Create multi-file DSL for requirements, pages, interactions, events, boundaries, and acceptance |
| `aw dsl review --write` | Generate engineer DSL review package before approval |
| `aw plan list/use` | Select active Plan and matching ATOMIC |
| `aw atomic list/use` | Select active ATOMIC_TASKS file |
| `aw task brief|confirm|start|complete` | Enforce pre-coding requirement discussion and verified completion |
| `aw plan change` | Record development-time plan changes in active Plan / ATOMIC |
| `aw plan task-add` | Append a same-scope AT-T to active ATOMIC |
| `aw task split` | Split an oversized AT-T into follow-up AT-T rows |
| `aw tp new/link/show/list` | Manage test plans |
| `aw verify --task <AT-T> --run-e2e` | Execute configured task/e2e verification |
| `aw compact "focus" --write --snapshot` | One-shot context compaction for Codex/new chat: handoff, snapshot, paste block, optional memory |
| `aw handoff --check` | Validate cross-session handoff snapshot |
| `aw memory chat` | Store summarized chat context |
| `aw code-map build|query|impact|affected|gate` | Build/query `docs/context/CODE_MAP.md` before reading code; locate modules, symbols, routes, imports, and tests without full-repo scans |
| `aw audit init|add|check` | Record AI actions, decisions, commands, results, evidence, and confirmations |
| `aw policy init|decision|check|diff|gate` | Initialize/check policy-as-code, inspect risky diffs, and record high-risk exceptions; `gate --strict` blocks risky diffs |
| `aw security init|finding|dependency|check` | Record security findings and dependency reviews |
| `aw security scan [--run]` | Detect/suggest installed secret/SCA/SAST scanners; run them with `--run` |
| `aw service-catalog init|add|check` | Maintain service/module catalog for handoff |
| `aw service-catalog discover [--write]` | Discover service/module candidates plus entry, API, data, dependencies, run, and observability hints |
| `aw release init|record|flag|check` | Track environments, releases, rollback, verification, and feature flags |
| `aw release gate [--run-verify] [--run-security] [--strict-policy] [--strict-report]` | Run pre-release checks across changelog, policy, security, catalog, environments, ops, agents, metrics, report gate, and optional verify/security scans |
| `aw release gate --strict-report` | Require the latest release report to exist and contain required snapshots |
| `aw release flag-check` | Check feature flags for cleanup plans |
| `aw report handoff|release [--write]` | Generate engineer-readable handoff/release reports under `docs/reports/` |
| `aw report check [--strict]` | Check latest handoff/release reports for required sections; strict mode can block handoff/release gates |
| `aw metrics init|record|summary|check` | Track DORA/flow delivery metrics and summarize delivery health |
| `aw ops init|slo|incident|incident-close|runbook|gate|check` | Track SLO, incidents, recovery closure, runbooks, and ops gate |
| `aw agents init|assign|handoff|review|gate|check` | Track multi-agent roles, ownership, handoffs, reviews, blocking review gate, and overlapping allowed paths |
| `aw trace check` | Check traceability across REQ, DSL, Plan, AT-T, TP, Bug, Changelog, and Harness records |

Windows notes: see `agent-workflow/WINDOWS.md`.
