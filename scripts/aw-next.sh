#!/usr/bin/env bash
# Print next AT-T* task (with coding gates).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"

aw_gate_coding_ready || exit 1
atomic="$(aw_resolve_atomic_tasks_file)" || {
  echo "error: no docs/plans/ATOMIC_TASKS_*.md" >&2
  exit 1
}

row="$(aw_task_find_next "${ROOT}/${atomic}")" || {
  echo "No eligible AT-T* (待办/进行中, deps satisfied)"
  exit 1
}

IFS=$'\t' read -r id domain title st dep ver <<< "$row"

echo "== Next task ($(basename "$atomic")) =="
echo ""
echo "ID:     ${id}"
echo "Domain: ${domain}"
echo "Title:  ${title}"
echo "Status: ${st}"
echo "Deps:   ${dep:-—}"
echo "Verify: ${ver:-—}"
echo ""
echo "Brief:  ./scripts/aw task brief ${id}"
echo "Confirm after discussion: ./scripts/aw task confirm ${id} \"已确认：范围=...；验收=...；非目标=...\""
echo "Start:  ./scripts/aw task start ${id}"
echo "Full:   ${atomic}"
