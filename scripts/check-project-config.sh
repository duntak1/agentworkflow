#!/usr/bin/env bash
# Detect unfilled placeholders in docs/PROJECT_CONFIG.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"
CFG="${ROOT}/docs/PROJECT_CONFIG.md"
ERR=0
WARN=0

warn() { echo "  warn: $*" >&2; WARN=1; }
ok() { echo "  ok: $*"; }

echo "== PROJECT_CONFIG check =="

if [[ ! -f "$CFG" ]]; then
  echo "missing  docs/PROJECT_CONFIG.md (run aw init)"
  exit 1
fi

if grep -qE '_{4,}' "$CFG"; then
  warn "contains blank placeholders (____)"
fi

if grep -qE 'lint：________________|test：________________|build：________________' "$CFG"; then
  warn "lint/test/build still default placeholders"
fi

project_stage="$(awk -F'|' '/\*\*项目阶段\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "$CFG" 2>/dev/null || true)"
scan_file="${ROOT}/docs/PROJECT_SCAN.md"
scan_stage=""
if [[ -f "$scan_file" ]]; then
  scan_stage="$(awk -F'|' '/\*\*建议项目阶段\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "$scan_file" 2>/dev/null || true)"
  ok "项目扫描: docs/PROJECT_SCAN.md (${scan_stage:-unknown})"
else
  warn "项目扫描 missing (run: ./scripts/aw project scan before DSL/Plan/task split)"
fi
case "$project_stage" in
  1|new|greenfield|fresh|全新|全新项目|新项目)
    ok "项目阶段: new"
    ;;
  2|existing|brownfield|legacy|current|已有|已有项目|存量|存量项目|非全新|非全新项目)
    ok "项目阶段: existing"
    ;;
  *)
    warn "项目阶段 not filled (choose: 1=全新项目 ./scripts/aw config init --project-stage 1 OR 2=已有/存量项目 ./scripts/aw config init --project-stage 2)"
    ;;
esac

project_kind="$(awk -F'|' '/\*\*项目类型\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "$CFG" 2>/dev/null || true)"
case "$project_kind" in
  1|git|github)
    project_kind="github"
    ok "项目类型: github"
    ;;
  2|local|local-git|local_git|本地|本地git|本地项目)
    project_kind="local-git"
    ok "项目类型: local-git"
    ;;
  3|gitlab|gitlab.com)
    project_kind="gitlab"
    ok "项目类型: gitlab"
    ;;
  4|bitbucket|bitbucket-cloud)
    project_kind="bitbucket"
    ok "项目类型: bitbucket"
    ;;
  5|gitee|码云)
    project_kind="gitee"
    ok "项目类型: gitee"
    ;;
  6|gitcode)
    project_kind="gitcode"
    ok "项目类型: gitcode"
    ;;
  7|gitea)
    project_kind="gitea"
    ok "项目类型: gitea"
    ;;
  8|forgejo)
    project_kind="forgejo"
    ok "项目类型: forgejo"
    ;;
  9|gitlab-ce|gitlab_ce|self-hosted-gitlab|private-gitlab|私有gitlab|自托管gitlab)
    project_kind="gitlab-ce"
    ok "项目类型: gitlab-ce"
    ;;
  10|gerrit)
    project_kind="gerrit"
    ok "项目类型: gerrit"
    ;;
  11|codeup|aliyun-codeup|云效|阿里云云效)
    project_kind="codeup"
    ok "项目类型: codeup"
    ;;
  *)
    project_kind=""
    warn "项目类型 not filled (choose: 1=GitHub, 2=本地 Git, 3=GitLab, 4=Bitbucket, 5=Gitee, 6=GitCode, 7=Gitea, 8=Forgejo, 9=GitLab CE, 10=Gerrit, 11=云效 Codeup)"
    ;;
esac

repo_url="$(awk -F'|' '/\*\*远程仓库地址\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit }' "$CFG" 2>/dev/null || true)"
github_url="$(awk -F'|' '/\*\*GitHub 仓库地址\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit }' "$CFG" 2>/dev/null || true)"
if [[ -z "$project_kind" ]]; then
  ok "远程仓库地址: pending project type selection"
