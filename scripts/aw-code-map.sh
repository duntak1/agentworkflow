#!/usr/bin/env bash
# Code Map helper: build/query a lightweight project graph before reading code.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
CTX_DIR="${ROOT}/docs/context"
CODE_MAP="${CTX_DIR}/CODE_MAP.md"
CODE_INDEX="${CTX_DIR}/CODE_CONTEXT_INDEX.md"
CMD="${1:-status}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw code-map init
  aw code-map build [--max-files 450]
  aw code-map status
  aw code-map query "symbol or keyword"
  aw code-map impact "symbol or keyword"
  aw code-map affected [--task AT-T...]
  aw code-map gate --task AT-T...
EOF
  exit "${1:-0}"
}

ensure_code_map() {
  mkdir -p "$CTX_DIR"
  [[ -f "$CODE_MAP" ]] || cp "${TEMPLATES}/context/CODE_MAP.md" "$CODE_MAP"
  [[ -f "$CODE_INDEX" ]] || cp "${TEMPLATES}/context/CODE_CONTEXT_INDEX.md" "$CODE_INDEX"
}

rel() {
  local path="$1"
  echo "${path#"${ROOT}/"}"
}

blocked_globs=(
  '!.git/**'
  '!node_modules/**'
  '!dist/**'
  '!build/**'
  '!coverage/**'
  '!.next/**'
  '!.nuxt/**'
  '!target/**'
  '!vendor/**'
  '!tmp/**'
  '!logs/**'
)

list_code_files() {
  if command -v rg >/dev/null 2>&1; then
    rg --files "$ROOT" \
      --glob '!agent-workflow/AGENTWORKFLOW_MANUAL.html' \
      --glob '!docs/index.html' \
      --glob '!.git/**' --glob '!node_modules/**' --glob '!dist/**' --glob '!build/**' \
      --glob '!coverage/**' --glob '!.next/**' --glob '!.nuxt/**' --glob '!target/**' \
      --glob '!vendor/**' --glob '!tmp/**' --glob '!logs/**' \
      | sed "s#${ROOT}/##" \
      | awk '
        /\.(sh|bash|zsh|md|mdx|ts|tsx|js|jsx|vue|svelte|py|go|rs|java|kt|kts|php|rb|cs|swift|mjs|cjs|css|scss|less|html|sql|yaml|yml|json|toml|xml)$/ {print}
      '
  else
    find "$ROOT" \
      \( -path "$ROOT/.git" -o -path "$ROOT/node_modules" -o -path "$ROOT/dist" -o -path "$ROOT/build" -o -path "$ROOT/coverage" -o -path "$ROOT/.next" -o -path "$ROOT/.nuxt" -o -path "$ROOT/target" -o -path "$ROOT/vendor" -o -path "$ROOT/tmp" -o -path "$ROOT/logs" \) -prune -o \
      -type f | sed "s#${ROOT}/##" \
      | awk '/\.(sh|bash|zsh|md|mdx|ts|tsx|js|jsx|vue|svelte|py|go|rs|java|kt|kts|php|rb|cs|swift|mjs|cjs|css|scss|less|html|sql|yaml|yml|json|toml|xml)$/ {print}'
  fi
}

file_kind() {
  local f="$1"
  case "$f" in
    *test*|*spec*|tests/*|*/tests/*|*/__tests__/*) echo "test" ;;
    *controller*|*handler*|*route*|*api*|*server*) echo "api" ;;
    scripts/*|*.sh|*.bash|*.zsh) echo "cli" ;;
    *.md|*.mdx) echo "doc" ;;
    *service*) echo "service" ;;
    *store*|*hook*|*composable*) echo "state" ;;
    *component*|*.vue|*.tsx|*.jsx|*.svelte) echo "ui" ;;
    *config*|*.config.*|package.json|pnpm-lock.yaml|yarn.lock|pom.xml|go.mod|Cargo.toml) echo "config" ;;
    *) echo "code" ;;
  esac
}

module_name() {
  local f="$1"
  if [[ "$f" == */* ]]; then
    echo "$f" | awk -F/ '{print $1 "/" $2}'
  else
    echo "."
  fi
}

