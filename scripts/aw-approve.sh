#!/usr/bin/env bash
# Set DSL → 已审 or Plan → 可执行 in metadata table.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
KIND=""
TARGET=""
REQ_LINK=""
NEXT_PLAN=false
PLAN_DOMAIN=""

usage() {
  echo "Usage: aw approve dsl <dsl.md> [--req REQ-YYYYMMDD-NN] [--plan] [--domain frontend|backend|fullstack|qa|docs|ops|data]" >&2
  echo "       aw approve plan <plan.md>" >&2
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
    dsl|plan) KIND="$1"; shift ;;
    --req) REQ_LINK="${2:-}"; shift 2 ;;
    --plan) NEXT_PLAN=true; shift ;;
    --domain) PLAN_DOMAIN="$(normalize_domain "${2:-}")" || exit 1; shift 2 ;;
    --frontend|--front-end) PLAN_DOMAIN="Frontend"; shift ;;
    --backend|--back-end) PLAN_DOMAIN="Backend"; shift ;;
    --fullstack) PLAN_DOMAIN="Fullstack"; shift ;;
    -h|--help) usage ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      [[ -z "$TARGET" ]] && TARGET="$1" || {
        echo "error: unexpected argument: $1" >&2
        exit 1
      }
      shift
      ;;
  esac
done

[[ -n "$KIND" && -n "$TARGET" ]] || usage

resolve_path() {
  local p="$1"
  [[ -z "$p" ]] && return 1
  if [[ -d "${ROOT}/${p}" && -f "${ROOT}/${p}/INDEX.md" ]]; then
    echo "${ROOT}/${p}/INDEX.md"
    return 0
  fi
  if [[ -f "${ROOT}/${p}" ]]; then
    echo "${ROOT}/${p}"
    return 0
  fi
  if [[ -f "$p" ]]; then
    echo "$p"
    return 0
  fi
  if [[ -d "$p" && -f "$p/INDEX.md" ]]; then
    echo "$p/INDEX.md"
    return 0
  fi
  return 1
}

FULL="$(resolve_path "$TARGET")" || {
  echo "error: file not found: $TARGET" >&2
  exit 1
}

aw_set_metadata_field() {
  local file="$1" label="$2" value="$3"
  local tmp
  tmp="$(mktemp)"
  awk -v lbl="$label" -v val="$value" '
    index($0, "| **" lbl "** |") > 0 {
      print "| **" lbl "** | " val " |"
      next
    }
    { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

rel="${FULL#${ROOT}/}"

case "$KIND" in
  dsl)
    aw_set_metadata_field "$FULL" "状态" "已审"
    if [[ -n "$REQ_LINK" ]]; then
      req_file=""
      if [[ -f "${ROOT}/docs/requirements/${REQ_LINK}" ]]; then
        req_file="${ROOT}/docs/requirements/${REQ_LINK}"
      elif [[ -f "${ROOT}/docs/requirements/${REQ_LINK}.md" ]]; then
        req_file="${ROOT}/docs/requirements/${REQ_LINK}.md"
      else
        shopt -s nullglob
        matches=("${ROOT}/docs/requirements/${REQ_LINK}"*.md)
        shopt -u nullglob
        if [[ ${#matches[@]} -eq 1 ]]; then
          req_file="${matches[0]}"
        elif [[ ${#matches[@]} -gt 1 ]]; then
          echo "warn: multiple REQ match ${REQ_LINK}* — use full filename" >&2
        fi
      fi
      if [[ -n "$req_file" && -f "$req_file" ]]; then
        aw_set_metadata_field "$FULL" "关联 REQ" "docs/requirements/$(basename "$req_file")"
      else
        echo "warn: REQ not found: $REQ_LINK" >&2
      fi
    fi
    echo "${rel}" > "${ROOT}/docs/.aw-active-dsl"
    echo "ok: DSL 状态 → 已审 (${rel})"
    if $NEXT_PLAN; then
      aw_require_planning_intake_ready
      if [[ -n "$PLAN_DOMAIN" ]]; then
        "${SCRIPT_DIR}/draft-plan.sh" "${rel}" --domain "$PLAN_DOMAIN"
      else
        "${SCRIPT_DIR}/draft-plan.sh" "${rel}"
      fi
    else
      echo "next: ./scripts/aw plan ${rel}"
    fi
    ;;
  plan)
    aw_set_metadata_field "$FULL" "状态" "可执行"
    echo "ok: Plan 状态 → 可执行 (${rel})"
    dsl_active=""
    [[ -f "${ROOT}/docs/.aw-active-dsl" ]] && dsl_active="$(tr -d '[:space:]' < "${ROOT}/docs/.aw-active-dsl")"
    if [[ -n "$dsl_active" ]]; then
      echo "next: ./scripts/aw confirm ${dsl_active} ${rel}"
    else
      echo "next: ./scripts/aw confirm docs/dsl/<已审>.md ${rel}"
    fi
    ;;
  *)
    usage
    ;;
esac
