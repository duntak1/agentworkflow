#!/usr/bin/env bash
# One-shot context compaction for Codex/new-session continuity.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
FOCUS=""
WRITE=false
CHECK=true
SNAPSHOT=false
PASTE=true
MEMORY_SUMMARY=""
MEMORY_DECISIONS="—"
MEMORY_TODOS="—"
MEMORY_OPEN="—"
MEMORY_RELATED="docs/handoff/PROJECT_HANDOFF.md"
MEMORY_SLUG=""
MEMORY_TITLE=""

usage() {
  cat <<'EOF'
Usage:
  aw compact [focus] [--write] [--snapshot] [--memory-summary "..."] [--memory-decisions "..."] [--memory-todos "..."] [--memory-open "..."] [--memory-related "..."] [--memory-slug slug] [--memory-title "title"] [--no-paste] [--no-check]

Purpose:
  Generate a standard handoff snapshot before Codex context compaction,
  model switch, long pause, or new chat. This does not hook into Codex
  native compaction events; it gives agents a deterministic command to run.

Outputs:
  - docs/handoff/PROJECT_HANDOFF.md when --write is set.
  - docs/handoff/LAST_AUTO_SNAPSHOT.md when --snapshot is set.
  - docs/handoff/PASTE_IN_NEW_CHAT.txt when paste output is enabled.
  - docs/memory/entries/MEM-*.md when --memory-summary is provided.
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --write) WRITE=true; shift ;;
    --snapshot) SNAPSHOT=true; shift ;;
    --no-paste) PASTE=false; shift ;;
    --no-check) CHECK=false; shift ;;
    --memory-summary) MEMORY_SUMMARY="${2:-}"; shift 2 ;;
    --memory-decisions) MEMORY_DECISIONS="${2:-}"; shift 2 ;;
    --memory-todos) MEMORY_TODOS="${2:-}"; shift 2 ;;
    --memory-open) MEMORY_OPEN="${2:-}"; shift 2 ;;
    --memory-related) MEMORY_RELATED="${2:-}"; shift 2 ;;
    --memory-slug) MEMORY_SLUG="${2:-}"; shift 2 ;;
    --memory-title) MEMORY_TITLE="${2:-}"; shift 2 ;;
    -h|--help|help) usage 0 ;;
    *)
      if [[ -n "$FOCUS" ]]; then
        FOCUS="${FOCUS} $1"
      else
        FOCUS="$1"
      fi
      shift
      ;;
  esac
done

[[ -n "$FOCUS" ]] || FOCUS="上下文压缩快照"
mkdir -p "${ROOT}/docs/handoff"

echo "== aw compact =="
echo "focus: ${FOCUS}"

if $WRITE; then
  "${SCRIPT_DIR}/draft-handoff.sh" "$FOCUS" --write
else
  "${SCRIPT_DIR}/draft-handoff.sh" "$FOCUS" > "${ROOT}/docs/handoff/LAST_AUTO_SNAPSHOT.md"
  SNAPSHOT=true
  echo "written: docs/handoff/LAST_AUTO_SNAPSHOT.md"
fi

if $SNAPSHOT && $WRITE; then
  "${SCRIPT_DIR}/draft-handoff.sh" "$FOCUS" > "${ROOT}/docs/handoff/LAST_AUTO_SNAPSHOT.md"
  echo "written: docs/handoff/LAST_AUTO_SNAPSHOT.md"
fi

if $CHECK; then
  "${SCRIPT_DIR}/draft-handoff.sh" --check
fi

if [[ -n "$MEMORY_SUMMARY" ]]; then
  if [[ -z "$MEMORY_SLUG" ]]; then
    MEMORY_SLUG="$(printf '%s' "$FOCUS" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-//;s/-$//')"
    [[ -n "$MEMORY_SLUG" ]] || MEMORY_SLUG="compact-chat"
  fi
  [[ -n "$MEMORY_TITLE" ]] || MEMORY_TITLE="Compact chat summary: ${FOCUS}"
  "${SCRIPT_DIR}/aw-memory.sh" chat "$MEMORY_SLUG" "$MEMORY_TITLE" \
    --summary "$MEMORY_SUMMARY" \
    --decisions "$MEMORY_DECISIONS" \
    --todos "$MEMORY_TODOS" \
    --open "$MEMORY_OPEN" \
    --related "$MEMORY_RELATED" \
    --source "aw compact" \
    --confidence medium \
    --scope task
fi

if $PASTE; then
  paste_file="${ROOT}/docs/handoff/PASTE_IN_NEW_CHAT.txt"
  cat > "$paste_file" <<EOF
请继续这个项目，先按 agent-workflow 恢复上下文。

必读：
1. agent-workflow/INVOCATION.md
2. docs/handoff/PROJECT_HANDOFF.md
3. docs/requirements/INDEX.md
4. docs/memory/INDEX.md

恢复命令：
./scripts/aw handoff --check
./scripts/aw memory inject
./scripts/aw status
./scripts/aw next

规则：
- 不要读取 ENGINEERING_INDEX.md 作为 AI 上下文。
- 不要全仓扫描；写代码前先 aw task brief / aw task confirm / aw context plan / aw context gate / aw task start。
- 如果本次是 Codex 原生上下文压缩后的继续，请以 PROJECT_HANDOFF.md 为工程真源，以 memory inject 为长期记忆补充。

本次压缩焦点：
${FOCUS}
EOF
  echo "written: docs/handoff/PASTE_IN_NEW_CHAT.txt"
fi

if [[ -x "${SCRIPT_DIR}/generate-engineering-index.sh" ]]; then
  AW_INDEX_MODE=scan "${SCRIPT_DIR}/generate-engineering-index.sh" --scan-only >/dev/null 2>&1 || true
fi

echo "next:"
echo "  New chat: paste docs/handoff/PASTE_IN_NEW_CHAT.txt"
echo "  Current chat: continue with ./scripts/aw status"
