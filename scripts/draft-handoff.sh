#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"
FOCUS=""
MODE="print"

usage() {
  cat <<'EOF'
Usage:
  aw handoff [focus]
  aw handoff [focus] --write
  aw handoff --check

Options:
  --write   Write reviewed handoff draft to docs/handoff/PROJECT_HANDOFF.md with a timestamped backup.
  --check   Validate docs/handoff/PROJECT_HANDOFF.md for required sections and risky content.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --write)
      MODE="write"
      shift
      ;;
    --check)
      MODE="check"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [[ -n "$FOCUS" ]]; then
        FOCUS="${FOCUS} $1"
      else
        FOCUS="$1"
      fi
      shift
      ;;
  esac
done

rel_or_dash() {
  local p="$1"
  [[ -n "$p" ]] && echo "$p" || echo "—"
}

status_or_dash() {
  local rel="$1"
  [[ -n "$rel" && -f "${ROOT}/${rel}" ]] && aw_read_metadata_status "${ROOT}/${rel}" || echo "—"
}

project_field_or_dash() {
  local field="$1" value
  value="$(aw_project_config_field "$field" 2>/dev/null || true)"
  [[ -n "$value" && "$value" != *"____"* ]] && echo "$value" || echo "—"
}

dsl="$(aw_resolve_dsl_file 2>/dev/null || true)"
plan="$(aw_resolve_plan_file 2>/dev/null || true)"
atomic="$(aw_resolve_atomic_tasks_file "$plan" 2>/dev/null || true)"
dsl_status="$(status_or_dash "$dsl")"
plan_status="$(status_or_dash "$plan")"

confirmed="—"
wf="$(aw_workflow_json_path)"
if [[ -f "$wf" ]]; then
  confirmed="$(grep -E '"confirmed_at"' "$wf" 2>/dev/null | sed -E 's/.*"confirmed_at"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' | head -1 || true)"
fi
[[ -n "$confirmed" ]] || confirmed="—"

current_task="—"
if [[ -f "$wf" ]]; then
  current_task="$(grep -E '"current_task_id"' "$wf" 2>/dev/null | sed -E 's/.*"current_task_id"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' | head -1 || true)"
fi
[[ -n "$current_task" ]] || current_task="—"

next_task="—"
if [[ -n "$atomic" && -f "${ROOT}/${atomic}" ]]; then
  next_row="$(aw_task_find_next "${ROOT}/${atomic}" 2>/dev/null || true)"
  if [[ -n "$next_row" ]]; then
    IFS=$'\t' read -r next_id next_domain next_title next_status next_deps next_verify <<< "$next_row"
    next_task="${next_id} [${next_status}] ${next_title}"
  fi
fi

req_lines="无"
if [[ -f "${ROOT}/docs/requirements/INDEX.md" ]]; then
  req_lines="$(grep -E '^\| REQ-|^\| `?REQ-' "${ROOT}/docs/requirements/INDEX.md" 2>/dev/null | tail -5 || true)"
  [[ -n "$req_lines" ]] || req_lines="见 docs/requirements/INDEX.md"
fi

bug_lines="无"
if [[ -f "${ROOT}/docs/handoff/AI_BUG_LOG.md" ]]; then
  bug_lines="$(grep -E '^\| BUG-' "${ROOT}/docs/handoff/AI_BUG_LOG.md" 2>/dev/null | tail -5 || true)"
  [[ -n "$bug_lines" ]] || bug_lines="见 docs/handoff/AI_BUG_LOG.md"
fi

git_head="—"
git_branch="—"
if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch="$(git -C "$ROOT" branch --show-current 2>/dev/null || true)"
  git_head="$(git -C "$ROOT" log -1 --pretty='%h %s' 2>/dev/null || true)"
  [[ -n "$git_branch" ]] || git_branch="detached"
  [[ -n "$git_head" ]] || git_head="—"
fi

project_kind="$(project_field_or_dash "项目类型")"
build_target="$(project_field_or_dash "构建目标")"
github_url="$(project_field_or_dash "GitHub 仓库地址")"
lint_cmd="$(aw_parse_project_config_cmd lint 2>/dev/null || true)"
test_cmd="$(aw_parse_project_config_cmd test 2>/dev/null || true)"
build_cmd="$(aw_parse_project_config_cmd build 2>/dev/null || true)"
[[ -n "$lint_cmd" ]] || lint_cmd="—"
[[ -n "$test_cmd" ]] || test_cmd="—"
[[ -n "$build_cmd" ]] || build_cmd="—"

