#!/usr/bin/env bash
# Service/module catalog helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
CATALOG="${ROOT}/docs/SERVICE_CATALOG.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw service-catalog init
  aw service-catalog add "name" --owner "..." --type frontend|backend|fullstack|job|lib --responsibility "..." [--entry "..."] [--verify "..."] [--related "..."]
  aw service-catalog discover [--write]
  aw service-catalog check
  aw service-catalog path
EOF
  exit "${1:-0}"
}

ensure_catalog() {
  mkdir -p "${ROOT}/docs"
  [[ -f "$CATALOG" ]] || cp "${TEMPLATES}/SERVICE_CATALOG.md" "$CATALOG"
}

detect_type_for_path() {
  local p="$1"
  case "$p" in
    *frontend*|*web*|*app*) echo "frontend" ;;
    *backend*|*server*|*api*) echo "backend" ;;
    *worker*|*job*|*queue*) echo "job" ;;
    *infra*) echo "infra" ;;
    *) echo "lib" ;;
  esac
}

scan_text() {
  local pattern="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden --glob '!agent-workflow/**' --glob '!docs/**' --glob '!reference/**' --glob '!node_modules/**' --glob '!vendor/**' --glob '!.git/**' "$pattern" "$ROOT" 2>/dev/null | head -5 || true
  else
    grep -RInE "$pattern" "$ROOT" 2>/dev/null | grep -v '/agent-workflow/' | grep -v '/docs/' | grep -v '/reference/' | head -5 || true
  fi
}

scan_files() {
  if command -v rg >/dev/null 2>&1; then
    rg --files "$ROOT" 2>/dev/null | sed "s#^${ROOT}/##" | grep -Ev '^(agent-workflow|docs|reference|node_modules|vendor|\.git)/' || true
  else
    find "$ROOT" -type f 2>/dev/null | sed "s#^${ROOT}/##" | grep -Ev '^(agent-workflow|docs|reference|node_modules|vendor|\.git)/' || true
  fi
}

summarize_scan() {
  local label="$1" pattern="$2" out
  out="$(scan_text "$pattern" | sed "s#^${ROOT}/##" | awk -F: '{print $1 ":" $2}' | sort -u | paste -sd ', ' - 2>/dev/null || true)"
  if [[ -n "$out" ]]; then
    echo "${label}: ${out}"
  else
    echo "待确认"
  fi
}

detect_entry_summary() {
  local files
  files="$(scan_files | grep -E '(^|/)(main|index|server|app|api|router|routes)\.(js|ts|tsx|jsx|py|go|rs|java|kt)$' | head -6 | paste -sd ', ' - 2>/dev/null || true)"
  [[ -n "$files" ]] && echo "$files" || echo "待确认"
}

detect_api_summary() {
  summarize_scan "routes" 'app\.(get|post|put|delete|patch)|router\.(get|post|put|delete|patch)|@(Get|Post|Put|Delete|Patch)|APIRouter|FastAPI|route\('
}

detect_data_summary() {
  summarize_scan "data" 'postgres|mysql|mongodb|redis|sqlite|prisma|sequelize|typeorm|sqlalchemy|mongoose|knex|database|db\.'
}

detect_deps_summary() {
  local manifests
  manifests="$(scan_files | grep -E '(^|/)(package.json|pnpm-lock.yaml|package-lock.json|yarn.lock|requirements.txt|pyproject.toml|go.mod|Cargo.toml|pom.xml|build.gradle)$' | paste -sd ', ' - 2>/dev/null || true)"
  [[ -n "$manifests" ]] && echo "manifests: ${manifests}" || echo "待确认"
}

detect_run_summary() {
  local ports scripts
  ports="$(scan_text 'PORT|listen\(|localhost:[0-9]+|:[0-9]{4}' | sed "s#^${ROOT}/##" | awk -F: '{print $1 ":" $2}' | sort -u | head -5 | paste -sd ', ' - 2>/dev/null || true)"
  scripts="$(scan_text '"(dev|start|serve|build)"[[:space:]]*:' | sed "s#^${ROOT}/##" | awk -F: '{print $1 ":" $2}' | sort -u | head -5 | paste -sd ', ' - 2>/dev/null || true)"
  if [[ -n "$ports" || -n "$scripts" ]]; then
    echo "ports/scripts: ${ports:-待确认} ${scripts:-}"
  else
    echo "待确认"
  fi
}

detect_observability_summary() {
  summarize_scan "observability" 'logger|log\.|console\.|sentry|datadog|prometheus|opentelemetry|otel|metrics|trace'
}

