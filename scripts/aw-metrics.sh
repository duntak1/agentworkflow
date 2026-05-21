#!/usr/bin/env bash
# Delivery metrics helper (DORA / Flow).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
METRICS_DIR="${ROOT}/docs/metrics"
METRICS="${METRICS_DIR}/DELIVERY_METRICS.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw metrics init
  aw metrics record --type deploy|change|failure|recovery --env local|staging|production --related "REQ/AT-T/Release" [--lead-time "..."] [--failed yes|no] [--mttr "..."] [--note "..."]
  aw metrics summary
  aw metrics check
  aw metrics list
EOF
  exit "${1:-0}"
}

ensure_metrics() {
  mkdir -p "$METRICS_DIR"
  [[ -f "$METRICS" ]] || cp "${TEMPLATES}/metrics/DELIVERY_METRICS.md" "$METRICS"
}

insert_row() {
  local row="$1" tmp
  tmp="$(mktemp)"
  awk -v row="$row" '
    /^\| 时间 \|/ {print; next}
    /^\|------/ && done==0 {print; print row; done=1; next}
    {print}
    END{if(done==0) print row}
  ' "$METRICS" > "$tmp"
  mv "$tmp" "$METRICS"
}

case "$CMD" in
  init)
    ensure_metrics
    echo "created/ok: docs/metrics/DELIVERY_METRICS.md"
    ;;
  record)
    TYPE=""
    ENV="local"
    RELATED="—"
    LEAD="—"
    FAILED="no"
    MTTR="—"
    NOTE="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --type) TYPE="${2:-}"; shift 2 ;;
        --env) ENV="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        --lead-time) LEAD="${2:-}"; shift 2 ;;
        --failed) FAILED="${2:-}"; shift 2 ;;
        --mttr) MTTR="${2:-}"; shift 2 ;;
        --note) NOTE="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    case "$TYPE" in deploy|change|failure|recovery) ;; *) echo "error: --type deploy|change|failure|recovery is required" >&2; exit 1 ;; esac
    case "$ENV" in local|dev|test|staging|production) ;; *) echo "error: unsupported env: $ENV" >&2; exit 1 ;; esac
    case "$FAILED" in yes|no) ;; *) echo "error: --failed yes|no" >&2; exit 1 ;; esac
    ensure_metrics
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_row "| ${now} | ${TYPE} | ${ENV} | ${RELATED} | ${LEAD} | ${FAILED} | ${MTTR} | ${NOTE} |"
    echo "logged: docs/metrics/DELIVERY_METRICS.md"
    aw_refresh_engineering_index
    ;;
  check)
    echo "== metrics check =="
    if [[ -f "$METRICS" ]]; then
      echo "ok  docs/metrics/DELIVERY_METRICS.md"
    else
      echo "missing  docs/metrics/DELIVERY_METRICS.md (run: aw metrics init)" >&2
      exit 1
    fi
    for term in "Deployment Frequency" "Lead Time" "Change Failure Rate" "MTTR"; do
      grep -q "$term" "$METRICS" && echo "ok  metric: $term" || { echo "missing  metric: $term" >&2; exit 1; }
    done
    ;;
  summary)
    ensure_metrics
    echo "== metrics summary =="
    awk -F'|' '
      function trim(s){gsub(/^[ \t]+|[ \t]+$/, "", s); return s}
      /^\| [0-9]{4}-[0-9]{2}-[0-9]{2}/ {
        total++
        type=trim($3)
        env=trim($4)
        failed=trim($7)
        if (type == "deploy") deploy++
        if (type == "deploy" && failed == "no") deploy_ok++
        if (type == "deploy" && failed == "yes") deploy_failed++
        if (type == "failure") failures++
        if (type == "recovery") recoveries++
        if (env == "production" && type == "deploy") prod_deploy++
      }
      END {
        print "records: " total+0
        print "deployments: " deploy+0 " (success: " deploy_ok+0 ", failed: " deploy_failed+0 ")"
        print "production deployments: " prod_deploy+0
        print "failures: " failures+0
        print "recoveries: " recoveries+0
      }
    ' "$METRICS"
    ;;
  list)
    ensure_metrics
    sed -n '1,140p' "$METRICS"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
