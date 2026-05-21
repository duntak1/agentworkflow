#!/usr/bin/env bash
# Frontend/backend API contract helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
DIR="${ROOT}/docs/contracts"
OPENAPI="${DIR}/API_CONTRACT.openapi.yaml"
CHANGELOG="${DIR}/API_CHANGELOG.md"
TESTS="${DIR}/CONTRACT_TESTS.md"
MOCK="${DIR}/MOCK_SERVER.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw contract init
  aw contract change --summary "..." --endpoint "..." --type add|change|remove [--task AT-T] [--breaking]
  aw contract test --task AT-T --mock "..." --contract "..." [--schema-diff "..."] [--result pass|fail] [--evidence "..."]
  aw contract diff [--base path] [--head path]
  aw contract gate
  aw contract check
EOF
  exit "${1:-0}"
}

ensure_contracts() {
  mkdir -p "$DIR"
  [[ -f "$OPENAPI" ]] || cp "${TEMPLATES}/contracts/API_CONTRACT.openapi.yaml" "$OPENAPI"
  [[ -f "$CHANGELOG" ]] || cp "${TEMPLATES}/contracts/API_CHANGELOG.md" "$CHANGELOG"
  [[ -f "$TESTS" ]] || cp "${TEMPLATES}/contracts/CONTRACT_TESTS.md" "$TESTS"
  [[ -f "$MOCK" ]] || cp "${TEMPLATES}/contracts/MOCK_SERVER.md" "$MOCK"
}

insert_row() {
  local file="$1" row="$2" tmp
  tmp="$(mktemp)"
  awk -v row="$row" '
    /^\|------/ && done==0 {print; print row; done=1; next}
    {print}
    END{if(done==0) print row}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

case "$CMD" in
  init)
    ensure_contracts
    echo "created/ok: docs/contracts/"
    ;;
  change)
    SUMMARY=""
    ENDPOINT=""
    TYPE="change"
    TASK="—"
    BREAKING=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --summary) SUMMARY="${2:-}"; shift 2 ;;
        --endpoint) ENDPOINT="${2:-}"; shift 2 ;;
        --type) TYPE="${2:-}"; shift 2 ;;
        --task|--related) TASK="${2:-}"; shift 2 ;;
        --breaking) BREAKING=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$SUMMARY" && -n "$ENDPOINT" ]] || { echo "error: --summary and --endpoint are required" >&2; exit 1; }
    case "$TYPE" in add|change|remove) ;; *) echo "error: --type add|change|remove" >&2; exit 1 ;; esac
    ensure_contracts
    impact="待前后端确认"
    [[ "$BREAKING" == true ]] && impact="破坏性变更，必须前后端确认"
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_row "$CHANGELOG" "| ${now} | ${TASK} | ${TYPE}${BREAKING:+ / breaking} | ${ENDPOINT}: ${SUMMARY} | ${impact} | ${impact} | 待 contract test | open |"
    echo "logged: docs/contracts/API_CHANGELOG.md"
    aw_refresh_engineering_index
    ;;
  test)
    TASK="—"
    MOCK_CMD="—"
    CONTRACT_CMD="—"
    SCHEMA_DIFF="—"
    RESULT="pass"
    EVIDENCE="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task|--related) TASK="${2:-}"; shift 2 ;;
        --mock) MOCK_CMD="${2:-}"; shift 2 ;;
        --contract) CONTRACT_CMD="${2:-}"; shift 2 ;;
        --schema-diff) SCHEMA_DIFF="${2:-}"; shift 2 ;;
        --result) RESULT="${2:-}"; shift 2 ;;
        --evidence) EVIDENCE="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    case "$RESULT" in pass|fail|skipped) ;; *) echo "error: --result pass|fail|skipped" >&2; exit 1 ;; esac
    ensure_contracts
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_row "$TESTS" "| ${now} | ${TASK} | docs/contracts/API_CONTRACT.openapi.yaml | ${MOCK_CMD} | ${CONTRACT_CMD} | ${SCHEMA_DIFF} | ${RESULT} | ${EVIDENCE} |"
    echo "logged: docs/contracts/CONTRACT_TESTS.md"
    aw_refresh_engineering_index
    ;;
  diff)
    BASE=""
    HEAD=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --base) BASE="${2:-}"; shift 2 ;;
        --head) HEAD="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    ensure_contracts
    if [[ -n "$BASE" && -n "$HEAD" ]]; then
      diff -u "$BASE" "$HEAD" || true
    elif git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git -C "$ROOT" diff -- docs/contracts/API_CONTRACT.openapi.yaml || true
    else
      echo "No git diff available. Provide --base and --head."
    fi
    ;;
  gate)
    ensure_contracts
    echo "== contract gate =="
    err=0
    [[ -s "$OPENAPI" ]] && echo "ok  docs/contracts/API_CONTRACT.openapi.yaml" || { echo "missing openapi contract" >&2; err=1; }
    if grep -Eq '\| .*breaking.* \| .*open \|' "$CHANGELOG" 2>/dev/null; then
      echo "block: breaking API change still open" >&2
      err=1
    fi
    if grep -Eq '\| .* \| .* \| .* \| .* \| .* \| .* \| fail \|' "$TESTS" 2>/dev/null; then
      echo "block: failing contract test recorded" >&2
      err=1
    fi
    if grep -q '待确认' "$MOCK" 2>/dev/null; then
      echo "warn  mock server config has 待确认 placeholders" >&2
    fi
    if [[ "$err" -eq 0 ]]; then
      echo "contract gate: ok"
    else
      echo "contract gate: failed" >&2
      exit "$err"
    fi
    ;;
  check)
    echo "== contract check =="
    err=0
    for f in "$OPENAPI" "$CHANGELOG" "$TESTS" "$MOCK"; do
      if [[ -f "$f" ]]; then
        echo "ok  ${f#"${ROOT}/"}"
      else
        echo "missing  ${f#"${ROOT}/"} (run: aw contract init)" >&2
        err=1
      fi
    done
    exit "$err"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
