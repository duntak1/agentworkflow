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
  *)
    project_kind=""
    warn "项目类型 not filled (choose: 1=GitHub 仓库 ./scripts/aw config init --project-kind 1 --github-url https://github.com/<owner>/<repo> OR 2=本地 Git 仓库 ./scripts/aw config init --project-kind 2)"
    ;;
esac

github_url="$(awk -F'|' '/\*\*GitHub 仓库地址\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit }' "$CFG" 2>/dev/null || true)"
if [[ -z "$project_kind" ]]; then
  ok "GitHub 仓库地址: pending project type selection"
elif [[ "$project_kind" == "local-git" ]]; then
  ok "GitHub 仓库地址: skipped for local Git repository"
elif [[ -z "$github_url" || "$github_url" == *"____"* ]]; then
  origin_url="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
  if [[ -n "$origin_url" && "$origin_url" == *github.com* ]]; then
    warn "GitHub 仓库地址 not filled for GitHub repository (detected origin: ${origin_url}; run: ./scripts/aw config init --project-kind 1 --github-url \"${origin_url}\")"
  else
    warn "GitHub 仓库地址 not filled for GitHub repository (run: ./scripts/aw config init --project-kind 1 --github-url https://github.com/<owner>/<repo>)"
  fi
elif [[ "$github_url" == github:* || "$github_url" == git@github.com:* || "$github_url" == https://github.com/* ]]; then
  ok "GitHub 仓库地址: ${github_url}"
else
  warn "GitHub 仓库地址 format does not look like GitHub: ${github_url}"
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
