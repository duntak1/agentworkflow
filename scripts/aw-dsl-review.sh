#!/usr/bin/env bash
# Print or write an engineer review package for a DSL file or DSL suite.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

ROOT="$(aw_repo_root)"
TARGET=""
WRITE=false
OUT=""

usage() {
  cat <<'EOF' >&2
Usage:
  aw dsl review [dsl.md|docs/dsl/DSL_<SLUG>/INDEX.md|docs/dsl/DSL_<SLUG>] [--write] [--out REVIEW.md]

Default target: active DSL from docs/.aw-active-dsl, then first DSL in docs/dsl/.
Default output: stdout. Use --write to save REVIEW.md next to the DSL.
EOF
  exit "${1:-1}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --write)
      WRITE=true
      shift
      ;;
    --out)
      OUT="${2:-}"
      [[ -n "$OUT" ]] || usage 1
      shift 2
      ;;
    -h|--help)
      usage 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage 1
      ;;
    *)
      [[ -z "$TARGET" ]] || { echo "error: unexpected argument: $1" >&2; exit 1; }
      TARGET="$1"
      shift
      ;;
  esac
done

resolve_target() {
  local p="${1:-}"
  if [[ -z "$p" ]]; then
    aw_resolve_dsl_file
    return
  fi
  if [[ -f "${ROOT}/${p}" ]]; then
    echo "${p#${ROOT}/}"
    return 0
  fi
  if [[ -d "${ROOT}/${p}" && -f "${ROOT}/${p}/INDEX.md" ]]; then
    echo "${p%/}/INDEX.md"
    return 0
  fi
  if [[ -f "$p" ]]; then
    case "$p" in
      "$ROOT"/*) echo "${p#${ROOT}/}" ;;
      *) echo "$p" ;;
    esac
    return 0
  fi
  if [[ -d "$p" && -f "$p/INDEX.md" ]]; then
    case "$p" in
      "$ROOT"/*) echo "${p#${ROOT}/}/INDEX.md" ;;
      *) echo "${p%/}/INDEX.md" ;;
    esac
    return 0
  fi
  return 1
}

DSL_REL="$(resolve_target "$TARGET")" || {
  echo "error: DSL not found. Run: aw dsl list" >&2
  exit 1
}
DSL_FULL="${ROOT}/${DSL_REL}"
[[ -f "$DSL_FULL" ]] || { echo "error: DSL file not found: ${DSL_REL}" >&2; exit 1; }

DSL_DIR="$(dirname "$DSL_REL")"
DSL_BASE="$(basename "$DSL_REL")"
IS_SUITE=false
if [[ "$DSL_BASE" == "INDEX.md" && "$DSL_DIR" == docs/dsl/DSL_* ]]; then
  IS_SUITE=true
fi

status="$(aw_read_metadata_status "$DSL_FULL")"
name="$(aw_extract_meta_field "$DSL_FULL" "名称" 2>/dev/null || true)"
slug="$(aw_extract_meta_field "$DSL_FULL" "短标识" 2>/dev/null || true)"
req="$(aw_extract_meta_field "$DSL_FULL" "关联 REQ" 2>/dev/null || true)"
plan="$(aw_extract_meta_field "$DSL_FULL" "关联 Plan" 2>/dev/null || true)"
reference="$(aw_extract_meta_field "$DSL_FULL" "关联 Reference" 2>/dev/null || true)"

if [[ -z "$OUT" && "$WRITE" == true ]]; then
  if $IS_SUITE; then
    OUT="${DSL_DIR}/REVIEW.md"
  else
    OUT="docs/dsl/REVIEW_${DSL_BASE%.md}.md"
  fi
fi

suite_files=(
  "00-requirements.md"
  "10-pages.md"
  "20-interactions.md"
  "30-events.md"
  "40-boundaries.md"
  "90-acceptance.md"
)

missing_suite=()
if $IS_SUITE; then
  for part in "${suite_files[@]}"; do
    [[ -f "${ROOT}/${DSL_DIR}/${part}" ]] || missing_suite+=("${part}")
  done
fi

contains_placeholder=false
if $IS_SUITE; then
  grep -Rqi '待填写' "${ROOT}/${DSL_DIR}" 2>/dev/null && contains_placeholder=true
else
  grep -qi '待填写' "$DSL_FULL" 2>/dev/null && contains_placeholder=true
fi

tmp="$(mktemp)"
{
  echo "# DSL Engineer Review — ${name:-${DSL_REL}}"
  echo ""
  echo "## 审阅对象"
  echo ""
  echo "| 字段 | 内容 |"
  echo "|------|------|"
  echo "| DSL | \`${DSL_REL}\` |"
  echo "| 类型 | $($IS_SUITE && echo "多文件 DSL suite" || echo "单文件 DSL") |"
  echo "| 名称 | ${name:-—} |"
  echo "| 短标识 | ${slug:-—} |"
  echo "| 当前状态 | ${status} |"
  echo "| 关联 REQ | ${req:-—} |"
  echo "| 关联 Plan | ${plan:-—} |"
  echo "| 关联 Reference | ${reference:-—} |"
  echo ""

  echo "## 必读文件"
  echo ""
  echo "- \`${DSL_REL}\`"
  if $IS_SUITE; then
    for part in "${suite_files[@]}"; do
      echo "- \`${DSL_DIR}/${part}\`"
    done
  fi
  [[ -n "${req:-}" && "${req}" != "—" ]] && echo "- \`${req}\`"
  [[ -n "${reference:-}" && "${reference}" != "—" ]] && echo "- \`${reference}\`"
  echo ""

  echo "## 审阅结论"
  echo ""
  echo "- [ ] 通过：可作为研发真源，允许进入 Plan。"
  echo "- [ ] 退回：需要补充或修订，原因写入下方「退回意见」。"
  echo ""

  echo "## 检查清单"
  echo ""
  echo "- [ ] 需求描述完整：目标、用户、场景、范围、成功标准清楚。"
  echo "- [ ] 参考来源可追踪：未编造 \`reference/\`、REQ、设计稿或源码路径。"
  echo "- [ ] 页面/模块结构清楚：路由、页面、布局、组件职责可用于拆任务。"
  echo "- [ ] 交互行为清楚：用户动作、状态流转、权限、空态、异常都有定义。"
  echo "- [ ] 事件清楚：触发条件、输入输出、副作用、失败处理、埋点边界明确。"
  echo "- [ ] 联动边界清楚：跨页、跨模块、接口契约、数据同步边界可执行。"
  echo "- [ ] 验收可检查：每条验收能落到命令、TP 用例、手工步骤或可观察结果。"
  echo "- [ ] 非目标明确：Out of Scope / notes / 待确认没有被误当成开发范围。"
  echo "- [ ] 无明显冲突：需求、页面、交互、事件、边界、验收之间互相一致。"
  echo ""

  if $IS_SUITE; then
    echo "## Suite 完整性"
    echo ""
    for part in "${suite_files[@]}"; do
      if [[ -f "${ROOT}/${DSL_DIR}/${part}" ]]; then
        echo "- [x] \`${part}\`"
      else
        echo "- [ ] \`${part}\` 缺失"
      fi
    done
    if [[ ${#missing_suite[@]} -gt 0 ]]; then
      echo ""
      echo "缺失文件：${missing_suite[*]}"
    fi
    echo ""
  fi

  echo "## 自动检查"
  echo ""
  echo "审阅前运行："
  echo ""
  echo '```bash'
  echo "./scripts/aw check dsl"
  echo '```'
  echo ""
  echo "当前状态：\`${status}\`。"
  if $contains_placeholder; then
    echo ""
    echo "提示：DSL 中仍包含 \`待填写\`，通常应退回补全。"
  fi
  echo ""

  echo "## 退回意见"
  echo ""
  echo "- "
  echo ""

  echo "## 通过后命令"
  echo ""
  echo '```bash'
  echo "./scripts/aw approve dsl ${DSL_REL} --plan"
  echo "# 只拆前端任务：./scripts/aw approve dsl ${DSL_REL} --plan --domain frontend"
  echo "# 只拆后端任务：./scripts/aw approve dsl ${DSL_REL} --plan --domain backend"
  echo '```'
  echo ""
  echo "说明：\`--plan\` 会在 DSL 盖章后直接输出 Plan + ATOMIC_TASKS 生成提示；\`--domain\` 可定向只拆 Frontend / Backend / Fullstack / QA / Docs / Ops / Data 任务。写业务代码仍需要 Plan \`可执行\` 且完成 \`aw confirm\`。"
} > "$tmp"

if $WRITE; then
  mkdir -p "$(dirname "${ROOT}/${OUT}")"
  cp "$tmp" "${ROOT}/${OUT}"
  echo "Wrote: ${OUT}"
  aw_refresh_engineering_index
  echo "Next: engineer reviews ${OUT} → ./scripts/aw approve dsl ${DSL_REL} --plan"
else
  cat "$tmp"
fi

rm -f "$tmp"
