#!/usr/bin/env bash
# PROJECT_CONFIG helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
CFG="${ROOT}/docs/PROJECT_CONFIG.md"
CMD="${1:-help}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw config init [--project-stage 1|2] [--project-kind provider] [--build-target 1|2|3] [--repo-url url] [--github-url url] [--default-branch branch] [--issue-system name] [--language lang] [--package-manager pm] [--frontend stack] [--ui library] [--backend stack] [--database db] [--lint cmd] [--format cmd] [--typecheck cmd] [--test cmd] [--build cmd] [--e2e cmd]

Project stage:
  1 = new       Brand-new project; start from reference -> DSL -> Plan.
  2 = existing  Existing/brownfield project; inventory current state first,
                backfill baseline, then generate incremental DSL/Plan.

Project kind:
  1  = github     GitHub public cloud repository.
  2  = local-git  Local Git repository; skips remote repository URL.
  3  = gitlab     GitLab.com repository.
  4  = bitbucket  Bitbucket Cloud repository.
  5  = gitee      Gitee repository.
  6  = gitcode    GitCode repository.
  7  = gitea      Self-hosted Gitea repository.
  8  = forgejo    Self-hosted Forgejo repository.
  9  = gitlab-ce  Self-hosted GitLab CE repository.
  10 = gerrit     Gerrit repository.
  11 = codeup     Alibaba Cloud Yunxiao Codeup repository.

Remote providers require 远程仓库地址 before planning/coding.

Fills docs/PROJECT_CONFIG.md placeholders. Omitted commands are auto-detected
from package.json when possible, otherwise left as placeholders.
EOF
  exit "${1:-0}"
}

detect_npm_script() {
  local name="$1"
  [[ -f "${ROOT}/package.json" ]] || return 1
  if grep -q "\"${name}\"[[:space:]]*:" "${ROOT}/package.json"; then
    if [[ -f "${ROOT}/pnpm-lock.yaml" ]]; then echo "pnpm ${name}"
    elif [[ -f "${ROOT}/yarn.lock" ]]; then echo "yarn ${name}"
    else echo "npm run ${name}"
    fi
    return 0
  fi
  return 1
}

detect_git_remote_url() {
  git -C "$ROOT" remote get-url origin 2>/dev/null || true
}

replace_field() {
  local field="$1" value="$2" tmp
  [[ -n "$value" ]] || return 0
  tmp="$(mktemp)"
  awk -F'|' -v field="$field" -v value="$value" '
    BEGIN { OFS="|" }
    index($0, "**" field "**") > 0 {
      print "| **" field "** | " value " |"
      next
    }
    { print }
  ' "$CFG" > "$tmp"
  mv "$tmp" "$CFG"
}

replace_cmd() {
  local key="$1" value="$2" tmp
  [[ -n "$value" ]] || return 0
  tmp="$(mktemp)"
  sed -E "s#^${key}[：:].*#${key}：${value}#" "$CFG" > "$tmp"
  mv "$tmp" "$CFG"
}