generate_handoff() {
  cat <<EOF
# PROJECT_HANDOFF

## 当前目标

${FOCUS:-（填写）}

## 当前状态

| 项 | 值 |
|----|----|
| DSL | $(rel_or_dash "$dsl") [${dsl_status}] |
| Plan | $(rel_or_dash "$plan") [${plan_status}] |
| ATOMIC | $(rel_or_dash "$atomic") |
| Confirm | ${confirmed} |
| Current task | ${current_task} |
| Next task | ${next_task} |

## 项目配置

| 项 | 值 |
|----|----|
| 项目类型 | ${project_kind} |
| 构建目标 | ${build_target} |
| GitHub 仓库地址 | ${github_url} |
| Git branch | ${git_branch} |
| Git HEAD | ${git_head} |

## 验证命令

- lint: ${lint_cmd}
- test: ${test_cmd}
- build: ${build_cmd}

## 近期 REQ（最近 5 条）

$(printf '%s\n' "$req_lines")

## 近期 Bug / 测试失败（最近 5 条）

$(printf '%s\n' "$bug_lines")

## 下一步（1～3 条）

1. ${next_task}
2. （填写）

## 风险 / 待确认

- （填写）

## 新会话启动

新开窗口时先读：
1. agent-workflow/INVOCATION.md
2. docs/handoff/PROJECT_HANDOFF.md
3. docs/requirements/INDEX.md

勿读：ENGINEERING_INDEX.md。

## 维护说明

- 本文件用于短期上下文压缩，只保留当前目标、状态、阻塞和下一步。
- 长期可复用结论请用 \`aw memory add ...\` 单独写入 docs/memory/。
- 生成后请人工删掉无关行，并覆盖保存到 docs/handoff/PROJECT_HANDOFF.md。

---
生成: $(date -u +"%Y-%m-%dT%H:%M:%SZ") · 仓库: ${ROOT}
EOF
}

check_handoff() {
  local file="${ROOT}/docs/handoff/PROJECT_HANDOFF.md"
  local err=0

  if [[ ! -f "$file" ]]; then
    echo "fail: missing docs/handoff/PROJECT_HANDOFF.md" >&2
    return 1
  fi

  for needle in \
    "# PROJECT_HANDOFF" \
    "## 当前目标" \
    "## 当前状态" \
    "## 下一步" \
    "## 风险 / 待确认" \
    "## 新会话启动"; do
    if grep -qF "$needle" "$file"; then
      echo "ok  handoff contains: ${needle}"
    else
      echo "fail: handoff missing: ${needle}" >&2
      err=1
    fi
  done

  if grep -qF "ENGINEERING_INDEX.md" "$file"; then
    if grep -qF "勿读：ENGINEERING_INDEX.md" "$file"; then
      echo "ok  ENGINEERING_INDEX.md only appears as do-not-read guidance"
    else
      echo "fail: handoff should not include ENGINEERING_INDEX.md content" >&2
      err=1
    fi
  fi

  if grep -Eiq '(api[_-]?key|secret|token|password|passwd)[[:space:]]*[:=][[:space:]]*[^[:space:]`<]+' "$file"; then
    echo "fail: possible secret-like content in handoff" >&2
    err=1
  else
    echo "ok  no obvious secret-like key/value content"
  fi

  local bytes
  bytes="$(wc -c < "$file" | tr -d '[:space:]')"
  if [[ "$bytes" -gt 12000 ]]; then
    echo "warn handoff is large (${bytes} bytes); move durable detail to REQ/ADR/Memory and keep links"
  else
    echo "ok  handoff size (${bytes} bytes)"
  fi

  return "$err"
}

case "$MODE" in
  print)
    generate_handoff
    ;;
  write)
    out="${ROOT}/docs/handoff/PROJECT_HANDOFF.md"
    mkdir -p "$(dirname "$out")"
    if [[ -s "$out" ]]; then
      backup="${out}.bak.$(date -u +"%Y%m%dT%H%M%SZ")"
      cp "$out" "$backup"
      echo "backup: ${backup}" >&2
    fi
    generate_handoff > "$out"
    echo "written: docs/handoff/PROJECT_HANDOFF.md" >&2
    check_handoff
    ;;
  check)
    check_handoff
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
