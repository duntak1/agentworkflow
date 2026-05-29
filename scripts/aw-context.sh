#!/usr/bin/env bash
# Context Intelligence helper: prevent wasteful full-repo reads by creating task-level context plans.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
CTX_DIR="${ROOT}/docs/context"
TASK_DIR="${CTX_DIR}/tasks"
CONFIG="${CTX_DIR}/CONTEXT_CONFIG.md"
INDEX="${CTX_DIR}/CODE_CONTEXT_INDEX.md"
CODE_MAP="${CTX_DIR}/CODE_MAP.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw context init
  aw context status
  aw context plan --task AT-T... [--max-files 8] [--max-symbols 20]
  aw context enrich --task AT-T...
  aw context query "symbol or keyword"
  aw context impact "symbol or keyword"
  aw context affected [--task AT-T...]
  aw context gate --task AT-T...
  aw context budget --task AT-T... [--max-files 6] [--max-symbols 12] [--max-search 3]
  aw context check
EOF
  exit "${1:-0}"
}

ensure_context() {
  mkdir -p "$CTX_DIR" "$TASK_DIR"
  [[ -f "$CONFIG" ]] || cp "${TEMPLATES}/context/CONTEXT_CONFIG.md" "$CONFIG"
  [[ -f "$CODE_MAP" ]] || cp "${TEMPLATES}/context/CODE_MAP.md" "$CODE_MAP"
  [[ -f "$INDEX" ]] || cp "${TEMPLATES}/context/CODE_CONTEXT_INDEX.md" "$INDEX"
}

ctx_auto_code_map_build() {
  [[ "${AW_CODE_MAP_AUTO:-1}" != "0" ]] || return 0
  [[ -x "${SCRIPT_DIR}/aw-code-map.sh" ]] || return 0
  "${SCRIPT_DIR}/aw-code-map.sh" build --quiet >/dev/null 2>&1 || {
    echo "warn  auto code-map build failed; run ./scripts/aw code-map build" >&2
    return 0
  }
}

ctx_plan_path() {
  local task="$1"
  echo "${TASK_DIR}/CTX-${task}.md"
}

ctx_rel() {
  local path="$1"
  echo "${path#"${ROOT}/"}"
}

ctx_field() {
  local label="$1" fallback="$2"
  local value
  value="$(awk -F'|' -v label="$label" '
    index($0, "**" label "**") > 0 {
      v=$3
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      print v
      exit
    }
  ' "$CONFIG" 2>/dev/null || true)"
  [[ -n "$value" ]] && echo "$value" || echo "$fallback"
}

ctx_codegraph_available() {
  command -v codegraph >/dev/null 2>&1
}

