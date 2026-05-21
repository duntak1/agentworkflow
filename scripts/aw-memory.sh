#!/usr/bin/env bash
# File-based agent memory helpers.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
MEM_DIR="${ROOT}/docs/memory"
ENTRY_DIR="${MEM_DIR}/entries"
ARCHIVE_DIR="${MEM_DIR}/archive"
INDEX="${MEM_DIR}/INDEX.md"
DATE="$(date +%Y%m%d)"
TODAY="$(date +%Y-%m-%d)"

usage() {
  cat <<'EOF'
Usage:
  aw memory init
  aw memory add <slug> "title" [--type semantic|episodic|procedural|preference|risk] [--source text] [--confidence low|medium|high] [--scope repo|feature|task|global] [--body text]
  aw memory chat <slug> "title" --summary "..." [--decisions "..."] [--todos "..."] [--open "..."] [--related "..."] [--source text] [--confidence low|medium|high] [--scope repo|feature|task|global]
  aw memory list
  aw memory search <query>
  aw memory show <MEM-id|path>
  aw memory archive <MEM-id|path>
  aw memory inject [query]
EOF
  exit "${1:-0}"
}

memory_init() {
  mkdir -p "$ENTRY_DIR" "$ARCHIVE_DIR"
  if [[ ! -f "${MEM_DIR}/README.md" ]]; then
    if [[ -f "${ROOT}/agent-workflow/templates/memory/README.md" ]]; then
      cp "${ROOT}/agent-workflow/templates/memory/README.md" "${MEM_DIR}/README.md"
    else
      cat > "${MEM_DIR}/README.md" <<'EOF'
# Agent Memory

File-based memory for reusable decisions, facts, preferences, patterns, and risks.
EOF
    fi
    echo "created: docs/memory/README.md"
  fi
  if [[ ! -f "$INDEX" ]]; then
    if [[ -f "${ROOT}/agent-workflow/templates/memory/INDEX.md" ]]; then
      cp "${ROOT}/agent-workflow/templates/memory/INDEX.md" "$INDEX"
    else
      cat > "$INDEX" <<'EOF'
# Memory Index

| ID | Type | Title | Confidence | Scope | Source | Lifecycle | Updated | Link |
|----|------|-------|------------|-------|--------|-----------|---------|------|
EOF
    fi
    echo "created: docs/memory/INDEX.md"
  fi
  if [[ ! -f "${MEM_DIR}/_TEMPLATE.md" ]]; then
    if [[ -f "${ROOT}/agent-workflow/templates/memory/_TEMPLATE.md" ]]; then
      cp "${ROOT}/agent-workflow/templates/memory/_TEMPLATE.md" "${MEM_DIR}/_TEMPLATE.md"
    fi
  fi
}

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-//;s/-$//'
}

detect_secret() {
  if printf '%s\n' "$@" | grep -Eiq '(api[_-]?key|token|password|passwd|secret)[[:space:]]*[:=]'; then
    return 0
  fi
  return 1
}

