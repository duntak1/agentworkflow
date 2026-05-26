#!/usr/bin/env bash
# Diagnose agent-workflow installation and next actions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"
ERR=0
WARN=0

ok() { echo "ok    $*"; }
warn() { echo "warn  $*"; WARN=1; }
fail() { echo "fail  $*"; ERR=1; }

exists() {
  [[ -e "${ROOT}/$1" ]]
}

echo "== agent-workflow doctor =="
echo "repo: ${ROOT}"
echo ""

exists "agent-workflow/INVOCATION.md" && ok "package installed" || fail "missing agent-workflow/ (run: ./scripts/aw install .)"
[[ -x "${ROOT}/scripts/aw" ]] && ok "CLI executable" || fail "scripts/aw missing or not executable"

if exists "agent-workflow/VERSION"; then
  ok "package version $(tr -d '[:space:]' < "${ROOT}/agent-workflow/VERSION")"
fi
if exists "skill/VERSION" && exists "agent-workflow/VERSION"; then
  skill_ver="$(tr -d '[:space:]' < "${ROOT}/skill/VERSION")"
  pkg_ver="$(tr -d '[:space:]' < "${ROOT}/agent-workflow/VERSION")"
  [[ "$skill_ver" == "$pkg_ver" ]] && ok "skill/package versions match (${skill_ver})" || warn "skill/package versions differ (${skill_ver} vs ${pkg_ver})"
fi

echo ""
echo "== project files =="
exists "reference" && ok "reference/" || warn "missing reference/ (run: ./scripts/aw init)"
exists "docs/PROJECT_CONFIG.md" && ok "PROJECT_CONFIG" || warn "missing docs/PROJECT_CONFIG.md (run: ./scripts/aw init)"
if exists "docs/PROJECT_CONFIG.md"; then
  project_stage="$(awk -F'|' '/\*\*项目阶段\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "${ROOT}/docs/PROJECT_CONFIG.md" 2>/dev/null || true)"
  project_kind="$(awk -F'|' '/\*\*项目类型\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "${ROOT}/docs/PROJECT_CONFIG.md" 2>/dev/null || true)"
  build_target="$(awk -F'|' '/\*\*构建目标\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "${ROOT}/docs/PROJECT_CONFIG.md" 2>/dev/null || true)"
  repo_url="$(awk -F'|' '/\*\*远程仓库地址\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit }' "${ROOT}/docs/PROJECT_CONFIG.md" 2>/dev/null || true)"
  github_url="$(awk -F'|' '/\*\*GitHub 仓库地址\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit }' "${ROOT}/docs/PROJECT_CONFIG.md" 2>/dev/null || true)"
  origin_url="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
  case "$project_stage" in
    1|new|greenfield|fresh|全新|全新项目|新项目) ok "project stage new" ;;
    2|existing|brownfield|legacy|current|已有|已有项目|存量|存量项目|非全新|非全新项目) ok "project stage existing" ;;
    *) warn "project stage not recorded (choose: 1=全新项目 ./scripts/aw config init --project-stage 1 OR 2=已有/存量项目 ./scripts/aw config init --project-stage 2)" ;;
  esac
  case "$project_kind" in
    1|git|github) project_kind="github"; ok "project kind github" ;;
    2|local|local-git|local_git|本地|本地git|本地项目) project_kind="local-git"; ok "project kind local-git" ;;
    3|gitlab|gitlab.com) project_kind="gitlab"; ok "project kind gitlab" ;;
    4|bitbucket|bitbucket-cloud) project_kind="bitbucket"; ok "project kind bitbucket" ;;
    5|gitee|码云) project_kind="gitee"; ok "project kind gitee" ;;
    6|gitcode) project_kind="gitcode"; ok "project kind gitcode" ;;
    7|gitea) project_kind="gitea"; ok "project kind gitea" ;;
    8|forgejo) project_kind="forgejo"; ok "project kind forgejo" ;;
    9|gitlab-ce|gitlab_ce|self-hosted-gitlab|private-gitlab|私有gitlab|自托管gitlab) project_kind="gitlab-ce"; ok "project kind gitlab-ce" ;;
    10|gerrit) project_kind="gerrit"; ok "project kind gerrit" ;;
    11|codeup|aliyun-codeup|云效|阿里云云效) project_kind="codeup"; ok "project kind codeup" ;;
    *) project_kind=""; warn "project kind not recorded (choose provider: 1=GitHub, 2=local Git, 3=GitLab, 4=Bitbucket, 5=Gitee, 6=GitCode, 7=Gitea, 8=Forgejo, 9=GitLab CE, 10=Gerrit, 11=Codeup)" ;;
  esac
  if [[ -z "$project_kind" ]]; then
    ok "remote repo pending project type selection"
  elif [[ "$project_kind" == "local-git" ]]; then
    ok "remote repo skipped for local Git repository"
  elif [[ -n "$repo_url" && "$repo_url" != *"____"* ]]; then
    ok "remote repo configured (${repo_url})"
  elif [[ "$project_kind" == "github" && -n "$github_url" && "$github_url" != *"____"* ]]; then
    ok "remote repo configured (${github_url})"
  elif [[ -n "$origin_url" ]]; then
    warn "remote repo URL not recorded (run: ./scripts/aw config init --project-kind ${project_kind} --repo-url \"${origin_url}\")"
  else
    warn "remote repo URL not recorded for ${project_kind} repository (run: ./scripts/aw config init --project-kind ${project_kind} --repo-url <repository-url>)"
  fi
  case "$build_target" in
    1|frontend|front|fe|前端|前端项目) ok "build target frontend" ;;
    2|backend|back|be|server|api|后端|后端项目) ok "build target backend" ;;
    3|fullstack|full-stack|both|all|前后端|全栈|前后端项目) ok "build target fullstack" ;;
    *) warn "build target not recorded (choose: 1=frontend, 2=backend, 3=fullstack)" ;;
  esac