elif [[ "$project_kind" == "local-git" ]]; then
  ok "远程仓库地址: skipped for local Git repository"
elif [[ -n "$repo_url" && "$repo_url" != *"____"* ]]; then
  ok "远程仓库地址: ${repo_url}"
elif [[ "$project_kind" == "github" && -n "$github_url" && "$github_url" != *"____"* ]]; then
  ok "远程仓库地址: ${github_url}"
elif [[ -z "$repo_url" || "$repo_url" == *"____"* ]]; then
  origin_url="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
  if [[ -n "$origin_url" ]]; then
    warn "远程仓库地址 not filled for ${project_kind} repository (detected origin: ${origin_url}; run: ./scripts/aw config init --project-kind ${project_kind} --repo-url \"${origin_url}\")"
  else
    warn "远程仓库地址 not filled for ${project_kind} repository (run: ./scripts/aw config init --project-kind ${project_kind} --repo-url <repository-url>)"
  fi
fi

build_target="$(awk -F'|' '/\*\*构建目标\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "$CFG" 2>/dev/null || true)"
case "$build_target" in
  1|frontend|front|fe|前端|前端项目)
    ok "构建目标: frontend"
    ;;
  2|backend|back|be|server|api|后端|后端项目)
    ok "构建目标: backend"
    ;;
  3|fullstack|full-stack|both|all|前后端|全栈|前后端项目)
    ok "构建目标: fullstack"
    ;;
  *)
    warn "构建目标 not filled (choose: 1=前端项目 ./scripts/aw config init --build-target 1 OR 2=后端项目 ./scripts/aw config init --build-target 2 OR 3=前后端项目 ./scripts/aw config init --build-target 3)"
    ;;
esac

if [[ "$build_target" == "3" || "$build_target" == "fullstack" || "$build_target" == "full-stack" || "$build_target" == "both" || "$build_target" == "all" || "$build_target" == "前后端" || "$build_target" == "全栈" || "$build_target" == "前后端项目" ]]; then
  if [[ -f "${ROOT}/docs/sync/SYNC_CONFIG.md" ]]; then
    sync_harness="$(awk -F'|' '/\*\*同步中心\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit }' "${ROOT}/docs/sync/SYNC_CONFIG.md" 2>/dev/null || true)"
    if [[ -n "$sync_harness" && "$sync_harness" != *"____"* ]]; then
      ok "同步中心: ${sync_harness}"
    else
      warn "同步中心 configured file exists but missing harness path"
    fi
  else
    warn "fullstack build target requires sync-center decision before frontend/backend Plan split (run: ./scripts/aw sync init <project-harness> --project <name> --agent <agent> --role <frontend|backend>, or document AW_ALLOW_NO_SYNC=1 exception for true monorepo)"
  fi
fi

for key in lint format typecheck test build e2e; do
  local_cmd=""
  local_cmd="$(aw_parse_project_config_cmd "$key" 2>/dev/null || true)"
  if [[ -z "$local_cmd" ]]; then
    if [[ "$key" == "e2e" ]]; then
      warn "${key} command not set (aw verify --run-e2e will skip/fail for TP)"
    elif [[ "$key" == "format" || "$key" == "typecheck" ]]; then
      warn "${key} command not set (recommended for engineering rules)"
    else
      warn "${key} command not set (aw verify will skip)"
    fi
  elif [[ "$local_cmd" == *"____"* ]]; then
    warn "${key} still placeholder"
  else
    ok "${key}: ${local_cmd}"
  fi
done

# Stack hints
if grep -qE '前端栈[^|]*\|[^|]*_{4,}' "$CFG" 2>/dev/null; then
  warn "前端栈 not filled"
fi
if grep -qE '语言[^|]*\|[^|]*_{4,}' "$CFG" 2>/dev/null; then
  warn "语言 not filled"
fi
if grep -qE '工程规范[^|]*\|[^|]*docs/ENGINEERING_RULES.md' "$CFG" 2>/dev/null; then
  ok "engineering rules linked: docs/ENGINEERING_RULES.md"
fi

exit "$ERR"