next_seq() {
  local max=0 n f
  shopt -s nullglob
  for f in "${ENTRY_DIR}"/MEM-"${DATE}"-*.md "${ARCHIVE_DIR}"/MEM-"${DATE}"-*.md; do
    [[ -f "$f" ]] || continue
    n="$(basename "$f" | sed -n "s/MEM-${DATE}-\\([0-9]*\\).*/\\1/p")"
    [[ -n "$n" ]] && ((10#$n > max)) && max=$((10#$n))
  done
  printf '%03d' $((max + 1))
}

resolve_memory_file() {
  local arg="$1"
  [[ -z "$arg" ]] && return 1
  if [[ -f "${ROOT}/${arg}" ]]; then
    echo "${ROOT}/${arg}"
    return 0
  fi
  if [[ -f "$arg" ]]; then
    echo "$arg"
    return 0
  fi
  local f
  for f in "${ENTRY_DIR}/${arg}"*.md "${ARCHIVE_DIR}/${arg}"*.md; do
    [[ -f "$f" ]] || continue
    echo "$f"
    return 0
  done
  return 1
}

append_index_row() {
  local id="$1" type="$2" title="$3" confidence="$4" scope="$5" source="$6" lifecycle="$7" rel="$8"
  local tmp
  tmp="$(mktemp)"
  {
    awk 'NR<=4' "$INDEX"
    echo "| ${id} | ${type} | ${title} | ${confidence} | ${scope} | ${source} | ${lifecycle} | ${TODAY} | [${rel}](./${rel#docs/memory/}) |"
    awk 'NR>4 && $0 !~ /^\\| MEM-/' "$INDEX" >/dev/null 2>&1 || true
    awk 'NR>4 && /^\\| MEM-/' "$INDEX" 2>/dev/null || true
  } > "$tmp"
  mv "$tmp" "$INDEX"
}

cmd="${1:-list}"
shift || true

case "$cmd" in
  init)
    memory_init
    ;;
  add)
    slug="${1:-}"
    title="${2:-}"
    [[ -n "$slug" && -n "$title" ]] || usage 1
    shift 2
    type="semantic"
    source="manual"
    confidence="medium"
    scope="repo"
    body=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --type) type="${2:-}"; shift 2 ;;
        --source) source="${2:-}"; shift 2 ;;
        --confidence) confidence="${2:-}"; shift 2 ;;
        --scope) scope="${2:-}"; shift 2 ;;
        --body) body="${2:-}"; shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown option: $1" >&2; usage 1 ;;
      esac
    done
    case "$type" in semantic|episodic|procedural|preference|risk) ;; *) echo "error: invalid type: $type" >&2; exit 1 ;; esac
    case "$confidence" in low|medium|high) ;; *) echo "error: invalid confidence: $confidence" >&2; exit 1 ;; esac
    case "$scope" in repo|feature|task|global) ;; *) echo "error: invalid scope: $scope" >&2; exit 1 ;; esac
    if detect_secret "$title" "$source" "$body"; then
      echo "error: possible secret detected; do not store secrets in memory" >&2
      exit 1
    fi
    memory_init >/dev/null
    slug="$(slugify "$slug")"
    seq="$(next_seq)"
    id="MEM-${DATE}-${seq}"
    file="${ENTRY_DIR}/${id}-${slug}.md"
    rel="docs/memory/entries/$(basename "$file")"
    cat > "$file" <<EOF
# ${id}-${slug}

## Metadata

| Field | Value |
|-------|-------|
| **ID** | ${id} |
| **Type** | ${type} |
| **Confidence** | ${confidence} |
| **Scope** | ${scope} |
| **Source** | ${source} |
| **Lifecycle** | active |
| **Updated** | ${TODAY} |

## Memory

${body:-${title}}

## Evidence

- ${source}

## Reuse Notes