discover_candidates() {
  local found=false p type name entry api data deps run obs
  echo "== service catalog discovery =="
  entry="$(detect_entry_summary)"
  api="$(detect_api_summary)"
  data="$(detect_data_summary)"
  deps="$(detect_deps_summary)"
  run="$(detect_run_summary)"
  obs="$(detect_observability_summary)"
  for p in package.json pyproject.toml pom.xml build.gradle go.mod Cargo.toml; do
    if [[ -f "${ROOT}/${p}" ]]; then
      found=true
      type="$(detect_type_for_path "$p")"
      name="$(basename "$ROOT")"
      echo "| ${name} | 待确认 | ${type} | Detected from ${p} | ${entry} | ${api} | ${data} | ${deps} | docs/PROJECT_CONFIG.md | ${run} | ${obs} | discover |"
    fi
  done
  for p in frontend backend apps packages services src api server web; do
    if [[ -d "${ROOT}/${p}" ]]; then
      found=true
      type="$(detect_type_for_path "$p")"
      echo "| ${p} | 待确认 | ${type} | Detected directory ${p} | ${p}/; ${entry} | ${api} | ${data} | ${deps} | docs/PROJECT_CONFIG.md | ${run} | ${obs} | discover |"
    fi
  done
  $found || echo "（未发现明显服务/模块入口；可手工使用 aw service-catalog add）"
}

append_catalog_row() {
  local row="$1" tmp
  tmp="$(mktemp)"
  awk -v row="$row" '
    /^\| 名称 \|/ {print; next}
    /^\|------/ && done==0 {print; print row; done=1; next}
    $0 ~ /^\| 待填写 \|/ {next}
    {print}
    END{if(done==0) print row}
  ' "$CATALOG" > "$tmp"
  mv "$tmp" "$CATALOG"
}

case "$CMD" in
  init)
    ensure_catalog
    echo "created/ok: docs/SERVICE_CATALOG.md"
    ;;
  add)
    NAME="${1:-}"
    [[ -n "$NAME" ]] || { echo "error: aw service-catalog add \"name\"" >&2; exit 1; }
    shift || true
    OWNER="待确认"
    TYPE="lib"
    RESP=""
    ENTRY="待确认"
    API="待确认"
    DATA="待确认"
    DEPS="待确认"
    VERIFY="待确认"
    RUN="待确认"
    OBS="待确认"
    RELATED="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --owner) OWNER="${2:-}"; shift 2 ;;
        --type) TYPE="${2:-}"; shift 2 ;;
        --responsibility|--desc) RESP="${2:-}"; shift 2 ;;
        --entry) ENTRY="${2:-}"; shift 2 ;;
        --api) API="${2:-}"; shift 2 ;;
        --data) DATA="${2:-}"; shift 2 ;;
        --deps) DEPS="${2:-}"; shift 2 ;;
        --verify) VERIFY="${2:-}"; shift 2 ;;
        --run|--deploy) RUN="${2:-}"; shift 2 ;;
        --observability|--logs) OBS="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$RESP" ]] || { echo "error: --responsibility is required" >&2; exit 1; }
    case "$TYPE" in frontend|backend|fullstack|job|lib|infra) ;; *) echo "error: unsupported type: $TYPE" >&2; exit 1 ;; esac
    ensure_catalog
    row="| ${NAME} | ${OWNER} | ${TYPE} | ${RESP} | ${ENTRY} | ${API} | ${DATA} | ${DEPS} | ${VERIFY} | ${RUN} | ${OBS} | ${RELATED} |"
    append_catalog_row "$row"
    echo "updated: docs/SERVICE_CATALOG.md"
    aw_refresh_engineering_index
    ;;
  discover)
    WRITE=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --write) WRITE=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    ensure_catalog
    if $WRITE; then
      rows="$(discover_candidates | grep '^|' || true)"
      if [[ -z "$rows" ]]; then
        echo "no candidates to write"
      else
        while IFS= read -r row; do
          [[ -n "$row" ]] || continue
          name="$(echo "$row" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')"
          if grep -q "| ${name} |" "$CATALOG" 2>/dev/null; then
            echo "skip existing: ${name}"
          else
            append_catalog_row "$row"
            echo "added candidate: ${name}"
          fi
        done <<< "$rows"
        aw_refresh_engineering_index
      fi
    else
      discover_candidates
      echo ""
      echo "note: discovery only. Re-run with --write to append candidates."
    fi
    ;;
  check)
    echo "== service catalog check =="
    if [[ ! -f "$CATALOG" ]]; then
      echo "missing  docs/SERVICE_CATALOG.md (run: aw service-catalog init)" >&2
      exit 1
    fi
    echo "ok  docs/SERVICE_CATALOG.md"
    for header in "Owner" "入口文件" "验证命令" "运行 / 部署"; do
      grep -q "$header" "$CATALOG" && echo "ok  column: $header" || { echo "missing  column: $header" >&2; exit 1; }
    done
    ;;
  path)
    ensure_catalog
    printf '%s\n' "${CATALOG#"${ROOT}/"}"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
