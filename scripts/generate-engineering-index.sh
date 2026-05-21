#!/usr/bin/env bash
# Generate ENGINEERING_INDEX.md from repo scan + task confirmation metadata.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"

# [[ -n "$var" ]] breaks when var contains '|' (table rows); use length test.
has_text() { [ "${#1}" -gt 0 ]; }
HEADER="${TEMPLATES}/ENGINEERING_INDEX.header.md"
OUT="${ROOT}/ENGINEERING_INDEX.md"
STATE="${ROOT}/docs/.aw-task-confirmed.json"

DSL_FILE=""
PLAN_FILE=""
MODE="${AW_INDEX_MODE:-scan}"
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --confirm) MODE="confirm" ;;
    --scan-only) MODE="scan" ;;
    --force|-f) ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) POSITIONAL+=("$1") ;;
  esac
  shift
done
DSL_FILE="${POSITIONAL[0]:-}"
PLAN_FILE="${POSITIONAL[1]:-}"

if [[ ! -f "$HEADER" ]]; then
  echo "error: missing template ${HEADER}" >&2
  exit 1
fi

# --- resolve DSL ---
if [[ -z "$DSL_FILE" ]]; then
  if [[ -f "${ROOT}/docs/.aw-active-dsl" ]]; then
    DSL_FILE="$(cat "${ROOT}/docs/.aw-active-dsl")"
  else
    for candidate in "${ROOT}"/docs/dsl/DSL_*.md "${ROOT}"/docs/dsl/*_DRAFT.md; do
      [[ -f "$candidate" ]] || continue
      base="$(basename "$candidate")"
      [[ "$base" == DSL_SPEC_TEMPLATE.md ]] && continue
      [[ "$base" == FRONTEND_PAGE_SPEC_TEMPLATE.md ]] && continue
      DSL_FILE="docs/dsl/${base}"
      break
    done
  fi
fi

if [[ -n "$DSL_FILE" && ! -f "${ROOT}/${DSL_FILE}" && -f "$DSL_FILE" ]]; then
  :
elif [[ -n "$DSL_FILE" && -f "${ROOT}/${DSL_FILE}" ]]; then
  DSL_FILE="${DSL_FILE#${ROOT}/}"
fi

read_metadata_status() {
  local file="$1"
  [[ -f "$file" ]] || { echo "—"; return; }
  local line
  line="$(grep -E '^\|[[:space:]]*\*?\*?状态\*?\*?[[:space:]]*\|' "$file" 2>/dev/null | head -1 || true)"
  [[ -n "$line" ]] || { echo "（未解析）"; return; }
  if echo "$line" | grep -q '已审'; then echo "已审"
  elif echo "$line" | grep -q '可执行'; then echo "可执行"
  elif echo "$line" | grep -q '草稿'; then echo "草稿"
  else echo "（未解析）"; fi
}

DSL_STATUS="—"
if [[ -n "$DSL_FILE" && -f "${ROOT}/${DSL_FILE}" ]]; then
  DSL_STATUS="$(read_metadata_status "${ROOT}/${DSL_FILE}")"
fi

# --- resolve Plan from DSL or glob ---
if [[ -z "$PLAN_FILE" && -n "$DSL_FILE" && -f "${ROOT}/${DSL_FILE}" ]]; then
  PLAN_FILE="$(grep -E '^\|[^|]*关联 Plan[^|]*\|' "${ROOT}/${DSL_FILE}" 2>/dev/null | head -1 | sed -E 's/^\|[^|]*\|[^|]*`?([^`| ]+)`?.*/\1/' || true)"
fi
if [[ -z "$PLAN_FILE" ]]; then
  for p in "${ROOT}"/docs/plans/PLAN_*.md; do
    [[ -f "$p" ]] || continue
    PLAN_FILE="docs/plans/$(basename "$p")"
    break
  done
fi
PLAN_STATUS="—"
if [[ -n "$PLAN_FILE" && -f "${ROOT}/${PLAN_FILE}" ]]; then
  PLAN_STATUS="$(read_metadata_status "${ROOT}/${PLAN_FILE}")"
fi

row_if_exists() {
  local label="$1" relpath="$2"
  if [[ -f "${ROOT}/${relpath}" ]]; then
    printf '| **%s** | [`%s`](./%s) |\n' "$label" "$relpath" "$relpath"
  else
    printf '| **%s** | _（尚未创建）_ |\n' "$label"
  fi
}

emit_glob_rows() {
  local dir="$1" pattern="$2" label_fn="$3"
  local f base
  shopt -s nullglob
  for f in "${ROOT}/${dir}"/${pattern}; do
    [[ -f "$f" ]] || continue
    base="$(basename "$f")"
    case "$base" in
      README.md|_TEMPLATE*|INDEX.md) continue ;;
    esac
    printf '| %s | [`%s/%s`](./%s/%s) |\n' "$("$label_fn" "$base")" "$dir" "$base" "$dir" "$base"
  done
  shopt -u nullglob
}

