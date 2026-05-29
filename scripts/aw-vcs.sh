#!/usr/bin/env bash
# Provider-neutral VCS branch / PR-MR-CR lifecycle helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
DIR="${ROOT}/docs/vcs"
CHECKLIST="${DIR}/PR_CHECKLIST.md"
REVIEWS="${DIR}/REVIEW_GATE.md"
POLICY="${DIR}/BRANCH_POLICY.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw vcs init
  aw vcs branch --name "task/AT-T001-title" [--checkout]
  aw vcs draft --title "..." --task AT-T... [--branch "..."] [--write]
  aw vcs fill --task AT-T... [--title "..."] [--write]
  aw vcs create --task AT-T... [--title "..."] [--execute]
  aw vcs review --reviewer "..." --task AT-T... --result pass|changes|block [--evidence "..."]
  aw vcs gate
  aw vcs check

Providers:
  GitHub, GitLab, Bitbucket, Gitee, GitCode, Gitea, Forgejo, GitLab CE, Gerrit, Codeup, local-git.
EOF
  exit "${1:-0}"
}

provider_label() {
  case "$(aw_project_kind)" in
    github) echo "GitHub Pull Request" ;;
    gitlab|gitlab-ce) echo "GitLab Merge Request" ;;
    bitbucket) echo "Bitbucket Pull Request" ;;
    gitee) echo "Gitee Pull Request" ;;
    gitcode) echo "GitCode Pull Request" ;;
    gitea) echo "Gitea Pull Request" ;;
    forgejo) echo "Forgejo Pull Request" ;;
    gerrit) echo "Gerrit Change" ;;
    codeup) echo "Codeup Merge Request" ;;
    local-git) echo "Local Git review checkpoint" ;;
    *) echo "VCS review checkpoint" ;;
  esac
}