ctx_is_blocked_path() {
  local path="$1" blocked
  blocked="$(ctx_field "Blocked Dirs" ".git,node_modules,dist,build,coverage,.next,.nuxt,target,vendor,tmp,logs")"
  IFS=',' read -ra dirs <<< "$blocked"
  local dir trimmed
  for dir in "${dirs[@]}"; do
    trimmed="$(echo "$dir" | xargs)"
    [[ -z "$trimmed" ]] && continue
    [[ "$path" == "$trimmed" || "$path" == "$trimmed/"* || "$path" == */"$trimmed"/* ]] && return 0
  done
  return 1
}

ctx_candidate_files_for_task() {
  local task="$1" max_files="$2" row title domain query
  row=""
  atomic="$(aw_resolve_atomic_tasks_file 2>/dev/null || true)"
  if [[ -n "${atomic:-}" && -f "${ROOT}/${atomic}" ]]; then
    row="$(aw_task_get_row "${ROOT}/${atomic}" "$task" 2>/dev/null || true)"
  fi
  if [[ -n "$row" ]]; then
    title="$(echo "$row" | awk -F'\t' '{print $3}')"
    domain="$(echo "$row" | awk -F'\t' '{print $2}')"
    query="${task} ${domain} ${title}"
  else
    query="$task"
  fi

  if ctx_codegraph_available; then
    codegraph context "$query" 2>/dev/null | sed -n 's/.*\([^[:space:]]\+\.[A-Za-z0-9][A-Za-z0-9._-]*\).*/\1/p' | head -n "$max_files" || true
  fi

  {
    [[ -f "$CODE_MAP" ]] && awk -F'|' 'NF > 3 {for(i=1;i<=NF;i++){if($i ~ /\//){gsub(/^[ \t`]+|[ \t`]+$/, "", $i); print $i}}}' "$CODE_MAP"
    [[ -f "$INDEX" ]] && awk -F'|' 'NF > 3 {for(i=1;i<=NF;i++){if($i ~ /\//){gsub(/^[ \t`]+|[ \t`]+$/, "", $i); print $i}}}' "$INDEX"
    [[ -f "${ROOT}/docs/FILE_INDEX.md" ]] && awk -F'|' 'NF > 3 {gsub(/^[ \t`]+|[ \t`]+$/, "", $2); if($2 ~ /\//) print $2}' "${ROOT}/docs/FILE_INDEX.md"
  } | while IFS= read -r file; do
    [[ -n "$file" && -f "${ROOT}/${file}" ]] || continue
    ctx_is_blocked_path "$file" && continue
    echo "$file"
  done | awk '!seen[$0]++' | head -n "$max_files"
}

ctx_insert_after_section() {
  local file="$1" section="$2" content_file="$3" tmp
  tmp="$(mktemp)"
  awk -v section="$section" -v insert_file="$content_file" '
    $0 == section && done==0 {
      print
      while ((getline line < insert_file) > 0) print line
      done=1
      next
    }
    {print}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

ctx_task_query() {
  local task="$1" row title domain
  row=""
  atomic="$(aw_resolve_atomic_tasks_file 2>/dev/null || true)"
  if [[ -n "${atomic:-}" && -f "${ROOT}/${atomic}" ]]; then
    row="$(aw_task_get_row "${ROOT}/${atomic}" "$task" 2>/dev/null || true)"
  fi
  if [[ -n "$row" ]]; then
    title="$(echo "$row" | awk -F'\t' '{print $3}')"
    domain="$(echo "$row" | awk -F'\t' '{print $2}')"
    echo "${task} ${domain} ${title}"
  else
    echo "$task"
  fi
}

ctx_allowed_files() {
  local out="$1"
  awk -F'|' '/^\| [^|]+ \| [^|]+ \| (no|yes) \|/ && $2 !~ /文件/ {
    gsub(/^[ \t]+|[ \t]+$/, "", $2)
    if ($2 != "待补充") print $2
  }' "$out"
}

ctx_update_section_table() {
  local file="$1" section="$2" table_file="$3" tmp
  tmp="$(mktemp)"
  awk -v section="$section" -v table="$table_file" '
    $0 == section {
      print
      while ((getline line < table) > 0) print line
      skip=1
      next
    }
    skip && /^## / {skip=0; print; next}
    skip {next}
    {print}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

case "$CMD" in
  init)
    ensure_context
    echo "created/ok: docs/context/"
    ;;
  status)
    ensure_context
    echo "== context status =="
    if ctx_codegraph_available; then
      echo "ok  codegraph: $(command -v codegraph)"
      codegraph status 2>/dev/null || true
    else
      echo "warn  codegraph not installed; fallback: CODE_MAP + CODE_CONTEXT_INDEX + FILE_INDEX + precise rg" >&2
      echo "      run aw code-map build; install/use codegraph when large projects need deeper symbol graph context" >&2
    fi
    [[ -f "$CONFIG" ]] && echo "ok  $(ctx_rel "$CONFIG")"
    [[ -f "$CODE_MAP" ]] && echo "ok  $(ctx_rel "$CODE_MAP")"
    [[ -f "$INDEX" ]] && echo "ok  $(ctx_rel "$INDEX")"
    [[ -f "${ROOT}/docs/FILE_INDEX.md" ]] && echo "ok  docs/FILE_INDEX.md" || echo "warn  docs/FILE_INDEX.md missing; run aw file-index" >&2
    ;;
  plan)
    TASK=""
    MAX_FILES="$(ctx_field "Max Files Per Task" "6" 2>/dev/null || echo 6)"
    MAX_SYMBOLS="$(ctx_field "Max Symbols Per Task" "12" 2>/dev/null || echo 12)"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task) TASK="${2:-}"; shift 2 ;;
        --max-files) MAX_FILES="${2:-}"; shift 2 ;;
        --max-symbols) MAX_SYMBOLS="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$TASK" ]] || { echo "error: --task is required" >&2; exit 1; }
    ensure_context
    ctx_auto_code_map_build
    OUT="$(ctx_plan_path "$TASK")"
    cp "${TEMPLATES}/context/CONTEXT_PLAN_TEMPLATE.md" "$OUT"
    dsl="$(aw_resolve_dsl_file 2>/dev/null || echo "待确认")"
    plan="$(aw_resolve_plan_file 2>/dev/null || echo "待确认")"
    tmp="$(mktemp)"
    {
      echo ""
      echo "| 文件 | 理由 | 是否已读 |"
      echo "|------|------|----------|"
      while IFS= read -r file; do
        [[ -n "$file" ]] || continue
        echo "| ${file} | Context candidate for ${TASK}; confirm before reading | no |"
      done < <(ctx_candidate_files_for_task "$TASK" "$MAX_FILES")
    } > "$tmp"
    python3 - "$OUT" "$TASK" "$dsl" "$plan" "$MAX_FILES" "$MAX_SYMBOLS" "$tmp" <<'PY'