dsl_label() { echo "DSL · ${1%.md}"; }
plan_label() { echo "Plan · ${1%.md}"; }
req_label() { echo "REQ · ${1%.md}"; }
tp_label() { echo "TP · ${1%.md}"; }

DSL_ROWS="$(emit_glob_rows "docs/dsl" "*.md" dsl_label)"
has_text "$DSL_ROWS" || DSL_ROWS='| _（尚无 DSL 文件）_ | — |'

PLAN_ROWS="$(emit_glob_rows "docs/plans" "*.md" plan_label)"
has_text "$PLAN_ROWS" || PLAN_ROWS='| _（尚无 Plan 文件）_ | — |'

REQ_ROWS=""
if [[ -f "${ROOT}/docs/requirements/INDEX.md" ]]; then
  REQ_ROWS="$(awk -F'|' '
    /^\| \[REQ-/ {
      link=$2; title=$3;
      gsub(/^[ \t]+|[ \t]+$/, "", link);
      gsub(/^[ \t]+|[ \t]+$/, "", title);
      file=link;
      sub(/^.*\]\(\.\//, "", file);
      sub(/\).*$/, "", file);
      if (file != "" && file != link)
        printf "| %s | [`docs/requirements/%s`](./docs/requirements/%s) |\n", title, file, file
    }
  ' "${ROOT}/docs/requirements/INDEX.md" 2>/dev/null || true)"
fi
if ! has_text "$REQ_ROWS"; then
  REQ_ROWS="$(emit_glob_rows "docs/requirements" "REQ-*.md" req_label)"
fi
has_text "$REQ_ROWS" || REQ_ROWS='| _（尚无 REQ）_ | — |'

TP_ROWS="$(emit_glob_rows "docs/quality/test-plans" "TP-*.md" tp_label)"
has_text "$TP_ROWS" || TP_ROWS='| _（尚无 TP）_ | — |'

CI_ROWS=""
append_ci() {
  local label="$1" path="$2"
  if [[ -f "${ROOT}/${path}" ]]; then
    CI_ROWS+="$(printf '| **%s** | [`%s`](./%s) |\n' "$label" "$path" "$path")"
  fi
}
append_ci "GitHub Actions" ".github/workflows/ci.yml"
append_ci "pre-commit 校验" "scripts/pre-commit-verify.sh"
append_ci "提交门禁" "scripts/commit-gate.sh"
append_ci "安全提交" "scripts/git-safe-commit.sh"
append_ci "REQ 索引校验" "scripts/check-req-index.sh"
append_ci "TP 索引校验" "scripts/check-test-plan-index.sh"
append_ci "安装 Git Hooks" "scripts/install-git-hooks.sh"
append_ci "同步 Cursor skill" "scripts/sync-skill.sh"
has_text "$CI_ROWS" || CI_ROWS='| _（CI / 门禁脚本尚未配置）_ | — |'

APP_ROWS=""
append_app() {
  local label="$1" path="$2"
  if [[ -d "${ROOT}/${path}" || -f "${ROOT}/${path}" ]]; then
    APP_ROWS+="$(printf '| **%s** | [`%s/`](./%s/) |\n' "$label" "$path" "$path")"
  fi
}
append_app "前端" "frontend"
append_app "后端" "backend"
append_app "移动端" "mobile"
has_text "$APP_ROWS" || APP_ROWS='_本仓库尚无应用代码目录（仅文档工作流时可忽略）。_'

INDEX_REFRESH_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
TASK_CONFIRMED_AT="—"
SNAPSHOT_KIND="仓库扫描（未任务确认）"

if [[ -f "$STATE" ]]; then
  TASK_CONFIRMED_AT="$(grep -E '"confirmed_at"' "$STATE" 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' | head -1 || true)"
  [[ -z "$TASK_CONFIRMED_AT" || "$TASK_CONFIRMED_AT" == "—" ]] && TASK_CONFIRMED_AT="—"
fi

if [[ "$MODE" == "confirm" ]]; then
  SNAPSHOT_KIND="任务已确认"
  TASK_CONFIRMED_AT="$INDEX_REFRESH_AT"
fi

ROW_README="$(row_if_exists "仓库根说明" "README.md")"
ROW_PROJECT_CONFIG="$(row_if_exists "项目配置" "docs/PROJECT_CONFIG.md")"
ROW_FILE_INDEX="$(row_if_exists "项目文件索引" "docs/FILE_INDEX.md")"
ROW_CHANGELOG="$(row_if_exists "CHANGELOG 入口" "CHANGELOG.md")"
ROW_BUG_ISSUE="$(row_if_exists "GitHub Bug 表单" ".github/ISSUE_TEMPLATE/bug_report.md")"
ROW_PR_TEMPLATE="$(row_if_exists "PR 模板" ".github/pull_request_template.md")"
ROW_REPO_VERSION="$(row_if_exists "REPO_VERSION" "docs/meta/REPO_VERSION")"
ROW_LAST_SNAPSHOT="$(row_if_exists "preCompact 草稿" "docs/handoff/LAST_AUTO_SNAPSHOT.md")"
ROW_PASTE_NEW_CHAT="$(row_if_exists "新开窗口粘贴" "docs/handoff/NEW_CHAT_PASTE_TEMPLATE.md")"
ROW_SECURITY_ROOT="$(row_if_exists "SECURITY 摘要" "SECURITY.md")"

TMP_OUT="$(mktemp)"
trap 'rm -f "$TMP_OUT"' EXIT

while IFS= read -r line || [[ -n "$line" ]]; do
  case "$line" in
    *'{{SNAPSHOT_KIND}}'*) line="${line//\{\{SNAPSHOT_KIND\}\}/$SNAPSHOT_KIND}" ;;
    *'{{INDEX_REFRESH_AT}}'*) line="${line//\{\{INDEX_REFRESH_AT\}\}/$INDEX_REFRESH_AT}" ;;
    *'{{TASK_CONFIRMED_AT}}'*) line="${line//\{\{TASK_CONFIRMED_AT\}\}/$TASK_CONFIRMED_AT}" ;;
    *'{{DSL_FILE}}'*) line="${line//\{\{DSL_FILE\}\}/${DSL_FILE:-—}}" ;;
    *'{{DSL_STATUS}}'*) line="${line//\{\{DSL_STATUS\}\}/$DSL_STATUS}" ;;
    *'{{PLAN_FILE}}'*) line="${line//\{\{PLAN_FILE\}\}/${PLAN_FILE:-—}}" ;;
    *'{{PLAN_STATUS}}'*) line="${line//\{\{PLAN_STATUS\}\}/$PLAN_STATUS}" ;;
    *'{{ROW_README}}'*) line="$ROW_README" ;;
    *'{{ROW_PROJECT_CONFIG}}'*) line="$ROW_PROJECT_CONFIG" ;;
    *'{{ROW_FILE_INDEX}}'*) line="$ROW_FILE_INDEX" ;;
    *'{{ROW_CHANGELOG}}'*) line="$ROW_CHANGELOG" ;;
    *'{{ROW_BUG_ISSUE}}'*) line="$ROW_BUG_ISSUE" ;;
    *'{{ROW_PR_TEMPLATE}}'*) line="$ROW_PR_TEMPLATE" ;;
    *'{{ROW_REPO_VERSION}}'*) line="$ROW_REPO_VERSION" ;;
    *'{{ROW_LAST_SNAPSHOT}}'*) line="$ROW_LAST_SNAPSHOT" ;;
    *'{{ROW_PASTE_NEW_CHAT}}'*) line="$ROW_PASTE_NEW_CHAT" ;;
    *'{{ROW_SECURITY_ROOT}}'*) line="$ROW_SECURITY_ROOT" ;;
    *'{{DSL_ROWS}}'*)
      printf '%s\n' "$line" >> "$TMP_OUT"
      printf '%s\n' "$DSL_ROWS" >> "$TMP_OUT"
      continue
      ;;
    *'{{PLAN_ROWS}}'*)
      printf '%s\n' "$line" >> "$TMP_OUT"
      printf '%s\n' "$PLAN_ROWS" >> "$TMP_OUT"
      continue
      ;;
    *'{{REQ_ROWS}}'*)
      printf '%s\n' "$line" >> "$TMP_OUT"
      printf '%s\n' "$REQ_ROWS" >> "$TMP_OUT"
      continue
      ;;
    *'{{TP_ROWS}}'*)
      printf '%s\n' "$line" >> "$TMP_OUT"
      printf '%s\n' "$TP_ROWS" >> "$TMP_OUT"
      continue
      ;;
    *'{{CI_ROWS}}'*)
      printf '%s\n' "$line" >> "$TMP_OUT"
      printf '%s\n' "$CI_ROWS" >> "$TMP_OUT"
      continue
      ;;
    *'{{APP_ROWS}}'*)
      printf '%s\n' "$line" >> "$TMP_OUT"
      printf '%s\n' "$APP_ROWS" >> "$TMP_OUT"
      continue
      ;;
  esac
  printf '%s\n' "$line" >> "$TMP_OUT"
done < "$HEADER"

mv "$TMP_OUT" "$OUT"

if [[ "$MODE" == "confirm" ]]; then
  mkdir -p "${ROOT}/docs"
  cat > "$STATE" <<EOF
{
  "confirmed_at": "${TASK_CONFIRMED_AT}",
  "dsl_file": "${DSL_FILE:-}",
  "dsl_status": "${DSL_STATUS}",
  "plan_file": "${PLAN_FILE:-}",
  "plan_status": "${PLAN_STATUS}",
  "engineering_index": "ENGINEERING_INDEX.md"
}
EOF
fi

echo "Wrote: ${OUT} (${MODE})"
[[ "$MODE" == "confirm" ]] && echo "State: ${STATE}"
echo "DSL: ${DSL_FILE:-—} (${DSL_STATUS}) · Plan: ${PLAN_FILE:-—} (${PLAN_STATUS})"