case "$CMD" in
  init)
    [[ -f "$CFG" ]] || { echo "error: missing docs/PROJECT_CONFIG.md (run aw init)" >&2; exit 1; }
    project_stage=""
    project_kind=""
    build_target=""
    repo_url=""
    github_url=""
    default_branch=""
    issue_system=""
    frontend=""
    language=""
    package_manager=""
    ui=""
    backend=""
    database=""
    lint=""
    format=""
    typecheck=""
    test_cmd=""
    build=""
    e2e=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --project-stage|--stage)
          case "$(echo "${2:-}" | tr '[:upper:]' '[:lower:]')" in
            1|new|greenfield|fresh|全新|全新项目|新项目) project_stage="new" ;;
            2|existing|brownfield|legacy|current|已有|已有项目|存量|存量项目|非全新|非全新项目) project_stage="existing" ;;
            *) echo "error: --project-stage must be 1/new or 2/existing" >&2; exit 1 ;;
          esac
          shift 2
          ;;
        --project-kind|--kind)
          case "$(echo "${2:-}" | tr '[:upper:]' '[:lower:]')" in
            1|github|git|remote|github-repo|github仓库|github项目) project_kind="github" ;;
            2|local-git|local_git|local|本地|本地git|本地-git|本地项目|本地git仓库) project_kind="local-git" ;;
            3|gitlab|gitlab.com|gitlab仓库|gitlab项目) project_kind="gitlab" ;;
            4|bitbucket|bitbucket-cloud|bitbucket仓库) project_kind="bitbucket" ;;
            5|gitee|码云|gitee仓库) project_kind="gitee" ;;
            6|gitcode|gitcode仓库) project_kind="gitcode" ;;
            7|gitea|gitea仓库|私有gitea) project_kind="gitea" ;;
            8|forgejo|forgejo仓库|私有forgejo) project_kind="forgejo" ;;
            9|gitlab-ce|gitlab_ce|self-hosted-gitlab|private-gitlab|私有gitlab|自托管gitlab|gitlab私有化) project_kind="gitlab-ce" ;;
            10|gerrit|gerrit仓库) project_kind="gerrit" ;;
            11|codeup|aliyun-codeup|aliyun|yunxiao|云效|阿里云云效|阿里云codeup|codeup仓库) project_kind="codeup" ;;
            *) echo "error: --project-kind must be a supported provider (1=github, 2=local-git, 3=gitlab, 4=bitbucket, 5=gitee, 6=gitcode, 7=gitea, 8=forgejo, 9=gitlab-ce, 10=gerrit, 11=codeup)" >&2; exit 1 ;;
          esac
          shift 2
          ;;
        --build-target|--target)
          case "$(echo "${2:-}" | tr '[:upper:]' '[:lower:]')" in
            1|frontend|front|fe|前端|前端项目) build_target="frontend" ;;
            2|backend|back|be|server|api|后端|后端项目) build_target="backend" ;;
            3|fullstack|full-stack|both|all|前后端|全栈|前后端项目) build_target="fullstack" ;;
            *) echo "error: --build-target must be 1(frontend), 2(backend), or 3(fullstack)" >&2; exit 1 ;;
          esac
          shift 2
          ;;
        --repo-url|--remote-url) repo_url="${2:-}"; shift 2 ;;
        --github-url) github_url="${2:-}"; repo_url="${2:-}"; shift 2 ;;
        --default-branch) default_branch="${2:-}"; shift 2 ;;
        --issue-system) issue_system="${2:-}"; shift 2 ;;
        --language) language="${2:-}"; shift 2 ;;
        --package-manager|--pm) package_manager="${2:-}"; shift 2 ;;
        --frontend) frontend="${2:-}"; shift 2 ;;
        --ui) ui="${2:-}"; shift 2 ;;
        --backend) backend="${2:-}"; shift 2 ;;
        --database|--db) database="${2:-}"; shift 2 ;;
        --lint) lint="${2:-}"; shift 2 ;;
        --format) format="${2:-}"; shift 2 ;;
        --typecheck) typecheck="${2:-}"; shift 2 ;;
        --test) test_cmd="${2:-}"; shift 2 ;;
        --build) build="${2:-}"; shift 2 ;;
        --e2e|--playwright) e2e="${2:-}"; shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    if [[ -z "$project_stage" ]]; then
      current_stage="$(awk -F'|' '/\*\*项目阶段\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "$CFG" 2>/dev/null || true)"
      case "$current_stage" in
        1|new|greenfield|fresh|全新|全新项目|新项目) project_stage="new" ;;
        2|existing|brownfield|legacy|current|已有|已有项目|存量|存量项目|非全新|非全新项目) project_stage="existing" ;;
      esac
    fi
    if [[ -z "$project_kind" && -n "$github_url" ]]; then
      project_kind="github"
    fi
    if [[ -z "$repo_url" && -n "$github_url" ]]; then
      repo_url="$github_url"
    fi
    if [[ -z "$project_kind" ]]; then
      current_kind="$(awk -F'|' '/\*\*项目类型\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "$CFG" 2>/dev/null || true)"
      case "$current_kind" in
        1|git|github) project_kind="github" ;;
        2|local|local-git|local_git|本地|本地git|本地项目) project_kind="local-git" ;;
        3|gitlab|gitlab.com) project_kind="gitlab" ;;
        4|bitbucket|bitbucket-cloud) project_kind="bitbucket" ;;
        5|gitee|码云) project_kind="gitee" ;;
        6|gitcode) project_kind="gitcode" ;;
        7|gitea) project_kind="gitea" ;;
        8|forgejo) project_kind="forgejo" ;;
        9|gitlab-ce|gitlab_ce|self-hosted-gitlab|private-gitlab|私有gitlab|自托管gitlab) project_kind="gitlab-ce" ;;
        10|gerrit) project_kind="gerrit" ;;
        11|codeup|aliyun-codeup|云效|阿里云云效) project_kind="codeup" ;;
      esac
    fi
    if [[ -z "$build_target" ]]; then
      current_target="$(awk -F'|' '/\*\*构建目标\*\*/ { gsub(/^[ \t]+|[ \t]+$/, "", $3); print tolower($3); exit }' "$CFG" 2>/dev/null || true)"
      case "$current_target" in
        1|frontend|front|fe|前端|前端项目) build_target="frontend" ;;
        2|backend|back|be|server|api|后端|后端项目) build_target="backend" ;;
        3|fullstack|full-stack|both|all|前后端|全栈|前后端项目) build_target="fullstack" ;;
      esac
    fi
    if [[ -n "$project_kind" && "$project_kind" != "local-git" && -z "$repo_url" ]]; then
      repo_url="$(detect_git_remote_url)"
    fi
    if [[ "$project_kind" == "github" && -z "$github_url" ]]; then
      github_url="$repo_url"
    fi
    [[ -n "$lint" ]] || lint="$(detect_npm_script lint 2>/dev/null || true)"
    [[ -n "$format" ]] || format="$(detect_npm_script format 2>/dev/null || true)"
    [[ -n "$typecheck" ]] || typecheck="$(detect_npm_script typecheck 2>/dev/null || detect_npm_script check 2>/dev/null || true)"
    [[ -n "$test_cmd" ]] || test_cmd="$(detect_npm_script test 2>/dev/null || true)"
    [[ -n "$build" ]] || build="$(detect_npm_script build 2>/dev/null || true)"
    [[ -n "$e2e" ]] || e2e="$(detect_npm_script e2e 2>/dev/null || detect_npm_script playwright 2>/dev/null || true)"
    replace_field "项目阶段" "$project_stage"
    replace_field "项目类型" "$project_kind"
    replace_field "构建目标" "$build_target"
    replace_field "远程仓库地址" "$repo_url"
    replace_field "GitHub 仓库地址" "$github_url"
    replace_field "默认分支" "$default_branch"
    replace_field "Issue 系统" "$issue_system"
    replace_field "语言" "$language"
    replace_field "包管理器" "$package_manager"
    replace_field "前端栈" "$frontend"
    replace_field "UI 库" "$ui"
    replace_field "后端栈" "$backend"
    replace_field "数据库" "$database"
    replace_cmd "lint" "$lint"
    replace_cmd "format" "$format"
    replace_cmd "typecheck" "$typecheck"
    replace_cmd "test" "$test_cmd"
    replace_cmd "build" "$build"
    replace_cmd "e2e" "$e2e"
    echo "ok: updated docs/PROJECT_CONFIG.md"
    echo "next: ./scripts/aw check config"
    ;;
  -h|--help|help) usage 0 ;;
  *) echo "Unknown: $CMD" >&2; usage 1 ;;
esac
