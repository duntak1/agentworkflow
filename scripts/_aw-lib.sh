#!/usr/bin/env bash
# Shared helpers for agent-workflow scripts.

aw_repo_root() {
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    git rev-parse --show-toplevel
  else
    pwd
  fi
}

# Cursor skill root (~/.cursor/skills/agent-workflow) when scripts run from skill bundle
aw_skill_root() {
  if [[ -n "${AW_SKILL_ROOT:-}" && -f "${AW_SKILL_ROOT}/SKILL.md" ]]; then
    echo "${AW_SKILL_ROOT}"
    return 0
  fi
  local script_root
  script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)"
  if [[ -f "${script_root}/SKILL.md" && -d "${script_root}/package" ]]; then
    echo "${script_root}"
    return 0
  fi
  return 1
}

# Policy docs: target repo agent-workflow/ or skill package/
aw_policy_dir() {
  local root
  root="$(aw_repo_root)"
  if [[ -d "${root}/agent-workflow/INVOCATION.md" ]] || [[ -f "${root}/agent-workflow/INVOCATION.md" ]]; then
    echo "${root}/agent-workflow"
    return 0
  fi
  local sk
  sk="$(aw_skill_root 2>/dev/null || true)"
  if [[ -n "$sk" && -f "${sk}/package/INVOCATION.md" ]]; then
    echo "${sk}/package"
    return 0
  fi
  echo "${root}/agent-workflow"
}

aw_templates_dir() {
  local root
  root="$(aw_repo_root)"
  if [[ -n "${AW_TEMPLATES_DIR:-}" && -d "${AW_TEMPLATES_DIR}" ]]; then
    echo "${AW_TEMPLATES_DIR}"
    return 0
  fi
  if [[ -d "${root}/agent-workflow/templates" ]]; then
    echo "${root}/agent-workflow/templates"
    return 0
  fi
  if [[ -n "${AW_SKILL_ROOT:-}" && -d "${AW_SKILL_ROOT}/templates" ]]; then
    echo "${AW_SKILL_ROOT}/templates"
    return 0
  fi
  # Skill install: scripts/../templates
  local script_root
  script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)"
  if [[ -d "${script_root}/templates" && -f "${script_root}/SKILL.md" ]]; then
    echo "${script_root}/templates"
    return 0
  fi
  echo "error: cannot find templates (set AW_TEMPLATES_DIR or run from repo with agent-workflow/templates)" >&2
  return 1
}

aw_copy_if_missing() {
  local src="$1" dest="$2"
  if [[ -e "$dest" ]]; then
    echo "  skip (exists): $dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp -R "$src" "$dest"
    echo "  created: $dest"
  fi
}

aw_refresh_engineering_index() {
  local root script_dir
  root="$(aw_repo_root)"
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
  if [[ -x "${script_dir}/generate-file-index.sh" ]]; then
    "${script_dir}/generate-file-index.sh" >/dev/null 2>&1 || true
  elif [[ -x "${root}/scripts/generate-file-index.sh" ]]; then
    "${root}/scripts/generate-file-index.sh" >/dev/null 2>&1 || true
  fi
  if [[ -x "${script_dir}/generate-engineering-index.sh" ]]; then
    if AW_INDEX_MODE=scan "${script_dir}/generate-engineering-index.sh" --scan-only >/dev/null 2>&1; then
      echo "index: ENGINEERING_INDEX.md refreshed"
    else
      echo "warn: ENGINEERING_INDEX.md refresh failed (run: ./scripts/aw index)" >&2
    fi
  elif [[ -x "${root}/scripts/generate-engineering-index.sh" ]]; then
    if AW_INDEX_MODE=scan "${root}/scripts/generate-engineering-index.sh" --scan-only >/dev/null 2>&1; then
      echo "index: ENGINEERING_INDEX.md refreshed"
    else
      echo "warn: ENGINEERING_INDEX.md refresh failed (run: ./scripts/aw index)" >&2
    fi
  fi
}

aw_project_config_field() {
  local field="$1" cfg
  cfg="$(aw_repo_root)/docs/PROJECT_CONFIG.md"
  [[ -f "$cfg" ]] || return 1
  awk -F'|' -v field="$field" '
    index($0, "**" field "**") > 0 {
      value=$3
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      print value
      exit
    }
  ' "$cfg"
}

aw_detect_git_origin_url() {
  git -C "$(aw_repo_root)" remote get-url origin 2>/dev/null || true
}

aw_project_kind() {
  local kind
  kind="$(aw_project_config_field "项目类型" 2>/dev/null || true)"
  kind="$(echo "$kind" | tr '[:upper:]' '[:lower:]')"
  case "$kind" in
    1|git|github) echo "github" ;;
    2|local|local-git|local_git|本地|本地git|本地项目) echo "local-git" ;;
    *) echo "" ;;
  esac
}

aw_project_stage() {
  local stage
  stage="$(aw_project_config_field "项目阶段" 2>/dev/null || true)"
  stage="$(echo "$stage" | tr '[:upper:]' '[:lower:]')"
  case "$stage" in
    1|new|greenfield|fresh|全新|全新项目|新项目) echo "new" ;;
    2|existing|brownfield|legacy|current|已有|已有项目|存量|存量项目|非全新|非全新项目) echo "existing" ;;
    *) echo "" ;;
  esac
}

aw_build_target() {
  local target
  target="$(aw_project_config_field "构建目标" 2>/dev/null || true)"
  target="$(echo "$target" | tr '[:upper:]' '[:lower:]')"
  case "$target" in
    1|frontend|front|fe|前端|前端项目) echo "frontend" ;;
    2|backend|back|be|server|api|后端|后端项目) echo "backend" ;;
    3|fullstack|full-stack|both|all|前后端|全栈|前后端项目) echo "fullstack" ;;
    *) echo "" ;;
  esac
}