- Inject with \`aw memory inject\` when relevant.
EOF
    append_index_row "$id" "$type" "$title" "$confidence" "$scope" "$source" "active" "$rel"
    echo "Created: ${rel}"
    ;;
  chat)
    slug="${1:-}"
    title="${2:-}"
    [[ -n "$slug" && -n "$title" ]] || usage 1
    shift 2
    summary=""
    decisions="—"
    todos="—"
    open="—"
    related="—"
    source="chat"
    confidence="medium"
    scope="task"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --summary) summary="${2:-}"; shift 2 ;;
        --decisions) decisions="${2:-}"; shift 2 ;;
        --todos) todos="${2:-}"; shift 2 ;;
        --open) open="${2:-}"; shift 2 ;;
        --related) related="${2:-}"; shift 2 ;;
        --source) source="${2:-}"; shift 2 ;;
        --confidence) confidence="${2:-}"; shift 2 ;;
        --scope) scope="${2:-}"; shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown option: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$summary" ]] || { echo "error: aw memory chat requires --summary" >&2; exit 1; }
    case "$confidence" in low|medium|high) ;; *) echo "error: invalid confidence: $confidence" >&2; exit 1 ;; esac
    case "$scope" in repo|feature|task|global) ;; *) echo "error: invalid scope: $scope" >&2; exit 1 ;; esac
    if detect_secret "$title" "$summary" "$decisions" "$todos" "$open" "$related" "$source"; then
      echo "error: possible secret detected; do not store secrets in chat memory" >&2
      exit 1
    fi
    memory_init >/dev/null
    slug="$(slugify "$slug")"
    [[ -n "$slug" ]] || slug="chat-summary"
    seq="$(next_seq)"
    id="MEM-${DATE}-${seq}"
    file="${ENTRY_DIR}/${id}-${slug}.md"
    rel="docs/memory/entries/$(basename "$file")"
    cat > "$file" <<EOF
# ${id}-${slug}

## Metadata

| Field | Value |
|-------|-------|
| **ID** | ${id} |
| **Type** | episodic |
| **Confidence** | ${confidence} |
| **Scope** | ${scope} |
| **Source** | ${source} |
| **Lifecycle** | active |
| **Updated** | ${TODAY} |

## Memory

${summary}

## Chat Decisions

${decisions}

## Follow-ups

${todos}

## Open Questions

${open}

## Related

${related}

## Evidence

- Summarized from chat: ${source}

## Reuse Notes

- Use this as chat context only; requirements still belong in \`docs/requirements/\`.
- Promote stable conclusions with \`aw memory add --type semantic|procedural|preference|risk\` when they should outlive the chat episode.
EOF
    append_index_row "$id" "episodic" "$title" "$confidence" "$scope" "$source" "active" "$rel"
    echo "Created: ${rel}"
    ;;
  list)
    memory_init >/dev/null
    echo "== Memory =="
    awk 'NR<=4 || /^\\| MEM-/' "$INDEX"
    ;;
  search)
    query="${1:-}"
    [[ -n "$query" ]] || { echo "error: aw memory search <query>" >&2; exit 1; }
    memory_init >/dev/null
    echo "== Memory search: ${query} =="
    grep -Rni --include='MEM-*.md' "$query" "$ENTRY_DIR" "$ARCHIVE_DIR" 2>/dev/null || true
    ;;
  show)
    arg="${1:-}"
    [[ -n "$arg" ]] || { echo "error: aw memory show <MEM-id|path>" >&2; exit 1; }
    file="$(resolve_memory_file "$arg")" || { echo "error: memory not found: $arg" >&2; exit 1; }
    sed -n '1,120p' "$file"
    ;;
  archive)
    arg="${1:-}"
    [[ -n "$arg" ]] || { echo "error: aw memory archive <MEM-id|path>" >&2; exit 1; }
    file="$(resolve_memory_file "$arg")" || { echo "error: memory not found: $arg" >&2; exit 1; }
    mkdir -p "$ARCHIVE_DIR"
    dest="${ARCHIVE_DIR}/$(basename "$file")"
    mv "$file" "$dest"
    echo "Archived: docs/memory/archive/$(basename "$dest")"
    ;;
  inject)
    query="${1:-}"
    memory_init >/dev/null
    echo "== Agent Memory Inject =="
    echo "Read these memory entries before acting. Treat them as context, not as unverified truth."
    echo ""
    if [[ -n "$query" ]]; then
      grep -Ril --include='MEM-*.md' "$query" "$ENTRY_DIR" 2>/dev/null | head -8 | while IFS= read -r f; do
        echo "- docs/memory/entries/$(basename "$f")"
        awk '/^## Memory/{flag=1; next} /^## Evidence/{flag=0} flag && NF {print "  " $0; exit}' "$f"
      done
    else
      find "$ENTRY_DIR" -name 'MEM-*.md' -type f | sort | tail -8 | while IFS= read -r f; do
        echo "- docs/memory/entries/$(basename "$f")"
        awk '/^## Memory/{flag=1; next} /^## Evidence/{flag=0} flag && NF {print "  " $0; exit}' "$f"
      done
    fi
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $cmd" >&2
    usage 1
    ;;
esac
