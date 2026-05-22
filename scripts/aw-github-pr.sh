#!/usr/bin/env bash
# GitHub branch / PR lifecycle helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
DIR="${ROOT}/docs/github"
CHECKLIST="${DIR}/PR_CHECKLIST.md"
REVIEWS="${DIR}/REVIEW_GATE.md"
POLICY="${DIR}/BRANCH_POLICY.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw github-pr init
  aw github-pr branch --name "task/AT-T001-title" [--checkout]
  aw github-pr draft --title "..." --task AT-T... [--branch "..."] [--write]
  aw github-pr fill --task AT-T... [--title "..."] [--write]
  aw github-pr create --task AT-T... [--title "..."] [--execute]
  aw github-pr review --reviewer "..." --task AT-T... --result pass|changes|block [--evidence "..."]
  aw github-pr gate
  aw github-pr check
EOF
  exit "${1:-0}"
}

ensure_github_pr() {
  mkdir -p "$DIR"
  [[ -f "$CHECKLIST" ]] || cp "${TEMPLATES}/github/PR_CHECKLIST.md" "$CHECKLIST"
  [[ -f "$REVIEWS" ]] || cp "${TEMPLATES}/github/REVIEW_GATE.md" "$REVIEWS"
  [[ -f "$POLICY" ]] || cp "${TEMPLATES}/github/BRANCH_POLICY.md" "$POLICY"
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
    ensure_github_pr
    echo "created/ok: docs/github/"
    ;;
  branch)
    NAME=""
    CHECKOUT=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --name) NAME="${2:-}"; shift 2 ;;
        --checkout) CHECKOUT=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$NAME" ]] || { echo "error: --name is required" >&2; exit 1; }
    ensure_github_pr
    if $CHECKOUT; then
      git -C "$ROOT" checkout -b "$NAME"
    else
      echo "Suggested:"
      echo "  git checkout -b ${NAME}"
    fi
    ;;
  draft)
    TITLE=""
    TASK="—"
    BRANCH="$(git -C "$ROOT" branch --show-current 2>/dev/null || echo "待确认")"
    WRITE=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --title) TITLE="${2:-}"; shift 2 ;;
        --task|--related) TASK="${2:-}"; shift 2 ;;
        --branch) BRANCH="${2:-}"; shift 2 ;;
        --write) WRITE=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$TITLE" ]] || { echo "error: --title is required" >&2; exit 1; }
    ensure_github_pr
    body="$(cat <<EOF
# ${TITLE}

## Trace

- Branch: ${BRANCH}
- Task: ${TASK}
- Requirements: 待确认
- DSL: 待确认
- Plan: 待确认

## Verification

- [ ] aw gate pr
- [ ] aw verify
- [ ] aw contract gate
- [ ] aw score record --scope pr

## Rollback

待确认
EOF
)"
    if $WRITE; then
      mkdir -p "${ROOT}/docs/github/pr-drafts"
      out="${ROOT}/docs/github/pr-drafts/${BRANCH//\//-}.md"
      printf '%s\n' "$body" > "$out"
      echo "written: ${out#"${ROOT}/"}"
    else
      printf '%s\n' "$body"
    fi
    ;;
  fill)
    TASK=""
    TITLE=""
    WRITE=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task|--related) TASK="${2:-}"; shift 2 ;;
        --title) TITLE="${2:-}"; shift 2 ;;
        --write) WRITE=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$TASK" ]] || { echo "error: --task is required" >&2; exit 1; }
    ensure_github_pr
    branch="$(git -C "$ROOT" branch --show-current 2>/dev/null || echo "待确认")"
    [[ -n "$TITLE" ]] || TITLE="${TASK} delivery"
    dsl="$(aw_resolve_dsl_file 2>/dev/null || echo "待确认")"
    plan="$(aw_resolve_plan_file 2>/dev/null || echo "待确认")"
    ctx="docs/context/tasks/CTX-${TASK}.md"
    body="$(cat <<EOF
# ${TITLE}

## Trace

- Branch: ${branch}
- Task: ${TASK}
- DSL: ${dsl}
- Plan: ${plan}
- Context: ${ctx}
- Requirements: docs/requirements/INDEX.md

## Gate Checklist

