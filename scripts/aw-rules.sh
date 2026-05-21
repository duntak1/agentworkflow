#!/usr/bin/env bash
# Engineering rules helper: init/review/check.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
RULES="${ROOT}/docs/ENGINEERING_RULES.md"
CMD="${1:-review}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw rules init             Create docs/ENGINEERING_RULES.md if missing
  aw rules review           Print engineer-facing rules checklist
  aw rules discover [--write]  Discover key project files for ENGINEERING_RULES.md
  aw rules check            Validate rules document exists and key sections are present
EOF
  exit "${1:-0}"
}

ensure_rules() {
  mkdir -p "${ROOT}/docs"
  if [[ ! -f "$RULES" ]]; then
    cp "${TEMPLATES}/rules/ENGINEERING_RULES.md" "$RULES"
    echo "created: docs/ENGINEERING_RULES.md"
  fi
}

scan_rule_files() {
  if command -v rg >/dev/null 2>&1; then
    rg --files "$ROOT" 2>/dev/null | sed "s#^${ROOT}/##" | grep -Ev '^(\.agents|\.codex-plugin|\.cursor|\.github/copilot-instructions\.md|agent-workflow|docs|reference|scripts|skill|node_modules|vendor|\.git|dist|build|target|coverage|tmp|temp|out|\.next|\.nuxt|\.vite)/' || true
  else
    find "$ROOT" -type f 2>/dev/null | sed "s#^${ROOT}/##" | grep -Ev '^(\.agents|\.codex-plugin|\.cursor|\.github/copilot-instructions\.md|agent-workflow|docs|reference|scripts|skill|node_modules|vendor|\.git|dist|build|target|coverage|tmp|temp|out|\.next|\.nuxt|\.vite)/' || true
  fi
}

scan_rule_text() {
  local pattern="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden --glob '!*.md' --glob '!LICENSE*' --glob '!NOTICE*' --glob '!CHANGELOG*' --glob '!agent-workflow/**' --glob '!docs/**' --glob '!reference/**' --glob '!scripts/**' --glob '!skill/**' --glob '!.agents/**' --glob '!.codex-plugin/**' --glob '!.cursor/**' --glob '!.github/**' --glob '!node_modules/**' --glob '!vendor/**' --glob '!.git/**' --glob '!dist/**' --glob '!build/**' --glob '!target/**' --glob '!coverage/**' --glob '!tmp/**' --glob '!temp/**' --glob '!out/**' --glob '!.next/**' --glob '!.nuxt/**' --glob '!.vite/**' "$pattern" "$ROOT" 2>/dev/null | sed "s#^${ROOT}/##" | grep -Ev '^(LICENSE|NOTICE|CHANGELOG)(\..*)?:|(\.agents|\.codex-plugin|\.cursor|\.github|agent-workflow|docs|reference|scripts|skill|node_modules|vendor|\.git|dist|build|target|coverage|tmp|temp|out|\.next|\.nuxt|\.vite)/' | head -8 || true
  else
    grep -RInE "$pattern" "$ROOT" 2>/dev/null | sed "s#^${ROOT}/##" | grep -Ev '^(LICENSE|NOTICE|CHANGELOG)(\..*)?:|(\.agents|\.codex-plugin|\.cursor|\.github|agent-workflow|docs|reference|scripts|skill|node_modules|vendor|\.git|dist|build|target|coverage|tmp|temp|out|\.next|\.nuxt|\.vite)/|\.md:' | head -8 || true
  fi
}

first_match() {
  local pattern="$1"
  scan_rule_files | grep -E "$pattern" | head -1 || true
}

first_text_file() {
  local pattern="$1"
  scan_rule_text "$pattern" | awk -F: '{print $1}' | head -1 || true
}

