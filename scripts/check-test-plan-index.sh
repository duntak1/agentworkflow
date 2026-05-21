#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TP_DIR="${ROOT}/docs/quality/test-plans"
INDEX="${TP_DIR}/INDEX.md"
ERR=0

echo "== test-plan index check =="

if [[ ! -d "$TP_DIR" ]]; then
  echo "skip: no docs/quality/test-plans/"
  exit 0
fi

shopt -s nullglob
count=0
for f in "${TP_DIR}"/TP-*.md; do
  count=$((count + 1))
  base="$(basename "$f")"
  if [[ ! -f "$INDEX" ]] || ! grep -qF "${base}" "$INDEX"; then
    echo "missing in INDEX: docs/quality/test-plans/${base}"
    ERR=1
  else
    echo "ok  docs/quality/test-plans/${base}"
  fi
done

if [[ "$count" -eq 0 ]]; then
  echo "skip: no TP-*.md files"
fi

exit "$ERR"
