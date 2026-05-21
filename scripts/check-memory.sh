#!/usr/bin/env bash
# Validate docs/memory layout and entries.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
MEM="${ROOT}/docs/memory"
ERR=0

echo "== memory check =="

if [[ ! -d "$MEM" ]]; then
  echo "skip: no docs/memory (run aw memory init)"
  exit 0
fi

need() {
  if [[ -e "${ROOT}/$1" ]]; then
    echo "ok  $1"
  else
    echo "missing  $1" >&2
    ERR=1
  fi
}

need "docs/memory/README.md"
need "docs/memory/INDEX.md"
need "docs/memory/entries"
need "docs/memory/archive"

if [[ -f "${MEM}/INDEX.md" ]] && grep -q '| ID | Type | Title | Confidence | Scope | Source | Lifecycle | Updated | Link |' "${MEM}/INDEX.md"; then
  echo "ok  memory index header"
else
  echo "missing  memory index header" >&2
  ERR=1
fi

shopt -s nullglob
for f in "${MEM}/entries"/MEM-*.md; do
  rel="${f#${ROOT}/}"
  for field in ID Type Confidence Scope Source Lifecycle Updated; do
    if grep -qF "| **${field}** |" "$f"; then
      :
    else
      echo "missing  ${rel}: ${field}" >&2
      ERR=1
    fi
  done
  if grep -Eiq '(api[_-]?key|token|password|secret)[[:space:]]*[:=]' "$f"; then
    echo "fail  possible secret in ${rel}" >&2
    ERR=1
  fi
done

exit "$ERR"
