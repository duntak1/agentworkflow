#!/usr/bin/env bash
# SLO / incident / runbook helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
OPS_DIR="${ROOT}/docs/ops"
SLO="${OPS_DIR}/SLO.md"
INCIDENTS="${OPS_DIR}/INCIDENTS.md"
RUNBOOKS="${OPS_DIR}/RUNBOOKS.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw ops init
  aw ops slo --service "..." --owner "..." --sli "..." --slo "..." [--source "..."] [--alert "..."]
  aw ops incident --id INC-... --severity sev1|sev2|sev3|sev4 --service "..." --summary "..." [--status open|mitigated|resolved] [--impact "..."] [--root-cause "..."] [--action "..."] [--related "..."]
  aw ops incident-close --id INC-... --action "..." [--root-cause "..."] [--impact "..."] [--related "..."]
  aw ops runbook --scenario "..." --service "..." --signal "..." --steps "..." --fix "..." [--rollback "..."] [--owner "..."]
  aw ops gate
  aw ops check
  aw ops list
EOF
  exit "${1:-0}"
}

ensure_ops() {
  mkdir -p "$OPS_DIR"
  [[ -f "$SLO" ]] || cp "${TEMPLATES}/ops/SLO.md" "$SLO"
  [[ -f "$INCIDENTS" ]] || cp "${TEMPLATES}/ops/INCIDENTS.md" "$INCIDENTS"
  [[ -f "$RUNBOOKS" ]] || cp "${TEMPLATES}/ops/RUNBOOKS.md" "$RUNBOOKS"
}

