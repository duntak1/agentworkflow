#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
SLUG="${1:-}"
TITLE="${2:-}"
DATE="$(date +%Y%m%d)"

[[ -n "$SLUG" && -n "$TITLE" ]] || {
  echo "Usage: $0 <slug> \"<title>\"" >&2
  exit 1
}

SLUG="$(echo "$SLUG" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-//;s/-$//')"
TP_DIR="${ROOT}/docs/quality/test-plans"
TEMPLATE="${TP_DIR}/_TEMPLATE.md"
INDEX="${TP_DIR}/INDEX.md"

[[ -f "$TEMPLATE" ]] || { echo "error: missing $TEMPLATE" >&2; exit 1; }

max=0
for f in "${TP_DIR}"/TP-"${DATE}"-*.md; do
  [[ -f "$f" ]] || continue
  n="$(basename "$f" | sed -n "s/TP-${DATE}-\\([0-9]*\\).*/\\1/p")"
  [[ -n "$n" ]] && ((10#$n > max)) && max=$((10#$n))
done
SEQ="$(printf '%03d' $((max + 1)))"
ID="TP-${DATE}-${SEQ}"
BASENAME="${ID}-${SLUG}"
FILE="${TP_DIR}/${BASENAME}.md"

sed -e "s/TP-YYYYMMDD-NN-short-slug/${BASENAME}/" \
    -e "s/TP-YYYYMMDD-NN/${ID}/" \
    -e "s/YYYY-MM-DD/$(date +%Y-%m-%d)/" \
    "$TEMPLATE" > "$FILE"

if [[ ! -f "$INDEX" ]]; then
  cat > "$INDEX" <<'EOF'
# Test Plan Index (TP)

| ID | 标题 | 状态 | 日期 | 链接 |
|----|------|------|------|------|
EOF
fi

TMP="$(mktemp)"
{
  head -n 5 "$INDEX"
  echo "| ${ID} | ${TITLE} | 草稿 | $(date +%Y-%m-%d) | [${BASENAME}.md](./${BASENAME}.md) |"
  awk 'NR>5' "$INDEX" 2>/dev/null || true
} > "$TMP"
mv "$TMP" "$INDEX"

echo "Created: docs/quality/test-plans/${BASENAME}.md"
aw_refresh_engineering_index
