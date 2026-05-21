#!/usr/bin/env bash
# Pre-commit helper: verify + suggest Conventional Commit with AT-T id (does not commit by default)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"
TASK_ID=""
MESSAGE=""
CHANGELOG_MESSAGE=""
CHANGELOG_TYPE="Changed"
RUN_VERIFY=true
EXECUTE=false

audit_commit() {
  local result="$1"
  if [[ -x "${SCRIPT_DIR}/aw-audit.sh" ]]; then
    "${SCRIPT_DIR}/aw-audit.sh" add --task "${TASK_ID:-—}" --action "commit checkpoint" --result "$result" --evidence "aw commit" >/dev/null || true
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK_ID="${2:-}"; shift 2 ;;
    -m|--message) MESSAGE="${2:-}"; shift 2 ;;
    --no-verify) RUN_VERIFY=false; shift ;;
    --changelog) CHANGELOG_MESSAGE="${2:-}"; shift 2 ;;
    --changelog-type) CHANGELOG_TYPE="${2:-}"; shift 2 ;;
    --execute) EXECUTE=true; shift ;;
    -h|--help)
      cat <<EOF
Usage: aw commit [-m "msg"] [--task AT-T…] [--changelog "..."] [--changelog-type Added|Changed|Fixed|Removed] [--no-verify] [--execute]

Runs aw verify (unless --no-verify), optionally writes CHANGELOG [Unreleased],
and suggests a commit message with AT-T id.
Does not run git commit unless --execute and -m are both set.
EOF
      exit 0
      ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$TASK_ID" && -f "$(aw_workflow_json_path)" ]]; then
  TASK_ID="$(grep -E '"current_task_id"' "$(aw_workflow_json_path)" 2>/dev/null | sed -E 's/.*"([^"]*)".*/\1/' | head -1 || true)"
fi

title=""
if [[ -n "$TASK_ID" ]]; then
  atomic="$(aw_resolve_atomic_tasks_file 2>/dev/null || true)"
  if [[ -n "$atomic" ]]; then
    row="$(aw_task_get_row "${ROOT}/${atomic}" "$TASK_ID" 2>/dev/null || true)"
    [[ -n "$row" ]] && title="$(echo "$row" | awk -F'\t' '{print $2}')"
  fi
fi

if [[ -n "$CHANGELOG_MESSAGE" ]]; then
  "${SCRIPT_DIR}/aw-changelog.sh" add --type "$CHANGELOG_TYPE" --message "$CHANGELOG_MESSAGE"
  audit_commit "CHANGELOG ${CHANGELOG_TYPE}: ${CHANGELOG_MESSAGE}"
fi

if $RUN_VERIFY; then
  if [[ -n "$TASK_ID" ]]; then
    "${SCRIPT_DIR}/aw-verify.sh" --task "$TASK_ID" || exit 1
  else
    "${SCRIPT_DIR}/aw-verify.sh" || exit 1
  fi
fi

if [[ -z "$MESSAGE" ]]; then
  if [[ -n "$TASK_ID" ]]; then
    MESSAGE="feat(${TASK_ID}): ${title:-task complete}"
  else
    MESSAGE="chore: agent-workflow task update"
  fi
fi

echo ""
echo "== Suggested commit =="
echo "$MESSAGE"
echo ""
echo "Commands:"
echo "  git add -A   # or stage selectively"
echo "  git commit -m \"${MESSAGE}\""
echo ""
audit_commit "suggested commit: ${MESSAGE}"

if $EXECUTE; then
  if ! git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    echo "error: not a git repository" >&2
    exit 1
  fi
  git -C "$ROOT" commit -m "$MESSAGE"
  audit_commit "executed commit: ${MESSAGE}"
  echo "ok: committed"
fi
