#!/usr/bin/env bash
# Create REQ-YYYYMMDD-NN-slug.md and update INDEX.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
SLUG="${1:-}"
TITLE="${2:-}"
DATE="$(date +%Y%m%d)"

usage() {
  echo "Usage: $0 <slug> \"<title>\"" >&2
  echo "Example: $0 my-feature \"用户登录优化\"" >&2
  exit 1
}

[[ -n "$SLUG" && -n "$TITLE" ]] || usage
SLUG="$(echo "$SLUG" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-//;s/-$//')"

REQ_DIR="${ROOT}/docs/requirements"
TEMPLATE="${REQ_DIR}/_TEMPLATE.md"
INDEX="${REQ_DIR}/INDEX.md"

[[ -f "$TEMPLATE" ]] || { echo "error: missing $TEMPLATE (run aw init)" >&2; exit 1; }

next_seq() {
  local max=0 n
  for f in "${REQ_DIR}"/REQ-"${DATE}"-*.md; do
    [[ -f "$f" ]] || continue
    n="$(basename "$f" | sed -n "s/REQ-${DATE}-\\([0-9]*\\).*/\\1/p")"
    [[ -n "$n" ]] && ((10#$n > max)) && max=$((10#$n))
  done
  for f in "${REQ_DIR}"/REQ-*.md; do
    [[ -f "$f" ]] || continue
    [[ "$(basename "$f")" == REQ-"${DATE}"-* ]] || continue
  done
  printf '%03d' $((max + 1))
}

SEQ="$(next_seq)"
ID="REQ-${DATE}-${SEQ}"
BASENAME="${ID}-${SLUG}"
FILE="${REQ_DIR}/${BASENAME}.md"

if [[ -f "$FILE" ]]; then
  echo "error: already exists: $FILE" >&2
  exit 1
fi

sed -e "s/REQ-YYYYMMDD-NN-short-slug/${BASENAME}/" \
    -e "s/REQ-YYYYMMDD-NN/${ID}/" \
    -e "s/YYYY-MM-DD/$(date +%Y-%m-%d)/" \
    "$TEMPLATE" > "$FILE"

# Update INDEX
if [[ ! -f "$INDEX" ]]; then
  cat > "$INDEX" <<'EOF'
# 需求索引（REQ）

| ID | 标题 | 状态 | 提出日期 | 备注 |
|----|------|------|----------|------|
EOF
fi

TMP="$(mktemp)"
{
  awk 'NR<=6' "$INDEX" 2>/dev/null || cat <<'HDR'
# 需求索引（REQ）

| ID | 标题 | 状态 | 提出日期 | 备注 |
|----|------|------|----------|------|
HDR
  echo "| [${ID}](./${BASENAME}.md) | ${TITLE} | 草稿 | $(date +%Y-%m-%d) | |"
  awk 'NR>6 && !/尚无更多/' "$INDEX" 2>/dev/null || true
} > "$TMP"
mv "$TMP" "$INDEX"

echo "Created: docs/requirements/${BASENAME}.md"
echo "Updated: docs/requirements/INDEX.md"