discover_rules_rows() {
  local permission router api_client exception response security migration ci build
  permission="$(first_text_file 'permission|permissions|hasPerm|auth|roles|RBAC|AccessDenied|SecurityFilterChain|WebSecurityConfigurerAdapter')"
  router="$(first_match '(^|/)(router|routes)/(index|static-routes|dynamic-routes)\.(ts|js|tsx|jsx)$|(^|/)router\.(ts|js)$|(^|/)routes\.(ts|js)$')"
  api_client="$(first_match '(^|/)(utils|lib|api)/(request|axios|client|http)\.(ts|js)$|(^|/)src/api/index\.(ts|js)$')"
  exception="$(first_text_file 'GlobalException|ExceptionHandler|ControllerAdvice|RestControllerAdvice|errorHandler|handleError')"
  response="$(first_text_file 'CommonResponse|ApiResponse|Result<|Result\\.|统一响应|ResponseEntity')"
  security="$(first_text_file 'JWT|Spring Security|SecurityConfig|SecurityFilterChain|WebSecurityConfigurerAdapter|UserDetailsService|Bearer')"
  migration="$(first_match '(^|/)(db/migration|migrations|migration|sql|database)/.*\.(sql|xml|yaml|yml)$')"
  ci="$(first_match '^\.github/workflows/.*\.(yml|yaml)$|^\.gitlab-ci\.yml$|^Jenkinsfile$')"
  build="$(first_match '(^|/)(package\.json|vite\.config\.(ts|js)|pom\.xml|build\.gradle|settings\.gradle|Dockerfile|docker-compose\.ya?ml)$')"

  echo "| ${permission:-待填写} | 权限入口 |"
  echo "| ${router:-待填写} | 路由入口 |"
  echo "| ${api_client:-待填写} | 统一 API Client |"
  echo "| ${exception:-待填写} | 全局异常处理 |"
  echo "| ${response:-待填写} | 统一响应封装 |"
  echo "| ${security:-待填写} | 安全配置 |"
  echo "| ${migration:-待填写} | 数据库迁移目录 |"
  echo "| ${ci:-待填写} | CI/CD 配置 |"
  echo "| ${build:-待填写} | 构建配置 |"
}

replace_key_files_table() {
  local rows="$1" tmp rows_file
  tmp="$(mktemp)"
  rows_file="$(mktemp)"
  printf '%s\n' "$rows" > "$rows_file"
  awk -v rows_file="$rows_file" '
    /^## 关键文件/ {in_key=1; print; next}
    in_key && /^\| 路径 \|/ {print; next}
    in_key && /^\|------/ {
      print
      while ((getline row < rows_file) > 0) print row
      close(rows_file)
      inserted=1
      next
    }
    in_key && /^## / {in_key=0; print; next}
    in_key && /^\|/ {next}
    {print}
    END {
      if (in_key && inserted==0) {
        print "| 路径 | 说明 |"
        print "|------|------|"
        while ((getline row < rows_file) > 0) print row
        close(rows_file)
      }
    }
  ' "$RULES" > "$tmp"
  rm -f "$rows_file"
  mv "$tmp" "$RULES"
}

discover_rules() {
  local write="$1" rows
  ensure_rules >/dev/null
  rows="$(discover_rules_rows)"
  echo "== engineering rules discovery =="
  printf '%s\n' "$rows"
  if $write; then
    replace_key_files_table "$rows"
    echo "updated: docs/ENGINEERING_RULES.md"
    aw_refresh_engineering_index
  else
    echo ""
    echo "note: discovery only. Re-run with --write to update the 关键文件 table."
  fi
}

