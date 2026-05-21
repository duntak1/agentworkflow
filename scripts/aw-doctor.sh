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
  project_kind="$(awk -F'|' '/\*\*项目类型\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "${ROOT}/docs/PROJECT_CONFIG.md" 2>/dev/null || true)"
  build_target="$(awk -F'|' '/\*\*构建目标\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "${ROOT}/docs/PROJECT_CONFIG.md" 2>/dev/null || true)"
  github_url="$(awk -F'|' '/\*\*GitHub 仓库地址\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit }' "${ROOT}/docs/PROJECT_CONFIG.md" 2>/dev/null || true)"
  origin_url="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
  case "$project_kind" in
    1|git|github) project_kind="github"; ok "project kind github" ;;
    2|local|local-git|local_git|本地|本地git|本地项目) project_kind="local-git"; ok "project kind local-git" ;;
    *) project_kind=""; warn "project kind not recorded (choose: 1=GitHub 仓库 ./scripts/aw config init --project-kind 1 --github-url ... OR 2=本地 Git 仓库 ./scripts/aw config init --project-kind 2)" ;;
  esac
  if [[ -z "$project_kind" ]]; then
    ok "GitHub repo pending project type selection"
  elif [[ "$project_kind" == "local-git" ]]; then
    ok "GitHub repo skipped for local Git repository"
  elif [[ -n "$github_url" && "$github_url" != *"____"* ]]; then
    ok "GitHub repo configured (${github_url})"
  elif [[ -n "$origin_url" && "$origin_url" == *github.com* ]]; then
    warn "GitHub repo URL not recorded (run: ./scripts/aw config init --project-kind 1 --github-url \"${origin_url}\")"
  else
    warn "GitHub repo URL not recorded for GitHub repository (run: ./scripts/aw config init --project-kind 1 --github-url https://github.com/<owner>/<repo>)"
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
