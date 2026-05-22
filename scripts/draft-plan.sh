#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
DSL_FILE=""
DOMAIN=""

usage() {
  cat <<'EOF' >&2
Usage: aw plan <path-to-dsl.md> [--domain frontend|backend|fullstack|qa|docs|ops|data]
Example: aw plan docs/dsl/DSL_DRAFT.md --domain frontend
EOF
  exit 1
}

normalize_domain() {
  local d="$1"
  d="$(echo "$d" | tr '[:upper:]' '[:lower:]')"
  case "$d" in
    frontend|front|fe|前端) echo "Frontend" ;;
    backend|back|be|api|server|后端) echo "Backend" ;;
    fullstack|full-stack|全栈) echo "Fullstack" ;;
    qa|test|testing|测试) echo "QA" ;;
    docs|doc|documentation|文档) echo "Docs" ;;
    ops|devops|infra|运维) echo "Ops" ;;
    data|数据) echo "Data" ;;
    ""|all|any|全部) echo "" ;;
    *) echo "error: unknown domain: $1" >&2; return 1 ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --domain)
      DOMAIN="$(normalize_domain "${2:-}")" || exit 1
      shift 2
      ;;
    --frontend|--front-end)
      DOMAIN="Frontend"
      shift
      ;;
    --backend|--back-end)
      DOMAIN="Backend"
      shift
      ;;
    --fullstack)
      DOMAIN="Fullstack"
      shift
      ;;
    -h|--help)
      usage
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      [[ -z "$DSL_FILE" ]] || { echo "error: unexpected argument: $1" >&2; exit 1; }
      DSL_FILE="$1"
      shift
      ;;
  esac
done

if [[ -z "$DSL_FILE" ]]; then
  usage
fi

if [[ -d "${ROOT}/${DSL_FILE}" && -f "${ROOT}/${DSL_FILE}/INDEX.md" ]]; then
  DSL_FILE="${DSL_FILE%/}/INDEX.md"
elif [[ -d "$DSL_FILE" && -f "$DSL_FILE/INDEX.md" ]]; then
  DSL_FILE="${DSL_FILE%/}/INDEX.md"
fi

if [[ ! -f "${ROOT}/${DSL_FILE}" ]] && [[ ! -f "$DSL_FILE" ]]; then
  echo "error: DSL file not found: $DSL_FILE" >&2
  exit 1
fi

FULL="${DSL_FILE}"
[[ -f "${ROOT}/${DSL_FILE}" ]] && FULL="${ROOT}/${DSL_FILE}"

if ! grep -qE '已审' "$FULL" 2>/dev/null; then
  echo "warning: DSL may not be reviewed (expected 状态 = 已审 in metadata)" >&2
fi

aw_warn_github_url_before_planning
aw_warn_project_stage_before_planning
aw_warn_build_target_before_planning

PROMPT_FILE="${TEMPLATES}/prompts/PROMPT-PLAN.md"
PROJECT_STAGE="$(aw_project_stage)"
BUILD_TARGET="$(aw_build_target)"
BUILD_TARGET_LABEL="$(aw_build_target_label "$BUILD_TARGET")"

echo "=============================================="
echo " Plan draft prompt"
echo " DSL: ${FULL}"
[[ -n "$DOMAIN" ]] && echo " Domain: ${DOMAIN}"
[[ -n "$PROJECT_STAGE" ]] && echo " Project stage: ${PROJECT_STAGE}"
[[ -n "$BUILD_TARGET_LABEL" ]] && echo " Build target: ${BUILD_TARGET_LABEL}"
echo "=============================================="
echo ""
echo "Attach:"
echo "  @${DSL_FILE}"
if [[ "$(basename "$DSL_FILE")" == "INDEX.md" && "$DSL_FILE" == docs/dsl/DSL_*/* ]]; then
  DSL_DIR_REL="$(dirname "$DSL_FILE")"
  echo "  @${DSL_DIR_REL}/00-requirements.md"
  echo "  @${DSL_DIR_REL}/10-pages.md"
  echo "  @${DSL_DIR_REL}/20-interactions.md"
  echo "  @${DSL_DIR_REL}/30-events.md"
  echo "  @${DSL_DIR_REL}/40-boundaries.md"
  echo "  @${DSL_DIR_REL}/90-acceptance.md"
fi
echo "  @docs/plans/_TEMPLATE_PLAN.md"
echo "  @docs/plans/_TEMPLATE_ATOMIC_TASKS.md"
echo "  @docs/requirements/ (linked REQ)"
echo "  @docs/PROJECT_CONFIG.md"
echo ""
echo "--- PROMPT ---"
echo ""

awk '/^```text$/,/^```$/' "${PROMPT_FILE}" | sed '1d;$d'

if [[ -n "$DOMAIN" ]]; then
  cat <<EOF

【本次定向拆解】
- 只生成 ${DOMAIN} 研发计划与 ${DOMAIN} AT-T* 原子任务。
- ATOMIC_TASKS_<slug>.md 中的「领域」列只能使用 ${DOMAIN}，除非某项验收必须跨端贯通且人类明确要求全栈。
- DSL 中属于其他领域的内容只写入 Plan 的「依赖 / 边界 / 交接」章节，不生成其他领域 AT-T*。
- 如发现 ${DOMAIN} 任务无法独立完成，必须在 Plan 风险中列出阻塞依赖，而不是擅自生成其他领域任务。
EOF
fi

cat <<EOF

【项目阶段】
EOF
case "$PROJECT_STAGE" in
  new)
    cat <<'EOF'
- 当前项目阶段：全新项目。Plan 应从已审 DSL 拆出完整研发任务。
EOF
    ;;
  existing)
    cat <<'EOF'
- 当前项目阶段：已有 / 存量项目。Plan 只能拆本次新增 / 变更 / 修复 / 联调任务，不得把一期已完成能力重新拆为待开发。
- 每个 AT-T 必须写清受影响文件候选、不可改动边界、验证命令和回滚风险。
EOF
    ;;
  *)
    cat <<'EOF'
- 当前项目阶段未配置。生成 Plan 前必须先让工程师选择：1=全新项目，2=已有 / 存量项目。
EOF
    ;;
esac

if [[ -n "$BUILD_TARGET_LABEL" ]]; then
  cat <<EOF

【构建目标】
- 本轮工程构建目标：${BUILD_TARGET_LABEL}。
- 若目标为 Frontend：只生成前端研发计划和 Frontend AT-T；后端/API 只写依赖、Mock、契约或阻塞说明。
- 若目标为 Backend：只生成后端研发计划和 Backend AT-T；前端/UI 只写依赖、接口契约或阻塞说明。
- 若目标为 Fullstack：可生成 Frontend / Backend / Fullstack AT-T，但必须写清前后端边界、接口契约、联调顺序和验收方式。
EOF
fi

echo ""
echo "--- END PROMPT ---"
echo ""
echo "L2 write block: ./scripts/aw paste plan-write"
