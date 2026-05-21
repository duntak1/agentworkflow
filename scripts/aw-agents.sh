#!/usr/bin/env bash
# Multi-agent collaboration protocol helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
AGENTS_DIR="${ROOT}/docs/agents"
ROLES="${AGENTS_DIR}/AGENT_ROLES.md"
HANDOFFS="${AGENTS_DIR}/AGENT_HANDOFFS.md"
REVIEWS="${AGENTS_DIR}/AGENT_REVIEWS.md"
LOCKS="${AGENTS_DIR}/AGENT_LOCKS.md"
HEARTBEATS="${AGENTS_DIR}/AGENT_HEARTBEATS.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw agents init
  aw agents assign --role developer|reviewer|tester|security|release --owner "..." --scope "..." [--allowed "..."] [--blocked "..."] [--related "REQ/AT-T"]
  aw agents handoff --from "..." --to "..." --related "REQ/AT-T" --scope "..." --done "..." --todo "..." [--risk "..."] [--evidence "..."]
  aw agents review --reviewer "..." --type code|test|security|release --related "REQ/AT-T" --result pass|changes|block [--blockers "..."] [--suggestions "..."] [--evidence "..."]
  aw agents claim --agent "..." --task AT-T... --role frontend|backend|fullstack|qa|docs|ops --scope "..." --allowed "path1,path2" [--ttl-min 120]
  aw agents heartbeat --agent "..." --task AT-T... --status working|blocked|done --action "..." [--blocked "..."] [--next "..."]
  aw agents release --agent "..." --task AT-T... [--notes "..."]
  aw agents lock-check [--task AT-T...]
  aw agents gate [--strict]
  aw agents check
  aw agents list
EOF
  exit "${1:-0}"
}

ensure_agents() {
  mkdir -p "$AGENTS_DIR"
  [[ -f "$ROLES" ]] || cp "${TEMPLATES}/agents/AGENT_ROLES.md" "$ROLES"
  [[ -f "$HANDOFFS" ]] || cp "${TEMPLATES}/agents/AGENT_HANDOFFS.md" "$HANDOFFS"
  [[ -f "$REVIEWS" ]] || cp "${TEMPLATES}/agents/AGENT_REVIEWS.md" "$REVIEWS"
  [[ -f "$LOCKS" ]] || cp "${TEMPLATES}/agents/AGENT_LOCKS.md" "$LOCKS"
  [[ -f "$HEARTBEATS" ]] || cp "${TEMPLATES}/agents/AGENT_HEARTBEATS.md" "$HEARTBEATS"
}