extract_symbols() {
  local f="$1"
  local abs="${ROOT}/${f}"
  [[ -f "$abs" ]] || return 0
  perl -ne '
    BEGIN { $file = shift @ARGV; }
    sub emit {
      my ($name, $type, $why) = @_;
      $name =~ s/\|/\//g;
      print "| $name | $type | $file | $. | $why |\n";
    }
    emit($3, "function", "function declaration") if /^\s*(export\s+)?(async\s+)?function\s+([A-Za-z_\$][A-Za-z0-9_\$]*)/;
    emit($3, "function", "arrow function") if /^\s*(export\s+)?(const|let|var)\s+([A-Za-z_\$][A-Za-z0-9_\$]*)\s*=\s*(async\s+)?(\([^)]*\)|[A-Za-z_\$][A-Za-z0-9_\$]*)\s*=>/;
    emit($3, $2, "declaration") if /^\s*(export\s+)?(class|interface|type|enum)\s+([A-Za-z_\$][A-Za-z0-9_\$]*)/;
    emit($2, $1, "python declaration") if /^\s*(def|class)\s+([A-Za-z_][A-Za-z0-9_]*)/;
    emit($2, "function", "go declaration") if /^\s*func\s+([A-Za-z_][A-Za-z0-9_]*)/;
    emit($1, "shell function", "shell declaration") if /^\s*([A-Za-z_][A-Za-z0-9_]*)\s*\(\)\s*\{/;
    emit($1, "heading", "markdown section") if /^#{1,6}\s+(.+)/;
  ' "$f" "$abs" 2>/dev/null || true
}