check_rules() {
  local err=0
  echo "== engineering rules check =="
  if [[ ! -f "$RULES" ]]; then
    echo "missing  docs/ENGINEERING_RULES.md (run: aw rules init)" >&2
    return 1
  fi
  echo "ok  docs/ENGINEERING_RULES.md"
  for section in "技术栈" "代码规范" "安全底线" "常见任务 SOP" "Git 提交"; do
    if grep -q "## ${section}" "$RULES" 2>/dev/null; then
      echo "ok  section: ${section}"
    else
      echo "missing  section: ${section}" >&2
      err=1
    fi
  done
  if grep -q '注释原则' "$RULES" 2>/dev/null; then
    echo "ok  rule: 注释原则"
  else
    echo "missing  rule: 注释原则" >&2
    err=1
  fi
  if grep -q '成熟方案优先' "$RULES" 2>/dev/null; then
    echo "ok  rule: 成熟方案优先"
  else
    echo "missing  rule: 成熟方案优先" >&2
    err=1
  fi
  if grep -q '提交前流程' "$RULES" 2>/dev/null && grep -q 'aw commit' "$RULES" 2>/dev/null && grep -q '阶段性提交提醒' "$RULES" 2>/dev/null; then
    echo "ok  rule: Git 提交流程"
  else
    echo "missing  rule: Git 提交流程" >&2
    err=1
  fi
  for section in "前端模块规范" "后端模块规范"; do
    if grep -q "## ${section}" "$RULES" 2>/dev/null; then
      echo "ok  section: ${section}"
    else
      echo "warn  missing recommended section: ${section}" >&2
    fi
  done
  for phrase in \
    "团队固定前端栈" \
    "Vue 3 + Vite + TypeScript" \
    "Element Plus" \
    "EleAdmin" \
    "团队固定后端栈" \
    "Spring Cloud Alibaba" \
    "MyBatis-Plus" \
    "MyBaseMapper" \
    "CommonResponse" \
    "团队前端标准目录" \
    "团队后端标准结构" \
    "JWT + RBAC" \
    "敏感字段清单" \
    "依赖准入" \
    "许可证白名单" \
    "许可证黑名单" \
    "完整文件路径" \
    "REQ" \
    "权限入口" \
    "统一 API Client" \
    "数据库迁移目录"; do
    if grep -qF "$phrase" "$RULES" 2>/dev/null; then
      echo "ok  team rule: ${phrase}"
    else
      echo "missing  team rule: ${phrase}" >&2
      err=1
    fi
  done
  if grep -q '待填写' "$RULES" 2>/dev/null; then
    echo "warn  contains 待填写 placeholders" >&2
  fi
  return "$err"
}

review_rules() {
  ensure_rules >/dev/null
  cat <<EOF
# Engineering Rules Review

## 必读

- docs/ENGINEERING_RULES.md
- docs/PROJECT_CONFIG.md
- AGENTS.md / CLAUDE.md（若存在）

## 工程师确认项

- [ ] 技术栈填写完整：前端、后端、数据库、构建、部署。
- [ ] 团队固定前端栈已保留：Vue3、Vite、TypeScript、Pinia、Vue Router、Axios、Element Plus、EleAdmin。
- [ ] 团队固定后端栈已保留：Java 8、Spring Boot 2.6.13、Spring Cloud Alibaba 2021.0.5.0、MyBatis-Plus 3.5.2、Redis、Kafka、MinIO、Maven 等。
- [ ] 代码规范可执行：目录、命名、分层、DTO/VO、API client、状态管理。
- [ ] 统一执行规范已保留：完整文件路径输出、JWT+RBAC、安全字段清单、许可证白/黑名单、依赖准入、关键文件索引。
- [ ] 注释原则清楚：复杂业务规则、边界、权衡、临时方案和跨模块联动有注释；无噪声注释。
- [ ] 成熟方案优先：项目既有工具、官方 SDK、成熟开源库、框架内置能力优先；新依赖需确认许可证、安全和维护状态。
- [ ] 禁令明确：依赖、共享目录、安全、SQL、日志、金额、CORS。
- [ ] 前端模块规范可落地：目录、API、types、hooks、store 条件、CRUD 能力。
- [ ] 后端模块规范可落地：输出顺序、分层、DTO/VO、Mapper/Repository、API 契约。
- [ ] 常见任务 SOP 可落地：前端页面、后端接口、数据库变更、CRUD、认证、文件上传下载。
- [ ] Git 提交流程可执行：验证、Bug 留痕、REQ/DSL/Plan 回写、diff 自查、选择性 stage、commit message 和 hook/CI 规则清楚。
- [ ] 阶段性提交提醒明确：每个大需求 / AT-T 完成后询问工程师是否提交当前分支；不同意提交则写 handoff 风险。
- [ ] 验证命令已同步到 docs/PROJECT_CONFIG.md。
- [ ] 当前 DSL/Plan 的领域任务能映射到对应工程规范。

## 通过后

\`\`\`bash
./scripts/aw check rules
./scripts/aw check config
\`\`\`
EOF
}

case "$CMD" in
  init)
    ensure_rules
    aw_refresh_engineering_index
    echo "next: edit docs/ENGINEERING_RULES.md → aw rules review → aw check rules"
    ;;
  review)
    review_rules
    ;;
  discover)
    WRITE=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --write) WRITE=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    discover_rules "$WRITE"
    ;;
  check)
    check_rules
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