- [ ] aw context gate --task ${TASK}
- [ ] aw contract gate
- [ ] aw verify --task ${TASK} --affected
- [ ] aw trace check
- [ ] aw score record --scope pr
- [ ] aw github-pr gate

## Changed Files

\`\`\`text
$(git -C "$ROOT" diff --name-only 2>/dev/null || true)
\`\`\`

## Rollback

- Commit checkpoint: 待确认
- Release impact: 待确认
EOF
)"
    if $WRITE; then
      mkdir -p "${ROOT}/docs/github/pr-drafts"
      out="${ROOT}/docs/github/pr-drafts/${branch//\//-}-${TASK}.md"
      printf '%s\n' "$body" > "$out"
      echo "written: ${out#"${ROOT}/"}"
    else
      printf '%s\n' "$body"
    fi
    ;;
  create)
    TASK=""
    TITLE=""
    EXECUTE=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task|--related) TASK="${2:-}"; shift 2 ;;
        --title) TITLE="${2:-}"; shift 2 ;;
        --execute) EXECUTE=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$TASK" ]] || { echo "error: --task is required" >&2; exit 1; }
    ensure_github_pr
    "${SCRIPT_DIR}/aw-github-pr.sh" fill --task "$TASK" ${TITLE:+--title "$TITLE"} --write
    branch="$(git -C "$ROOT" branch --show-current 2>/dev/null || echo "")"
    draft="${ROOT}/docs/github/pr-drafts/${branch//\//-}-${TASK}.md"
    [[ -n "$TITLE" ]] || TITLE="${TASK} delivery"
    if $EXECUTE; then
      command -v gh >/dev/null 2>&1 || { echo "error: gh CLI not installed" >&2; exit 1; }
      gh pr create --title "$TITLE" --body-file "$draft"
    else
      echo "Suggested GitHub PR command:"
      echo "  gh pr create --title \"${TITLE}\" --body-file \"${draft#"${ROOT}/"}\""
      echo "Run with --execute only after engineer confirmation."
    fi
    ;;
  review)
    REVIEWER=""
    TASK="—"
    RESULT=""
    EVIDENCE="—"
    BLOCKERS="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --reviewer) REVIEWER="${2:-}"; shift 2 ;;
        --task|--related) TASK="${2:-}"; shift 2 ;;
        --result) RESULT="${2:-}"; shift 2 ;;
        --evidence) EVIDENCE="${2:-}"; shift 2 ;;
        --blockers) BLOCKERS="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$REVIEWER" ]] || { echo "error: --reviewer is required" >&2; exit 1; }
    case "$RESULT" in pass|changes|block) ;; *) echo "error: --result pass|changes|block" >&2; exit 1 ;; esac
    ensure_github_pr
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    branch="$(git -C "$ROOT" branch --show-current 2>/dev/null || echo "—")"
    insert_row "$REVIEWS" "| ${now} | ${REVIEWER} | ${branch} | ${TASK} | ${RESULT} | ${BLOCKERS} | — | ${EVIDENCE} |"
    echo "logged: docs/github/REVIEW_GATE.md"
    aw_refresh_engineering_index
    ;;
  gate)
    ensure_github_pr
    echo "== github-pr gate =="
    err=0
    kind="$(aw_project_kind)"
    if [[ "$kind" == "github" ]]; then
      aw_github_url_configured || { aw_print_github_url_guidance; err=1; }
    else
      echo "info: project kind is ${kind:-unconfigured}; GitHub PR gate is advisory unless project-kind=github"
    fi
    if grep -Eq '\| .* \| .* \| .* \| .* \| block \|' "$REVIEWS" 2>/dev/null; then
      echo "block: PR review has blocking result" >&2
      err=1
    fi
    "${SCRIPT_DIR}/aw-contract.sh" gate || err=1
    "${SCRIPT_DIR}/aw-score.sh" check || err=1
    if [[ "$err" -eq 0 ]]; then
      echo "github-pr gate: ok"
    else
      echo "github-pr gate: failed" >&2
      exit "$err"
    fi
    ;;
  check)
    echo "== github-pr check =="
    err=0
    for f in "$CHECKLIST" "$REVIEWS" "$POLICY"; do
      if [[ -f "$f" ]]; then
        echo "ok  ${f#"${ROOT}/"}"
      else
        echo "missing  ${f#"${ROOT}/"} (run: aw github-pr init)" >&2
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