insert_after_table() {
  local file="$1" row="$2" tmp
  tmp="$(mktemp)"
  awk -v row="$row" '
    /^\|[-]+/ && done==0 {print; print row; done=1; next}
    $0 ~ /^\| 待填写 \|/ {next}
    {print}
    END{if(done==0) print row}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

case "$CMD" in
  init)
    ensure_ops
    echo "created/ok: docs/ops/"
    ;;
  slo)
    SERVICE=""
    OWNER=""
    SLI=""
    SLO_VAL=""
    WINDOW="30d"
    BUDGET="待确认"
    SOURCE="待确认"
    ALERT="待确认"
    REVIEW="$(date '+%Y-%m-%d')"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --service) SERVICE="${2:-}"; shift 2 ;;
        --owner) OWNER="${2:-}"; shift 2 ;;
        --sli) SLI="${2:-}"; shift 2 ;;
        --slo) SLO_VAL="${2:-}"; shift 2 ;;
        --window) WINDOW="${2:-}"; shift 2 ;;
        --budget) BUDGET="${2:-}"; shift 2 ;;
        --source) SOURCE="${2:-}"; shift 2 ;;
        --alert) ALERT="${2:-}"; shift 2 ;;
        --review) REVIEW="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$SERVICE" && -n "$OWNER" && -n "$SLI" && -n "$SLO_VAL" ]] || { echo "error: --service --owner --sli --slo are required" >&2; exit 1; }
    ensure_ops
    insert_after_table "$SLO" "| ${SERVICE} | ${OWNER} | ${SLI} | ${SLO_VAL} | ${WINDOW} | ${BUDGET} | ${SOURCE} | ${ALERT} | ${REVIEW} |"
    echo "updated: docs/ops/SLO.md"
    aw_refresh_engineering_index
    ;;
  incident)
    ID=""
    SEV=""
    SERVICE=""
    SUMMARY=""
    STATUS="open"
    IMPACT="待确认"
    ROOT_CAUSE="待确认"
    ACTION="待确认"
    RELATED="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --id) ID="${2:-}"; shift 2 ;;
        --severity) SEV="${2:-}"; shift 2 ;;
        --service) SERVICE="${2:-}"; shift 2 ;;
        --summary) SUMMARY="${2:-}"; shift 2 ;;
        --status) STATUS="${2:-}"; shift 2 ;;
        --impact) IMPACT="${2:-}"; shift 2 ;;
        --root-cause) ROOT_CAUSE="${2:-}"; shift 2 ;;
        --action) ACTION="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$ID" && -n "$SEV" && -n "$SERVICE" && -n "$SUMMARY" ]] || { echo "error: --id --severity --service --summary are required" >&2; exit 1; }
    case "$SEV" in sev1|sev2|sev3|sev4) ;; *) echo "error: --severity sev1|sev2|sev3|sev4" >&2; exit 1 ;; esac
    case "$STATUS" in open|mitigated|resolved) ;; *) echo "error: --status open|mitigated|resolved" >&2; exit 1 ;; esac
    ensure_ops
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_after_table "$INCIDENTS" "| ${now} | ${ID} | ${SEV} | ${SERVICE} | ${SUMMARY} | ${STATUS} | ${IMPACT} | ${ROOT_CAUSE} | ${ACTION} | ${RELATED} |"
    echo "logged: docs/ops/INCIDENTS.md"
    aw_refresh_engineering_index
    ;;
  incident-close)
    ID=""
    IMPACT="已恢复"
    ROOT_CAUSE="待复盘"
    ACTION=""
    RELATED="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --id) ID="${2:-}"; shift 2 ;;
        --impact) IMPACT="${2:-}"; shift 2 ;;
        --root-cause) ROOT_CAUSE="${2:-}"; shift 2 ;;
        --action) ACTION="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$ID" && -n "$ACTION" ]] || { echo "error: --id and --action are required" >&2; exit 1; }
    ensure_ops
    latest="$(
      awk -F'|' -v id="$ID" '
        function trim(s){gsub(/^[ \t]+|[ \t]+$/, "", s); return s}
        trim($3)==id && found==0 { sev=trim($4); svc=trim($5); sum=trim($6); rel=trim($11); found=1 }
        END { if (svc!="") print sev "|" svc "|" sum "|" rel }
      ' "$INCIDENTS"
    )"
    [[ -n "$latest" ]] || { echo "error: incident not found: $ID" >&2; exit 1; }
    IFS='|' read -r SEV SERVICE SUMMARY FOUND_RELATED <<< "$latest"
    [[ "$RELATED" == "—" && -n "${FOUND_RELATED:-}" ]] && RELATED="$FOUND_RELATED"
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_after_table "$INCIDENTS" "| ${now} | ${ID} | ${SEV} | ${SERVICE} | ${SUMMARY} | resolved | ${IMPACT} | ${ROOT_CAUSE} | ${ACTION} | ${RELATED} |"
    echo "closed: docs/ops/INCIDENTS.md"
    aw_refresh_engineering_index
    ;;
  runbook)
    SCENARIO=""
    SERVICE=""
    SIGNAL=""
    STEPS=""
    FIX=""
    ROLLBACK="待确认"
    OWNER="待确认"
    REVIEW="$(date '+%Y-%m-%d')"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --scenario) SCENARIO="${2:-}"; shift 2 ;;
        --service) SERVICE="${2:-}"; shift 2 ;;
        --signal) SIGNAL="${2:-}"; shift 2 ;;
        --steps) STEPS="${2:-}"; shift 2 ;;
        --fix) FIX="${2:-}"; shift 2 ;;
        --rollback) ROLLBACK="${2:-}"; shift 2 ;;
        --owner) OWNER="${2:-}"; shift 2 ;;
        --review) REVIEW="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$SCENARIO" && -n "$SERVICE" && -n "$SIGNAL" && -n "$STEPS" && -n "$FIX" ]] || { echo "error: --scenario --service --signal --steps --fix are required" >&2; exit 1; }
    ensure_ops
    insert_after_table "$RUNBOOKS" "| ${SCENARIO} | ${SERVICE} | ${SIGNAL} | ${STEPS} | ${FIX} | ${ROLLBACK} | ${OWNER} | ${REVIEW} |"
    echo "updated: docs/ops/RUNBOOKS.md"
    aw_refresh_engineering_index
    ;;
  check)
    echo "== ops check =="
    err=0
    for f in "$SLO" "$INCIDENTS" "$RUNBOOKS"; do
      if [[ -f "$f" ]]; then
        echo "ok  ${f#"${ROOT}/"}"
      else
        echo "missing  ${f#"${ROOT}/"} (run: aw ops init)" >&2
        err=1
      fi
    done
    exit "$err"
    ;;
  gate)
    ensure_ops
    echo "== ops gate =="
    "${SCRIPT_DIR}/aw-ops.sh" check
    blockers="$(
      awk -F'|' '
        function trim(s){gsub(/^[ \t]+|[ \t]+$/, "", s); return s}
        /^\| [0-9]{4}-/ {
          id=trim($3)
          if (seen[id]++) next
          sev=trim($4); status=trim($7)
          if ((sev=="sev1" || sev=="sev2") && (status=="open" || status=="mitigated")) print $0
        }
      ' "$INCIDENTS"
    )"
    if [[ -n "$blockers" ]]; then
      echo "block: unresolved sev1/sev2 incidents require release/ops review" >&2
      echo "$blockers" >&2
      exit 1
    fi
    echo "ops gate: ok"
    ;;
  list)
    ensure_ops
    sed -n '1,100p' "$SLO"
    echo ""
    sed -n '1,100p' "$INCIDENTS"
    echo ""
    sed -n '1,100p' "$RUNBOOKS"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
