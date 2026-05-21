#!/usr/bin/env bash
# Delivery scorecard helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
DIR="${ROOT}/docs/score"
SCORE="${DIR}/DELIVERY_SCORE.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw score init
  aw score record [--scope "AT-T001|REQ|release|pr"]
  aw score check
  aw score latest
EOF
  exit "${1:-0}"
}

ensure_score() {
  mkdir -p "$DIR"
  [[ -f "$SCORE" ]] || cp "${TEMPLATES}/score/DELIVERY_SCORE.md" "$SCORE"
}

score_item() {
  local label="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    echo "20|${label}:ok"
  else
    echo "0|${label}:missing"
  fi
}

insert_row() {
  local row="$1" tmp
  tmp="$(mktemp)"
  awk -v row="$row" '
    /^\|------/ && done==0 {print; print row; done=1; next}
    {print}
    END{if(done==0) print row}
  ' "$SCORE" > "$tmp"
  mv "$tmp" "$SCORE"
}

case "$CMD" in
  init)
    ensure_score
    echo "created/ok: docs/score/DELIVERY_SCORE.md"
    ;;
  record)
    SCOPE="current"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --scope) SCOPE="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    ensure_score
    req="$(score_item req 'test -f "${ROOT}/docs/requirements/INDEX.md"')"
    dsl="$(score_item dsl-plan '"${SCRIPT_DIR}/check-dsl.sh" >/dev/null 2>&1 && "${SCRIPT_DIR}/check-plan.sh" >/dev/null 2>&1')"
    task="$(score_item task-confirm 'test -f "${ROOT}/docs/.aw-workflow.json" -o -f "${ROOT}/docs/.aw-task-confirmed.json"')"
    verify="$(score_item verify 'test -f "${ROOT}/docs/quality/test-plans/INDEX.md"')"
    bug="$(score_item bug 'test -f "${ROOT}/docs/handoff/AI_BUG_LOG.md"')"
    file_index="$(score_item file-index 'test -f "${ROOT}/docs/FILE_INDEX.md"')"
    contract="$(score_item contract 'test -f "${ROOT}/docs/contracts/API_CONTRACT.openapi.yaml"')"
    git_rel="$(score_item git-release 'test -f "${ROOT}/docs/release/RELEASE_RECORD.md"')"
    handoff="$(score_item handoff 'test -f "${ROOT}/docs/handoff/PROJECT_HANDOFF.md"')"
    total=0
    for item in "$req" "$dsl" "$task" "$verify" "$bug" "$file_index" "$contract" "$git_rel" "$handoff"; do
      total=$((total + ${item%%|*}))
    done
    # Normalize 9 checks x 20 = 180 to 100.
    total=$((total * 100 / 180))
    conclusion="review"
    [[ "$total" -ge 85 ]] && conclusion="pass"
    [[ "$total" -lt 60 ]] && conclusion="risk"
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_row "| ${now} | ${SCOPE} | ${total} | ${req#*|} | ${dsl#*|} | ${task#*|} | ${verify#*|} | ${bug#*|} | ${file_index#*|} | ${contract#*|} | ${git_rel#*|} | ${handoff#*|} | ${conclusion} |"
    echo "score: ${total}/100 (${conclusion})"
    aw_refresh_engineering_index
    ;;
  check)
    echo "== score check =="
    if [[ -f "$SCORE" ]]; then
      echo "ok  docs/score/DELIVERY_SCORE.md"
    else
      echo "missing  docs/score/DELIVERY_SCORE.md (run: aw score init)" >&2
      exit 1
    fi
    ;;
  latest)
    ensure_score
    awk '/^\| [0-9]{4}-/ {print; exit}' "$SCORE" || true
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