extract_routes() {
  local f="$1"
  local abs="${ROOT}/${f}"
  [[ -f "$abs" ]] || return 0
  awk -v file="$f" '
    function emit(method,path){gsub(/["'\''`]/, "", path); print "| " method " | " path " | " file " | " NR " | route candidate |"}
    match($0, /\.(get|post|put|patch|delete|options)[ \t]*\([ \t]*(["'\''`][^"'\''`]+["'\''`])/, m) {emit(toupper(m[1]), m[2])}
    match($0, /(GET|POST|PUT|PATCH|DELETE|OPTIONS)[ \t]+(["'\''`\/][^"'\''` ]+)/, m) {emit(m[1], m[2])}
    match($0, /@(Get|Post|Put|Patch|Delete|Controller)[ \t]*\([ \t]*(["'\''`][^"'\''`]*["'\''`])/, m) {emit(toupper(m[1]), m[2])}
    match($0, /(path|url|route):[ \t]*(["'\''`][^"'\''`]+["'\''`])/, m) {emit("ANY", m[2])}
  ' "$abs" 2>/dev/null || true
}

extract_imports() {
  local f="$1"
  local abs="${ROOT}/${f}"
  [[ -f "$abs" ]] || return 0
  awk -v file="$f" '
    match($0, /^[ \t]*import .* from [\"'\''`]([^\"'\''`]+)[\"'\''`]/, m) {print "| " file " | " m[1] " | import |"}
    match($0, /^[ \t]*import [\"'\''`]([^\"'\''`]+)[\"'\''`]/, m) {print "| " file " | " m[1] " | side-effect import |"}
    match($0, /require\([\"'\''`]([^\"'\''`]+)[\"'\''`]\)/, m) {print "| " file " | " m[1] " | require |"}
    match($0, /^[ \t]*from ([A-Za-z0-9_\.]+) import /, m) {print "| " file " | " m[1] " | python import |"}
  ' "$abs" 2>/dev/null || true
}

case "$CMD" in
  init)
    ensure_code_map
    echo "created/ok: docs/context/CODE_MAP.md"
    ;;
  status)
    ensure_code_map
    echo "== code-map status =="
    [[ -f "$CODE_MAP" ]] && echo "ok  docs/context/CODE_MAP.md"
    if command -v codegraph >/dev/null 2>&1; then
      echo "ok  codegraph: $(command -v codegraph)"
    else
      echo "warn  codegraph unavailable; using built-in CODE_MAP + rg fallback" >&2
    fi
    ;;
  build)
    MAX_FILES=450
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --max-files) MAX_FILES="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    ensure_code_map
    tmp_files="$(mktemp)"
    tmp_dirs="$(mktemp)"
    tmp_entries="$(mktemp)"
    tmp_modules="$(mktemp)"
    tmp_symbols="$(mktemp)"
    tmp_routes="$(mktemp)"
    tmp_tests="$(mktemp)"
    tmp_imports="$(mktemp)"
    list_code_files | head -n "$MAX_FILES" > "$tmp_files"
    file_count="$(wc -l < "$tmp_files" | tr -d ' ')"
    {
      while IFS= read -r f; do
        [[ -n "$f" ]] || continue
        dir="$(dirname "$f")"
        kind="$(file_kind "$f")"
        echo "${dir}|${kind}"
      done < "$tmp_files"
    } | awk -F'|' '
      {key=$1 "|" $2; count[key]++}
      END {for (k in count) {split(k,a,"|"); print "| " a[1] " | " a[2] " | " count[k] " | inferred from file paths |"}}
    ' | sort > "$tmp_dirs"
    {
      echo "| 类型 | 文件 | 说明 |"
      echo "|------|------|------|"
      while IFS= read -r f; do
        case "$f" in
          scripts/aw|scripts/aw-*.sh|package.json|vite.config.*|next.config.*|nuxt.config.*|src/main.*|src/index.*|src/App.*|app/*|pages/*|server.*|src/server.*|main.py|app.py|manage.py|cmd/*/main.go|pom.xml|go.mod|Cargo.toml|README.md|AGENTS.md|CLAUDE.md|agent-workflow/INVOCATION.md|skill/SKILL.md)
            echo "| $(file_kind "$f") | ${f} | entry/config candidate |"
            ;;
        esac
      done < "$tmp_files"
    } > "$tmp_entries"
    {
      while IFS= read -r f; do
        [[ -n "$f" ]] || continue
        mod="$(module_name "$f")"
        kind="$(file_kind "$f")"
        echo "${mod}|${f}|${kind}"
      done < "$tmp_files"
    } | awk -F'|' '
      {
        mod=$1
        if (!(mod in file)) file[mod]=$2
        if (symbols[mod] == "") symbols[mod]=$3; else if (index(symbols[mod], $3)==0) symbols[mod]=symbols[mod] "," $3
        count[mod]++
      }
      END {
        for (m in count) print "| " m " | " file[m] " | " symbols[m] " | 待查询 | 待查询 | " count[m] " files |"
      }
    ' | sort > "$tmp_modules"
    {
      echo "| Symbol | 类型 | 文件 | 行号 | 说明 |"
      echo "|--------|------|------|------|------|"
      while IFS= read -r f; do extract_symbols "$f"; done < "$tmp_files"
    } > "$tmp_symbols"
    symbol_count="$(( $(wc -l < "$tmp_symbols" | tr -d ' ') - 2 ))"
    [[ "$symbol_count" -lt 0 ]] && symbol_count=0
    {
      echo "| 方法 | 路径 | 文件 | 行号 | 说明 |"
      echo "|------|------|------|------|------|"
      while IFS= read -r f; do extract_routes "$f"; done < "$tmp_files"
    } > "$tmp_routes"
    route_count="$(( $(wc -l < "$tmp_routes" | tr -d ' ') - 2 ))"
    [[ "$route_count" -lt 0 ]] && route_count=0
    {
      echo "| 代码文件 / 模块 | 相关测试 | 推断依据 |"
      echo "|-----------------|----------|----------|"
      tests="$(awk '/(^|\/)(test|tests|__tests__|spec)\// || /\.(test|spec)\./ {print}' "$tmp_files")"
      test_count="$(echo "$tests" | awk 'NF' | wc -l | tr -d ' ')"
      while IFS= read -r f; do
        [[ -n "$f" ]] || continue
        base="$(basename "$f" | sed -E 's/\.(test|spec)//; s/\.[^.]+$//')"
        match="$(echo "$tests" | rg -i "$base" 2>/dev/null | head -5 | paste -sd ';' - || true)"
        [[ -n "$match" ]] && echo "| ${f} | ${match} | basename match |"
      done < "$tmp_files"
      [[ "${test_count:-0}" -eq 0 ]] && echo "| 待补充 | 待补充 | no test files detected |"
    } > "$tmp_tests"
    test_count="$(awk 'NR>2 && $2 !~ /待补充/ {c++} END{print c+0}' "$tmp_tests")"
    {
      echo "| 文件 | 依赖 / import | 说明 |"
      echo "|------|---------------|------|"
      while IFS= read -r f; do extract_imports "$f"; done < "$tmp_files"
    } > "$tmp_imports"
    backend="builtin"
    command -v codegraph >/dev/null 2>&1 && backend="codegraph+builtin"
    {
      echo "# CODE_MAP（代码地图）"
      echo ""
      echo "> 读者：AI Agent + 人类工程师。用途是在修改代码前快速定位模块、入口、Symbol、调用/依赖关系和受影响测试，避免无目标全仓扫描。"
      echo "> 生成：\`./scripts/aw code-map build\`。查询：\`./scripts/aw code-map query \"keyword\"\`、\`./scripts/aw code-map impact \"symbol\"\`。"
      echo ""
      echo "## 元数据"
      echo ""
      echo "| 字段 | 内容 |"
      echo "|------|------|"
      echo "| **生成时间** | $(date '+%Y-%m-%d %H:%M:%S') |"
      echo "| **后端** | ${backend} |"
      echo "| **项目根目录** | ${ROOT} |"
      echo "| **文件数** | ${file_count} |"
      echo "| **Symbol 数** | ${symbol_count} |"
      echo "| **路由 / API 数** | ${route_count} |"
      echo "| **测试文件数** | ${test_count} |"
      echo ""
      echo "## 目录概览"
      echo ""
      echo "| 目录 | 类型 | 代码文件数 | 说明 |"
      echo "|------|------|------------|------|"
      cat "$tmp_dirs"
      echo ""
      echo "## 入口文件"
      echo ""
      cat "$tmp_entries"
      echo ""
      echo "## 模块地图"
      echo ""
      echo "| 模块 | 入口 / 关键文件 | 核心 Symbol | 路由 / API | 相关测试 | 说明 |"
      echo "|------|-----------------|-------------|------------|----------|------|"
      cat "$tmp_modules"
      echo ""
      echo "## Symbol 索引"
      echo ""
      cat "$tmp_symbols"
      echo ""
      echo "## 路由 / API 索引"
      echo ""
      cat "$tmp_routes"
      echo ""
      echo "## 测试映射"
      echo ""
      cat "$tmp_tests"
      echo ""
      echo "## 依赖线索"
      echo ""
      cat "$tmp_imports"
      echo ""
      echo "## Token 读取规则"
      echo ""
      echo "- 默认先查 \`CODE_MAP.md\`，再查 \`CODE_CONTEXT_INDEX.md\`，再查 \`FILE_INDEX.md\`，最后才用精准 \`rg\`。"
      echo "- \`CODE_MAP.md\` 是定位索引，不等于授权读取全文。编码前仍必须生成并确认 \`CTX-<AT-T>.md\`。"
      echo "- 查询结果不足时，Agent 需要说明“缺什么信息、准备扩大到哪些文件、为什么”，等待工程师确认。"
      echo "- 禁止为了“了解项目”读取全仓；禁止读取 \`.git\`、\`node_modules\`、\`dist\`、\`build\`、\`coverage\`、\`.next\`、\`.nuxt\`、\`target\`、\`vendor\`、\`tmp\`、\`logs\`。"
    } > "$CODE_MAP"
    rm -f "$tmp_files" "$tmp_dirs" "$tmp_entries" "$tmp_modules" "$tmp_symbols" "$tmp_routes" "$tmp_tests" "$tmp_imports"
    echo "written: $(rel "$CODE_MAP")"
    echo "summary: files=${file_count}, symbols=${symbol_count}, routes=${route_count}, tests=${test_count}, backend=${backend}"
    ;;
  query)
    QUERY="${1:-}"
    [[ -n "$QUERY" ]] || { echo "error: aw code-map query \"symbol or keyword\"" >&2; exit 1; }
    ensure_code_map
    echo "== code-map query: ${QUERY} =="
    if command -v codegraph >/dev/null 2>&1; then
      codegraph search "$QUERY" 2>/dev/null || true
    fi
    rg -n -i --glob '!node_modules/**' --glob '!dist/**' --glob '!build/**' --glob '!.git/**' --glob '!coverage/**' --glob '!target/**' "$QUERY" "$CODE_MAP" "$CODE_INDEX" "${ROOT}/docs/FILE_INDEX.md" 2>/dev/null | head -80 || true
    ;;
  impact)
    QUERY="${1:-}"
    [[ -n "$QUERY" ]] || { echo "error: aw code-map impact \"symbol or keyword\"" >&2; exit 1; }
    ensure_code_map
    echo "== code-map impact: ${QUERY} =="
    if command -v codegraph >/dev/null 2>&1; then
      codegraph callers "$QUERY" 2>/dev/null || true
      codegraph callees "$QUERY" 2>/dev/null || true
      codegraph impact "$QUERY" 2>/dev/null || true
    else
      echo "warn  codegraph unavailable; using CODE_MAP import/test/route clues" >&2
    fi
    rg -n -i --glob '!node_modules/**' --glob '!dist/**' --glob '!build/**' --glob '!.git/**' --glob '!coverage/**' --glob '!target/**' "$QUERY" "$CODE_MAP" 2>/dev/null | head -120 || true
    ;;
  affected)
    exec "${SCRIPT_DIR}/aw-context.sh" affected "$@"
    ;;
  gate)
    ensure_code_map
    err=0
    [[ -f "$CODE_MAP" ]] || { echo "block: missing docs/context/CODE_MAP.md; run aw code-map build" >&2; err=1; }
    if grep -q '待生成' "$CODE_MAP" 2>/dev/null; then
      echo "block: CODE_MAP.md is template-only; run aw code-map build" >&2
      err=1
    fi
    if [[ "${1:-}" == "--task" ]]; then
      "${SCRIPT_DIR}/aw-context.sh" gate --task "${2:-}" || err=1
    fi
    [[ "$err" -eq 0 ]] && echo "code-map gate: ok" || exit "$err"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