insert_after_header() {
  local file="$1" row="$2" tmp
  tmp="$(mktemp)"
  awk -v row="$row" '
    /^\| 时间 \|/ {print; next}
    /^\|------/ && done==0 {print; print row; done=1; next}
    {print}
    END{if(done==0) print row}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

case "$CMD" in
  init)
    ensure_agents
    echo "created/ok: docs/agents/"
    ;;
  assign)
    ROLE=""
    OWNER=""
    SCOPE=""
    ALLOWED="待确认"
    BLOCKED="无关文件、未确认需求"
    RELATED="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --role) ROLE="${2:-}"; shift 2 ;;
        --owner) OWNER="${2:-}"; shift 2 ;;
        --scope) SCOPE="${2:-}"; shift 2 ;;
        --allowed) ALLOWED="${2:-}"; shift 2 ;;
        --blocked) BLOCKED="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    case "$ROLE" in developer|reviewer|tester|security|release) ;; *) echo "error: --role developer|reviewer|tester|security|release is required" >&2; exit 1 ;; esac
    [[ -n "$OWNER" && -n "$SCOPE" ]] || { echo "error: --owner and --scope are required" >&2; exit 1; }
    ensure_agents
    {
      echo ""
      echo "## Assignment - $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
      echo ""
      echo "- Role: ${ROLE}"
      echo "- Owner: ${OWNER}"
      echo "- Related: ${RELATED}"
      echo "- Scope: ${SCOPE}"
      echo "- Allowed paths: ${ALLOWED}"
      echo "- Blocked paths: ${BLOCKED}"
    } >> "$ROLES"
    echo "assigned: ${ROLE} → ${OWNER}"
    aw_refresh_engineering_index
    ;;
  handoff)
    FROM=""
    TO=""
    RELATED="—"
    SCOPE=""
    DONE=""
    TODO=""
    RISK="—"
    EVIDENCE="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --from) FROM="${2:-}"; shift 2 ;;
        --to) TO="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        --scope) SCOPE="${2:-}"; shift 2 ;;
        --done) DONE="${2:-}"; shift 2 ;;
        --todo) TODO="${2:-}"; shift 2 ;;
        --risk) RISK="${2:-}"; shift 2 ;;
        --evidence) EVIDENCE="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$FROM" && -n "$TO" && -n "$SCOPE" && -n "$DONE" && -n "$TODO" ]] || { echo "error: --from --to --scope --done --todo are required" >&2; exit 1; }
    ensure_agents
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_after_header "$HANDOFFS" "| ${now} | ${FROM} | ${TO} | ${RELATED} | ${SCOPE} | ${DONE} | ${TODO} | ${RISK} | ${EVIDENCE} |"
    echo "logged: docs/agents/AGENT_HANDOFFS.md"
    aw_refresh_engineering_index
    ;;
  review)
    REVIEWER=""
    TYPE=""
    RELATED="—"
    RESULT=""
    BLOCKERS="—"
    SUGGESTIONS="—"
    EVIDENCE="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --reviewer) REVIEWER="${2:-}"; shift 2 ;;
        --type) TYPE="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        --result) RESULT="${2:-}"; shift 2 ;;
        --blockers) BLOCKERS="${2:-}"; shift 2 ;;
        --suggestions) SUGGESTIONS="${2:-}"; shift 2 ;;
        --evidence) EVIDENCE="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    case "$TYPE" in code|test|security|release) ;; *) echo "error: --type code|test|security|release is required" >&2; exit 1 ;; esac
    case "$RESULT" in pass|changes|block) ;; *) echo "error: --result pass|changes|block is required" >&2; exit 1 ;; esac
    [[ -n "$REVIEWER" ]] || { echo "error: --reviewer is required" >&2; exit 1; }
    ensure_agents
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_after_header "$REVIEWS" "| ${now} | ${REVIEWER} | ${TYPE} | ${RELATED} | ${RESULT} | ${BLOCKERS} | ${SUGGESTIONS} | ${EVIDENCE} |"
    echo "logged: docs/agents/AGENT_REVIEWS.md"
    aw_refresh_engineering_index
    ;;
  claim)
    AGENT=""
    TASK=""
    ROLE=""
    SCOPE=""
    ALLOWED=""
    TTL_MIN="120"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --agent) AGENT="${2:-}"; shift 2 ;;
        --task) TASK="${2:-}"; shift 2 ;;
        --role) ROLE="${2:-}"; shift 2 ;;
        --scope) SCOPE="${2:-}"; shift 2 ;;
        --allowed) ALLOWED="${2:-}"; shift 2 ;;
        --ttl-min) TTL_MIN="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$AGENT" && -n "$TASK" && -n "$ROLE" && -n "$SCOPE" && -n "$ALLOWED" ]] || { echo "error: --agent --task --role --scope --allowed are required" >&2; exit 1; }
    ensure_agents
    now_epoch="$(date +%s)"
    expires_epoch=$((now_epoch + TTL_MIN * 60))
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    expires="$(date -r "$expires_epoch" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date '+%Y-%m-%d %H:%M:%S')"
    if grep -Eq "^\|[[:space:]]*${TASK}[[:space:]]*\|" "$LOCKS" && ! grep -Eq "^\|[[:space:]]*${TASK}[[:space:]]*\|[[:space:]]*${AGENT}[[:space:]]*\|" "$LOCKS"; then
      echo "error: task already claimed by another agent: ${TASK}" >&2
      grep -E "^\|[[:space:]]*${TASK}[[:space:]]*\|" "$LOCKS" >&2 || true
      exit 1
    fi
    insert_after_header "$LOCKS" "| ${TASK} | ${AGENT} | ${ROLE} | ${SCOPE} | ${ALLOWED} | active | ${now} | ${expires} | ${now} | — |"
    echo "claimed: ${TASK} by ${AGENT}"
    aw_refresh_engineering_index
    ;;
  heartbeat)
    AGENT=""
    TASK=""
    STATUS="working"
    ACTION=""
    BLOCKED="—"
    NEXT="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --agent) AGENT="${2:-}"; shift 2 ;;
        --task) TASK="${2:-}"; shift 2 ;;
        --status) STATUS="${2:-}"; shift 2 ;;
        --action) ACTION="${2:-}"; shift 2 ;;
        --blocked) BLOCKED="${2:-}"; shift 2 ;;
        --next) NEXT="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$AGENT" && -n "$TASK" && -n "$ACTION" ]] || { echo "error: --agent --task --action are required" >&2; exit 1; }
    case "$STATUS" in working|blocked|done) ;; *) echo "error: --status working|blocked|done" >&2; exit 1 ;; esac
    ensure_agents
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_after_header "$HEARTBEATS" "| ${now} | ${AGENT} | ${TASK} | ${STATUS} | ${ACTION} | ${BLOCKED} | ${NEXT} |"
    echo "heartbeat: ${AGENT} ${TASK} ${STATUS}"
    ;;
  release)
    AGENT=""
    TASK=""
    NOTES="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --agent) AGENT="${2:-}"; shift 2 ;;
        --task) TASK="${2:-}"; shift 2 ;;
        --notes) NOTES="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$AGENT" && -n "$TASK" ]] || { echo "error: --agent --task are required" >&2; exit 1; }
    ensure_agents
    tmp="$(mktemp)"
    awk -v task="$TASK" -v agent="$AGENT" -v notes="$NOTES" '
      BEGIN{FS=OFS="|"}
      $0 ~ "^\\|" {
        t=$2; a=$3; gsub(/^[ \t]+|[ \t]+$/, "", t); gsub(/^[ \t]+|[ \t]+$/, "", a)
        if (t == task && a == agent) {
          $7=" released "
          $11=" " notes " "
        }
      }
      {print}
    ' "$LOCKS" > "$tmp"
    mv "$tmp" "$LOCKS"
    echo "released: ${TASK} by ${AGENT}"
    aw_refresh_engineering_index
    ;;
  lock-check)
    ensure_agents
    TASK_FILTER=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task) TASK_FILTER="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    echo "== agent lock check =="
    err=0
    now_epoch="$(date +%s)"
    active_count="$(awk -F'|' -v task="$TASK_FILTER" '
      /^\|/ && $2 !~ /Task/ && $0 !~ /\|------/ {
        t=$2; s=$7
        gsub(/^[ \t]+|[ \t]+$/, "", t); gsub(/^[ \t]+|[ \t]+$/, "", s)
        if ((task == "" || t == task) && s == "active") c++
      }
      END{print c+0}
    ' "$LOCKS")"
    if [[ -n "$TASK_FILTER" && "$active_count" -eq 0 ]]; then
      echo "block: no active agent lock for ${TASK_FILTER}" >&2
      err=1
    else
      echo "ok  active locks: ${active_count}"
    fi
    while IFS='|' read -r _ task agent role scope allowed status claimed expires heartbeat notes _rest; do
      task="$(echo "${task:-}" | xargs)"
      agent="$(echo "${agent:-}" | xargs)"
      status="$(echo "${status:-}" | xargs)"
      expires="$(echo "${expires:-}" | xargs)"
      [[ -z "$task" || "$task" == "Task" || "$task" == "------" || "$status" != "active" ]] && continue
      [[ -n "$TASK_FILTER" && "$task" != "$TASK_FILTER" ]] && continue
      exp_epoch="$(date -j -f '%Y-%m-%d %H:%M:%S' "$expires" '+%s' 2>/dev/null || echo 0)"
      if [[ "$exp_epoch" -gt 0 && "$exp_epoch" -lt "$now_epoch" ]]; then
        echo "block: expired lock ${task} by ${agent}" >&2
        err=1
      fi
    done < "$LOCKS"
    exit "$err"
    ;;
  check)
    echo "== agents check =="
    err=0
    for f in "$ROLES" "$HANDOFFS" "$REVIEWS" "$LOCKS" "$HEARTBEATS"; do
      if [[ -f "$f" ]]; then
        echo "ok  ${f#"${ROOT}/"}"
      else
        echo "missing  ${f#"${ROOT}/"} (run: aw agents init)" >&2
        err=1
      fi
    done
    exit "$err"
    ;;
  gate)
    ensure_agents
    STRICT=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --strict) STRICT=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    echo "== agents gate =="
    "${SCRIPT_DIR}/aw-agents.sh" check
    "${SCRIPT_DIR}/aw-agents.sh" lock-check || err=1
    err=0
    if grep -Eq '^\| [^|]+ \| [^|]+ \| [^|]+ \| [^|]+ \| block \|' "$REVIEWS"; then
      echo "block: agent review has blocking result" >&2
      grep -E '^\| [^|]+ \| [^|]+ \| [^|]+ \| [^|]+ \| block \|' "$REVIEWS" >&2 || true
      exit 1
    fi
    if grep -Eq '^\| [^|]+ \| [^|]+ \| [^|]+ \| [^|]+ \| changes \|' "$REVIEWS"; then
      echo "warn  agent review requests changes" >&2
    fi
    if grep -q 'Allowed paths: 待确认' "$ROLES"; then
      echo "warn  agent assignment has unconfirmed allowed paths" >&2
    fi
    conflicts="$(
      awk '
        function trim(s){gsub(/^[ \t]+|[ \t]+$/, "", s); return s}
        function norm(s){
          s=trim(s)
          if (substr(s, 1, 2) == "./") s=substr(s, 3)
          while (length(s) > 1 && substr(s, length(s), 1) == "/") s=substr(s, 1, length(s)-1)
          return s
        }
        /^- Owner:/ {owner=trim(substr($0, index($0, ":")+1))}
        /^- Allowed paths:/ {
          allowed=trim(substr($0, index($0, ":")+1))
          if (owner == "" || allowed == "" || allowed == "待确认") next
          n=split(allowed, parts, /[,;，；]/)
          for (i=1; i<=n; i++) {
            p=norm(parts[i])
            if (p == "" || p == "待确认" || p == "N/A" || p == "none") continue
            idx++
            owners[idx]=owner
            paths[idx]=p
          }
        }
        END {
          for (i=1; i<=idx; i++) {
            for (j=i+1; j<=idx; j++) {
              if (owners[i] == owners[j]) continue
              pi=paths[i]; pj=paths[j]
              if (pi == pj || index(pi "/", pj "/") == 1 || index(pj "/", pi "/") == 1) {
                print owners[i] " ↔ " owners[j] ": " pi " / " pj
              }
            }
          }
        }
      ' "$ROLES"
    )"
    if [[ -n "$conflicts" ]]; then
      if $STRICT; then
        echo "block: agent allowed paths overlap" >&2
        echo "$conflicts" >&2
        exit 1
      fi
      echo "warn  agent allowed paths overlap; coordinate handoff or rerun with --strict to block" >&2
      echo "$conflicts" >&2
      err=0
    fi
    echo "agents gate: ok"
    exit "$err"
    ;;
  list)
    ensure_agents
    sed -n '1,120p' "$ROLES"
    echo ""
    sed -n '1,120p' "$HANDOFFS"
    echo ""
    sed -n '1,120p' "$REVIEWS"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
