#!/usr/bin/env bash
# Check that core CLI commands are documented in Skill reference and Invocation.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ERR=0

check_doc() {
  local doc="$1" needle="$2"
  if grep -qF "$needle" "$doc" 2>/dev/null; then
    echo "ok  $(basename "$doc"): ${needle}"
  else
    echo "missing  $(basename "$doc"): ${needle}" >&2
    ERR=1
  fi
}

DOCS=(
  "${ROOT}/skill/reference.md"
  "${ROOT}/agent-workflow/INVOCATION.md"
)

if [[ ! -f "${ROOT}/skill/reference.md" ]]; then
  echo "skip: no skill/reference.md in this repo"
  exit 0
fi

COMMANDS=(
  "aw dsl apply"
  "aw dsl suite"
  "aw dsl review"
  "aw dsl list"
  "aw plan apply"
  "aw plan list"
  "aw plan change"
  "aw plan task-add"
  "aw config init"
  "aw rules"
  "aw rules discover"
  "aw task blocked"
  "aw task split"
  "aw task brief"
  "aw task confirm"
  "aw task complete"
  "aw verify --run-e2e"
  "aw check tp"
  "aw check plugin"
  "aw check memory"
  "aw ci install"
  "aw doctor"
  "aw demo"
  "aw dashboard"
  "aw status --json"
  "aw capabilities"
  "aw capabilities --json"
  "aw project scan"
  "aw project gate"
  "aw file-index"
  "aw handoff --check"
  "aw handoff \"focus\" --write"
  "aw memory"
  "aw memory chat"
  "aw bug"
  "aw changelog"
  "aw audit"
  "aw policy"
  "aw policy gate"
  "aw security"
  "aw security scan"
  "aw service-catalog"
  "aw service-catalog discover"
  "aw release"
  "aw release gate"
  "aw release gate --strict-report"
  "aw release flag-check"
  "aw report handoff"
  "aw report release"
  "aw report check"
  "aw metrics"
  "aw metrics summary"
  "aw ops"
  "aw ops gate"
  "aw agents"
  "aw agents gate"
  "aw agents gate --strict"
  "aw sync"
  "aw sync init"
  "aw sync push"
  "aw sync pull"
  "aw sync baseline"
  "aw sync board"
  "aw sync event"
  "aw sync change"
  "aw sync inbox"
  "aw trace check"
  "aw req new"
  "aw req change"
  "aw setup"
  "aw upgrade"
  "aw remove"
)

echo "== docs command check =="
for doc in "${DOCS[@]}"; do
  for cmd in "${COMMANDS[@]}"; do
    check_doc "$doc" "$cmd"
  done
done

exit "$ERR"
