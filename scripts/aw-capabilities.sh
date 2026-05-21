#!/usr/bin/env bash
# Print installed agent-workflow capabilities.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON=false
case "${1:-}" in
  --json) JSON=true; shift ;;
  -h|--help)
    cat <<'EOF'
Usage: aw capabilities [--json]

Print supported tools, commands, and proof paths.
EOF
    exit 0
    ;;
esac

VERSION="unknown"
if [[ -f "${SCRIPT_DIR}/../agent-workflow/VERSION" ]]; then
  VERSION="$(tr -d '[:space:]' < "${SCRIPT_DIR}/../agent-workflow/VERSION")"
elif [[ -f "${SCRIPT_DIR}/../package/VERSION" ]]; then
  VERSION="$(tr -d '[:space:]' < "${SCRIPT_DIR}/../package/VERSION")"
elif [[ -f "${SCRIPT_DIR}/../VERSION" ]]; then
  VERSION="$(tr -d '[:space:]' < "${SCRIPT_DIR}/../VERSION")"
fi

if $JSON; then
  cat <<EOF
{
  "version": "${VERSION}",
  "pipeline": [
    "Reference",
    "DSL reviewed",
    "Plan executable",
    "confirm",
    "AT-T task",
    "verify",
    "changelog/git",
    "handoff"
  ],
  "adapters": [
    "Claude Code",
    "Codex",
    "Copilot / VS Code",
    "Cursor",
    "Windsurf",
    "Cline",
    "Continue",
    "Any chat"
  ],
  "commands": [
    "install",
    "setup",
    "doctor",
    "demo",
    "init",
    "status",
    "capabilities",
    "dashboard",
    "dsl",
    "dsl review",
    "plan",
    "plan change",
    "plan task-add",
    "approve",
    "confirm",
    "index",
    "check",
    "config",
    "ci",
    "atomic",
    "req",
    "tp",
    "bug",
    "changelog",
    "memory chat",
    "next",
    "task",
    "task split",
    "paste",
    "verify",
    "commit",
    "audit",
    "policy",
    "policy gate",
    "security",
    "service-catalog",
    "release",
    "report",
    "release gate --strict-report",
    "report handoff",
    "report release",
    "report check",
    "trace",
    "trace check",
    "metrics",
    "metrics summary",
    "ops",
    "ops gate",
    "agents",
    "agents gate",
    "sync",
    "sync init",
    "sync push",
    "sync pull",
    "sync baseline",
    "sync board",
    "sync event",
    "sync change",
    "sync inbox",
    "sync status",
    "sync check",
    "gate",
    "gate pre-commit",
    "gate pr",
    "contract",
    "contract change",
    "contract test",
    "contract gate",
    "github-pr",
    "github-pr branch",
    "github-pr draft",
    "github-pr gate",
    "score",
    "score record",
    "recover",
    "recover context",
    "recover plan",
    "recover sync",
    "handoff --write",
    "handoff --check",
    "hooks",
    "adapters",
    "sync-skill",
    "upgrade",
    "remove"
  ],
  "proof": [
    "aw demo",
    "aw status --json",
    "aw capabilities --json",
    "aw check all",
    "aw verify --task <AT-T> --run-e2e",
    "aw gate pr",
    "aw contract gate",
    "aw score record --scope pr",
    "aw handoff --check"
  ]
}
EOF
  exit 0
fi

cat <<EOF
== agent-workflow capabilities ==
version: ${VERSION}

Pipeline:
  Reference -> DSL reviewed -> Plan executable -> confirm -> AT-T task -> verify -> changelog/git -> handoff

Adapters:
  Claude Code, Codex, Copilot / VS Code, Cursor, Windsurf, Cline, Continue, Any chat

Core commands:
  install, setup, doctor, demo, init, status, capabilities, dashboard, dsl, dsl review, plan, approve,
  confirm, index, check, config, ci, atomic, req, tp, next, task, task split, paste,
  plan change, plan task-add,
  verify, commit, changelog, handoff --write, handoff --check, memory chat, bug,
  audit, policy, policy gate, security, service-catalog, release, release gate --strict-report, report, report handoff, report release, report check, trace, trace check,
  metrics, metrics summary, ops, ops gate, agents, agents gate, sync, sync init, sync push, sync pull, sync baseline, sync board, sync event, sync change, sync inbox,
  gate, gate pre-commit, gate pr, contract, contract change, contract test, contract gate,
  github-pr, github-pr branch, github-pr draft, github-pr gate, score, score record,
  recover, recover context, recover plan, recover sync,
  hooks, adapters, sync-skill, upgrade, remove

Proof:
  aw demo
  aw status --json
  aw capabilities --json
  aw check all
  aw verify --task <AT-T> --run-e2e
  aw gate pr
  aw contract gate
  aw score record --scope pr
  aw handoff --check
  aw report handoff --write
  aw report check --strict
EOF