fi
exists "docs/dsl" && ok "docs/dsl/" || warn "missing docs/dsl/ (run: ./scripts/aw init)"
exists "docs/plans" && ok "docs/plans/" || warn "missing docs/plans/ (run: ./scripts/aw init)"

dsl="$(aw_resolve_dsl_file 2>/dev/null || true)"
plan="$(aw_resolve_plan_file 2>/dev/null || true)"
atomic="$(aw_resolve_atomic_tasks_file "$plan" 2>/dev/null || true)"
if [[ -n "$dsl" ]]; then
  dsl_st="$(aw_read_metadata_status "${ROOT}/${dsl}")"
  ok "DSL ${dsl} [${dsl_st}]"
else
  warn "no DSL selected/found"
fi
if [[ -n "$plan" ]]; then
  plan_st="$(aw_read_metadata_status "${ROOT}/${plan}")"
  ok "Plan ${plan} [${plan_st}]"
else
  warn "no Plan found"
fi
[[ -n "$atomic" ]] && ok "ATOMIC ${atomic}" || warn "no ATOMIC_TASKS file"
exists "docs/.aw-workflow.json" && ok "workflow confirmed state present" || warn "no confirm state (run: ./scripts/aw confirm <dsl> <plan>)"

echo ""
echo "== adapters / automation =="
exists "AGENTS.md" && ok "Codex adapter" || warn "missing AGENTS.md (run: ./scripts/aw adapters --codex)"
exists "CLAUDE.md" && ok "Claude adapter" || warn "missing CLAUDE.md (run: ./scripts/aw adapters --claude)"
exists ".github/copilot-instructions.md" && ok "Copilot adapter" || warn "missing Copilot adapter"
exists ".cursor/rules/agent-workflow.mdc" && ok "Cursor adapter" || warn "missing Cursor adapter"
exists ".github/workflows/agent-workflow.yml" && ok "project CI workflow" || warn "missing project CI workflow (run: ./scripts/aw ci install)"

echo ""
echo "== checks =="
if "${ROOT}/scripts/aw" check all >/tmp/aw-doctor-check.log 2>&1; then
  ok "aw check all"
else
  warn "aw check all reported issues; inspect with: ./scripts/aw check all"
fi

echo ""
if [[ "$ERR" -eq 0 && "$WARN" -eq 0 ]]; then
  echo "doctor: ok"
elif [[ "$ERR" -eq 0 ]]; then
  echo "doctor: ok with warnings"
else
  echo "doctor: failed"
fi

exit "$ERR"