ensure_vcs() {
  mkdir -p "$DIR"
  if [[ ! -f "$CHECKLIST" ]]; then
    cp "${TEMPLATES}/github/PR_CHECKLIST.md" "$CHECKLIST"
    sed -i.bak 's/# PR_CHECKLIST/# VCS_REVIEW_CHECKLIST/' "$CHECKLIST" && rm -f "${CHECKLIST}.bak"
  fi
  if [[ ! -f "$REVIEWS" ]]; then
    cp "${TEMPLATES}/github/REVIEW_GATE.md" "$REVIEWS"
    sed -i.bak 's/# REVIEW_GATE/# VCS_REVIEW_GATE/' "$REVIEWS" && rm -f "${REVIEWS}.bak"
  fi
  if [[ ! -f "$POLICY" ]]; then
    cp "${TEMPLATES}/github/BRANCH_POLICY.md" "$POLICY"
    sed -i.bak 's/PR 前：运行 `aw github-pr gate`。/PR\/MR\/CR 前：运行 `aw vcs gate`。/' "$POLICY" && rm -f "${POLICY}.bak"
  fi
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

draft_body() {
  local title="$1" task="$2" branch="$3"
  local dsl plan ctx provider
  provider="$(provider_label)"
  dsl="$(aw_resolve_dsl_file 2>/dev/null || echo "待确认")"
  plan="$(aw_resolve_plan_file 2>/dev/null || echo "待确认")"
  ctx="docs/context/tasks/CTX-${task}.md"
  cat <<EOF
# ${title}

Provider: ${provider}

## Trace

- Branch: ${branch}
- Task: ${task}
- DSL: ${dsl}
- Plan: ${plan}
- Context: ${ctx}
- Requirements: docs/requirements/INDEX.md

## Gate Checklist

- [ ] aw context gate --task ${task}
- [ ] aw contract gate
- [ ] aw verify --task ${task} --affected
- [ ] aw trace check
- [ ] aw score record --scope pr
- [ ] aw vcs gate

## Changed Files

\`\`\`text
$(git -C "$ROOT" diff --name-only 2>/dev/null || true)
\`\`\`

## Rollback

- Commit checkpoint: 待确认
- Release impact: 待确认
EOF
}

case "$CMD" in
  init)
    ensure_vcs
    echo "created/ok: docs/vcs/"
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
    ensure_vcs
    if $CHECKOUT; then
      git -C "$ROOT" checkout -b "$NAME"
    else
      echo "Suggested:"
      echo "  git checkout -b ${NAME}"
    fi
    ;;
  draft|fill)
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
    [[ -n "$TITLE" ]] || TITLE="${TASK} delivery"
    [[ -n "$TASK" && "$TASK" != "—" ]] || { echo "error: --task is required" >&2; exit 1; }
    ensure_vcs
    body="$(draft_body "$TITLE" "$TASK" "$BRANCH")"
    if $WRITE; then
      mkdir -p "${DIR}/drafts"
      out="${DIR}/drafts/${BRANCH//\//-}-${TASK}.md"
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
    [[ -n "$TITLE" ]] || TITLE="${TASK} delivery"
    ensure_vcs
    "${SCRIPT_DIR}/aw-vcs.sh" fill --task "$TASK" --title "$TITLE" --write
    kind="$(aw_project_kind)"
    branch="$(git -C "$ROOT" branch --show-current 2>/dev/null || echo "")"
    draft="${DIR}/drafts/${branch//\//-}-${TASK}.md"
    if $EXECUTE; then
      case "$kind" in
        github) command -v gh >/dev/null 2>&1 || { echo "error: gh CLI not installed" >&2; exit 1; }; gh pr create --title "$TITLE" --body-file "$draft" ;;
        gitlab|gitlab-ce) command -v glab >/dev/null 2>&1 || { echo "error: glab CLI not installed" >&2; exit 1; }; glab mr create --title "$TITLE" --description-file "$draft" ;;
        *) echo "error: --execute is only automated for GitHub/GitLab when CLI is installed; create manually using docs/vcs/drafts" >&2; exit 1 ;;
      esac
    else
      echo "Suggested $(provider_label) creation:"
      case "$kind" in
        github) echo "  gh pr create --title \"${TITLE}\" --body-file \"${draft#"${ROOT}/"}\"" ;;
        gitlab|gitlab-ce) echo "  glab mr create --title \"${TITLE}\" --description-file \"${draft#"${ROOT}/"}\"" ;;
        bitbucket) echo "  Open Bitbucket Pull Request with body: ${draft#"${ROOT}/"}" ;;
        gitee|gitcode|gitea|forgejo|codeup) echo "  Open provider PR/MR with body: ${draft#"${ROOT}/"}" ;;
        gerrit) echo "  Push for review, then attach body/checklist: ${draft#"${ROOT}/"}" ;;
        local-git) echo "  Use local review checklist: ${draft#"${ROOT}/"}" ;;
        *) echo "  Configure project kind, then create review with body: ${draft#"${ROOT}/"}" ;;
      esac
      echo "Run with --execute only after engineer confirmation and supported CLI setup."
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
    ensure_vcs
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    branch="$(git -C "$ROOT" branch --show-current 2>/dev/null || echo "—")"
    insert_row "$REVIEWS" "| ${now} | ${REVIEWER} | ${branch} | ${TASK} | ${RESULT} | ${BLOCKERS} | — | ${EVIDENCE} |"
    echo "logged: docs/vcs/REVIEW_GATE.md"
    aw_refresh_engineering_index
    ;;
  gate)
    ensure_vcs
    echo "== vcs gate =="
    err=0
    kind="$(aw_project_kind)"
    if [[ -z "$kind" ]]; then
      echo "block: project kind is not configured" >&2
      aw_print_project_kind_guidance
      err=1
    elif aw_project_kind_requires_remote "$kind"; then
      aw_remote_repo_url_configured || { aw_print_remote_repo_url_guidance; err=1; }
    fi
    if grep -Eq '\| .* \| .* \| .* \| .* \| block \|' "$REVIEWS" 2>/dev/null; then
      echo "block: VCS review has blocking result" >&2
      err=1
    fi
    "${SCRIPT_DIR}/aw-contract.sh" gate || err=1
    "${SCRIPT_DIR}/aw-score.sh" check || err=1
    if [[ "$err" -eq 0 ]]; then
      echo "vcs gate: ok"
    else
      echo "vcs gate: failed" >&2
      exit "$err"
    fi
    ;;
  check)
    echo "== vcs check =="
    err=0
    for f in "$CHECKLIST" "$REVIEWS" "$POLICY"; do
      if [[ -f "$f" ]]; then
        echo "ok  ${f#"${ROOT}/"}"
      else
        echo "missing  ${f#"${ROOT}/"} (run: aw vcs init)" >&2
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