aw_build_target_label() {
  case "$1" in
    frontend) echo "Frontend" ;;
    backend) echo "Backend" ;;
    fullstack) echo "Fullstack" ;;
    *) echo "" ;;
  esac
}

aw_github_url_configured() {
  local url
  url="$(aw_project_config_field "GitHub 仓库地址" 2>/dev/null || true)"
  [[ -n "$url" && "$url" != *"____"* ]]
}

aw_print_project_stage_guidance() {
  echo "请先确认项目阶段：" >&2
  echo "  1) 全新项目：./scripts/aw config init --project-stage 1" >&2
  echo "     路线：reference/inputs → DSL suite → DSL 审核 → Plan → confirm → 开发" >&2
  echo "  2) 已有 / 存量项目：./scripts/aw config init --project-stage 2" >&2
  echo "     路线：现状盘点 → 一期基线回填 → 增量 DSL → 增量 Plan → confirm → 开发" >&2
}

aw_warn_project_stage_before_planning() {
  local stage
  stage="$(aw_project_stage)"
  [[ -n "$stage" ]] && return 0
  echo "" >&2
  echo "warn: 项目阶段未配置；启动 AgentWorkflow 时必须先选择 1=全新项目 或 2=已有/存量项目。" >&2
  aw_print_project_stage_guidance
  echo "" >&2
}

aw_print_build_target_guidance() {
  echo "请先确认构建目标：" >&2
  echo "  1) 前端项目：./scripts/aw config init --build-target 1" >&2
  echo "  2) 后端项目：./scripts/aw config init --build-target 2" >&2
  echo "  3) 前后端项目：./scripts/aw config init --build-target 3" >&2
}

aw_warn_build_target_before_planning() {
  local target
  target="$(aw_build_target)"
  [[ -n "$target" ]] && return 0
  echo "" >&2
  echo "warn: 构建目标未配置；生成研发计划/任务拆分前请先选择 1=前端项目、2=后端项目、3=前后端项目。" >&2
  aw_print_build_target_guidance
  echo "" >&2
}

aw_print_project_kind_guidance() {
  local origin
  origin="$(aw_detect_git_origin_url)"
  echo "请先确认项目类型：" >&2
  echo "  1) GitHub 仓库：./scripts/aw config init --project-kind 1 --github-url https://github.com/<owner>/<repo>" >&2
  echo "  2) 本地 Git 仓库：./scripts/aw config init --project-kind 2" >&2
  if [[ -n "$origin" && "$origin" == *github.com* ]]; then
    echo "检测到 GitHub origin，可直接使用：" >&2
    echo "  ./scripts/aw config init --project-kind 1 --github-url \"${origin}\"" >&2
  fi
}

aw_print_github_url_guidance() {
  local origin
  origin="$(aw_detect_git_origin_url)"
  echo "当前项目类型为 GitHub 仓库，但 GitHub 仓库地址未配置。开始任务拆分或写代码前，请先记录 GitHub 仓库地址：" >&2
  if [[ -n "$origin" && "$origin" == *github.com* ]]; then
    echo "  ./scripts/aw config init --project-kind 1 --github-url \"${origin}\"" >&2
  else
    echo "  ./scripts/aw config init --project-kind 1 --github-url https://github.com/<owner>/<repo>" >&2
  fi
}

aw_warn_github_url_before_planning() {
  local kind
  kind="$(aw_project_kind)"
  if [[ "$kind" == "local-git" ]]; then
    return 0
  fi
  if [[ -z "$kind" ]]; then
    echo "" >&2
    echo "warn: 项目类型未配置；生成研发计划/任务拆分前请先选择 1=GitHub 仓库 或 2=本地 Git 仓库。" >&2
    aw_print_project_kind_guidance
    echo "" >&2
    return 0
  fi
  aw_github_url_configured && return 0
  echo "" >&2
  echo "warn: GitHub 仓库地址未配置；生成研发计划/任务拆分前建议先补齐。若这是本地 Git 仓库，请改为 --project-kind 2。" >&2
  aw_print_github_url_guidance
  echo "" >&2
}

aw_require_github_url_before_coding() {
  local kind
  kind="$(aw_project_kind)"
  if [[ "$kind" == "local-git" ]]; then
    return 0
  fi
  if [[ -z "$kind" ]]; then
    echo "error: 项目类型未配置；代码编写前必须先选择 1=GitHub 仓库 或 2=本地 Git 仓库。" >&2
    aw_print_project_kind_guidance
    return 1
  fi
  aw_github_url_configured && return 0
  echo "error: 当前项目类型为 GitHub 仓库，但 GitHub 仓库地址未配置；代码编写前必须先完成 GitHub 仓库地址配置。" >&2
  aw_print_github_url_guidance
  return 1
}

aw_detect_dsl_path() {
  local manifest="${1:-}"
  if [[ ! -f "$manifest" ]]; then
    echo "A"
    return 0
  fi
  local explicit
  explicit="$(grep -E '^dsl_path:' "$manifest" 2>/dev/null | head -1 | sed 's/^dsl_path:[[:space:]]*//' | tr -d '"' | tr '[:upper:]' '[:lower:]')"
  if [[ "$explicit" == "a" || "$explicit" == "b" || "$explicit" == "c" ]]; then
    echo "$(echo "$explicit" | tr '[:lower:]' '[:upper:]')"
    return 0
  fi
  if grep -q 'type:[[:space:]]*source' "$manifest" 2>/dev/null; then
    echo "C"
    return 0
  fi
  if grep -q 'type:[[:space:]]*design' "$manifest" 2>/dev/null; then
    echo "B"
    return 0
  fi
  echo "A"
}