import sys, pathlib
out, task, dsl, plan, max_files, max_symbols, table = sys.argv[1:]
p = pathlib.Path(out)
s = p.read_text()
s = s.replace("# CTX-<AT-T>", f"# CTX-{task}")
s = s.replace("| **Task** | <AT-T> |", f"| **Task** | {task} |")
s = s.replace("| **Related DSL** | 待确认 |", f"| **Related DSL** | {dsl} |")
s = s.replace("| **Related Plan** | 待确认 |", f"| **Related Plan** | {plan} |")
s = s.replace("| Max files | 8 |", f"| Max files | {max_files} |")
s = s.replace("| Max symbols | 20 |", f"| Max symbols | {max_symbols} |")
marker = "## 允许读取文件\n\n| 文件 | 理由 | 是否已读 |\n|------|------|----------|\n| 待补充 | 待补充 | no |"
s = s.replace(marker, "## 允许读取文件\n" + pathlib.Path(table).read_text().rstrip())
p.write_text(s)
PY
    rm -f "$tmp"
    echo "written: $(ctx_rel "$OUT")"
    echo "next: review allowed files, then aw context gate --task ${TASK}"
    ;;
  query)
    QUERY="${1:-}"
    [[ -n "$QUERY" ]] || { echo "error: aw context query \"symbol\"" >&2; exit 1; }
    ensure_context
    echo "== context query: ${QUERY} =="
    if ctx_codegraph_available; then
      codegraph search "$QUERY" 2>/dev/null || true
    fi
    rg -n --glob '!node_modules/**' --glob '!dist/**' --glob '!build/**' --glob '!.git/**' --glob '!coverage/**' --glob '!target/**' "$QUERY" "$ROOT" 2>/dev/null | sed "s#${ROOT}/##" | head -60 || true
    ;;
  impact)
    QUERY="${1:-}"
    [[ -n "$QUERY" ]] || { echo "error: aw context impact \"symbol\"" >&2; exit 1; }
    ensure_context
    echo "== context impact: ${QUERY} =="
    if ctx_codegraph_available; then
      codegraph callers "$QUERY" 2>/dev/null || true
      codegraph callees "$QUERY" 2>/dev/null || true
      codegraph impact "$QUERY" 2>/dev/null || true
    else
      echo "warn  codegraph unavailable; use precise rg results as weak impact signal" >&2
      rg -n --glob '!node_modules/**' --glob '!dist/**' --glob '!build/**' --glob '!.git/**' --glob '!coverage/**' --glob '!target/**' "$QUERY" "$ROOT" 2>/dev/null | sed "s#${ROOT}/##" | head -80 || true
    fi
    ;;
  affected)
    TASK=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task) TASK="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    ensure_context
    echo "== affected analysis =="
    changed="$(git -C "$ROOT" diff --name-only 2>/dev/null || true)"
    staged="$(git -C "$ROOT" diff --cached --name-only 2>/dev/null || true)"
    files="$(printf '%s\n%s\n' "$changed" "$staged" | awk 'NF && !seen[$0]++')"
    if [[ -z "$files" ]]; then
      echo "no changed files"
    else
      echo "$files"
    fi
    tests="$(echo "$files" | awk '
      /(^|\/)(test|tests|__tests__|spec)\// || /\.(test|spec)\./ {print}
      /\.vue$/ {gsub(/src\/views\//, "tests/e2e/"); print}
      /\.ts$/ || /\.js$/ || /\.java$/ {print}
    ' | awk 'NF && !seen[$0]++')"
    [[ -n "$tests" ]] && { echo ""; echo "Suggested affected tests:"; echo "$tests"; }
    if [[ -n "$TASK" ]]; then
      OUT="$(ctx_plan_path "$TASK")"
      if [[ -f "$OUT" ]]; then
        now="$(date '+%Y-%m-%d %H:%M:%S')"
        row="| ${now} | $(echo "$files" | tr '\n' ';' | sed 's/;$//') | $(echo "$tests" | tr '\n' ';' | sed 's/;$//') | aw verify --task ${TASK} | pending |"
        tmp="$(mktemp)"
        awk -v row="$row" '
          /^## Affected Analysis/ {print; insec=1; next}
          insec && /^\|------/ && done==0 {print; print row; done=1; next}
          {print}
        ' "$OUT" > "$tmp"
        mv "$tmp" "$OUT"
        echo ""
        echo "updated: $(ctx_rel "$OUT")"
      fi
    fi
    ;;
  enrich)
    TASK=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task) TASK="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$TASK" ]] || { echo "error: --task is required" >&2; exit 1; }
    ensure_context
    OUT="$(ctx_plan_path "$TASK")"
    [[ -f "$OUT" ]] || "${SCRIPT_DIR}/aw-context.sh" plan --task "$TASK" >/dev/null
    query="$(ctx_task_query "$TASK")"
    tmp_symbols="$(mktemp)"
    tmp_impact="$(mktemp)"
    {
      echo ""
      echo "| Symbol | 类型 | 文件 | 关系 |"
      echo "|--------|------|------|------|"
      if ctx_codegraph_available; then
        codegraph search "$query" 2>/dev/null | head -20 | sed 's/|/ /g' | awk '{print "| " $0 " | codegraph | 待确认 | candidate |"}'
      fi
      rg -n --glob '!node_modules/**' --glob '!dist/**' --glob '!build/**' --glob '!.git/**' --glob '!coverage/**' --glob '!target/**' "$query" "$ROOT" 2>/dev/null \
        | sed "s#${ROOT}/##" | head -20 | awk -F: '{print "| " $3 " | rg | " $1 " | candidate |"}'
    } > "$tmp_symbols"
    {
      echo ""
      echo "| 类型 | 内容 |"
      echo "|------|------|"
      echo "| Query | ${query} |"
      if ctx_codegraph_available; then
        echo "| CodeGraph impact | $(codegraph impact "$query" 2>/dev/null | head -10 | tr '\n' ';' | sed 's/|/ /g') |"
      else
        echo "| CodeGraph | unavailable; fallback to CODE_MAP / CODE_CONTEXT_INDEX / FILE_INDEX / precise rg |"
      fi
      echo "| Affected files | $(ctx_allowed_files "$OUT" | tr '\n' ';' | sed 's/;$//') |"
      echo "| Affected tests | run aw context affected --task ${TASK} after code changes |"
    } > "$tmp_impact"
    ctx_update_section_table "$OUT" "## 相关 Symbol" "$tmp_symbols"
    ctx_update_section_table "$OUT" "## 调用链 / 影响范围" "$tmp_impact"
    rm -f "$tmp_symbols" "$tmp_impact"
    echo "enriched: $(ctx_rel "$OUT")"
    echo "next: review generated symbols/impact, then aw context gate --task ${TASK}"
    ;;
  budget)
    TASK=""
    MAX_FILES=""
    MAX_SYMBOLS=""
    MAX_SEARCH=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task) TASK="${2:-}"; shift 2 ;;
        --max-files) MAX_FILES="${2:-}"; shift 2 ;;
        --max-symbols) MAX_SYMBOLS="${2:-}"; shift 2 ;;
        --max-search) MAX_SEARCH="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$TASK" ]] || { echo "error: --task is required" >&2; exit 1; }
    OUT="$(ctx_plan_path "$TASK")"
    [[ -f "$OUT" ]] || { echo "error: missing context plan: $(ctx_rel "$OUT")" >&2; exit 1; }
    [[ -n "$MAX_FILES" ]] && perl -0pi -e "s/\\| Max files \\| [^|]+ \\|/| Max files | ${MAX_FILES} |/" "$OUT"
    [[ -n "$MAX_SYMBOLS" ]] && perl -0pi -e "s/\\| Max symbols \\| [^|]+ \\|/| Max symbols | ${MAX_SYMBOLS} |/" "$OUT"
    [[ -n "$MAX_SEARCH" ]] && perl -0pi -e "s/\\| Max search queries \\| [^|]+ \\|/| Max search queries | ${MAX_SEARCH} |/" "$OUT"
    echo "updated: $(ctx_rel "$OUT")"
    ;;
  gate)
    TASK=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task) TASK="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$TASK" ]] || { echo "error: --task is required" >&2; exit 1; }
    ensure_context
    OUT="$(ctx_plan_path "$TASK")"
    echo "== context gate: ${TASK} =="
    err=0
    if [[ ! -f "$OUT" ]]; then
      echo "block: missing context plan: $(ctx_rel "$OUT")" >&2
      echo "  run: ./scripts/aw context plan --task ${TASK}" >&2
      exit 1
    fi
    allowed_count="$(awk -F'|' '/^\| [^|]+ \| [^|]+ \| (no|yes) \|/ && $2 !~ /文件/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); if ($2 != "待补充") print $2}' "$OUT" | wc -l | tr -d ' ')"
    max_files="$(awk -F'|' '/\| Max files \|/ {gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit}' "$OUT")"
    [[ -z "$max_files" ]] && max_files=6
    if [[ "$allowed_count" -eq 0 ]]; then
      echo "block: context plan has no allowed files" >&2
      err=1
    elif [[ "$allowed_count" -gt "$max_files" ]]; then
      echo "block: allowed files ${allowed_count} exceeds budget ${max_files}" >&2
      err=1
    else
      echo "ok  allowed files: ${allowed_count}/${max_files}"
    fi
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      if ctx_is_blocked_path "$file"; then
        echo "block: blocked path listed in allowed files: ${file}" >&2
        err=1
      fi
    done < <(awk -F'|' '/^\| [^|]+ \| [^|]+ \| (no|yes) \|/ && $2 !~ /文件/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); if ($2 != "待补充") print $2}' "$OUT")
    if grep -q '待补充' "$OUT"; then
      echo "warn  context plan still has 待补充 placeholders" >&2
    fi
    if [[ "$err" -eq 0 ]]; then
      echo "context gate: ok"
    else
      echo "context gate: failed" >&2
      exit "$err"
    fi
    ;;
  check)
    echo "== context check =="
    err=0
    for f in "$CONFIG" "$INDEX"; do
      if [[ -f "$f" ]]; then
        echo "ok  $(ctx_rel "$f")"
      else
        echo "missing  $(ctx_rel "$f") (run: aw context init)" >&2
        err=1
      fi
    done
    [[ -d "$TASK_DIR" ]] && echo "ok  docs/context/tasks/" || echo "missing  docs/context/tasks/ (run: aw context init)" >&2
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
