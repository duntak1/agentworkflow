#!/usr/bin/env bash
# Release/environment record helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
REL_DIR="${ROOT}/docs/release"
ENV_FILE="${REL_DIR}/ENVIRONMENTS.md"
RECORD="${REL_DIR}/RELEASE_RECORD.md"
FLAGS="${REL_DIR}/FEATURE_FLAGS.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw release init
  aw release record --version "vX.Y.Z|unreleased" --env local|staging|production --scope "..." [--related "REQ/AT-T"] [--evidence "..."] [--rollback "..."] [--status planned|deployed|verified|rolled-back]
  aw release flag "flag-name" --owner "..." --default on|off --scope "..." [--cleanup "..."]
  aw release flag-check
  aw release gate [--task AT-T...] [--run-verify] [--run-security] [--strict-policy] [--strict-report]
  aw release check
  aw release list
EOF
  exit "${1:-0}"
}

ensure_release() {
  mkdir -p "$REL_DIR"
  [[ -f "$ENV_FILE" ]] || cp "${TEMPLATES}/release/ENVIRONMENTS.md" "$ENV_FILE"
  [[ -f "$RECORD" ]] || cp "${TEMPLATES}/release/RELEASE_RECORD.md" "$RECORD"
  [[ -f "$FLAGS" ]] || cp "${TEMPLATES}/release/FEATURE_FLAGS.md" "$FLAGS"
}

insert_after_header() {
  local file="$1" row="$2"
  local tmp
  tmp="$(mktemp)"
  awk -v row="$row" '
    /^\| 时间 \|/ || /^\| Flag \|/ {print; next}
    /^\|------/ && done==0 {print; print row; done=1; next}
    {print}
    END{if(done==0) print row}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

case "$CMD" in
  init)
    ensure_release
    echo "created/ok: docs/release/"
    ;;
  record)
    VERSION=""
    ENV="local"
    SCOPE=""
    RELATED="—"
    CHANGELOG="CHANGELOG [Unreleased]"
    EVIDENCE="—"
    FLAG="—"
    ROLLBACK="待确认"
    STATUS="planned"
    CONFIRM="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --version) VERSION="${2:-}"; shift 2 ;;
        --env) ENV="${2:-}"; shift 2 ;;
        --scope) SCOPE="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        --changelog) CHANGELOG="${2:-}"; shift 2 ;;
        --evidence) EVIDENCE="${2:-}"; shift 2 ;;
        --flag|--flags) FLAG="${2:-}"; shift 2 ;;
        --rollback) ROLLBACK="${2:-}"; shift 2 ;;
        --status) STATUS="${2:-}"; shift 2 ;;
        --confirm) CONFIRM="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$VERSION" ]] || { echo "error: --version is required" >&2; exit 1; }
    [[ -n "$SCOPE" ]] || { echo "error: --scope is required" >&2; exit 1; }
    case "$ENV" in local|dev|test|staging|production) ;; *) echo "error: unsupported env: $ENV" >&2; exit 1 ;; esac
    case "$STATUS" in planned|deployed|verified|rolled-back|failed) ;; *) echo "error: unsupported status: $STATUS" >&2; exit 1 ;; esac
    ensure_release
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_after_header "$RECORD" "| ${now} | ${VERSION} | ${ENV} | ${SCOPE} | ${RELATED} | ${CHANGELOG} | ${EVIDENCE} | ${FLAG} | ${ROLLBACK} | ${STATUS} | ${CONFIRM} |"
    echo "logged: docs/release/RELEASE_RECORD.md"
    aw_refresh_engineering_index
    ;;
  flag)
    NAME="${1:-}"
    [[ -n "$NAME" ]] || { echo "error: aw release flag \"name\"" >&2; exit 1; }
    shift || true
    OWNER=""
    DEFAULT=""
    SCOPE=""
    RULE="待确认"
    KILL="待确认"
    REASON="待确认"
    CLEANUP="待确认"
    RELATED="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --owner) OWNER="${2:-}"; shift 2 ;;
        --default) DEFAULT="${2:-}"; shift 2 ;;
        --scope) SCOPE="${2:-}"; shift 2 ;;
        --rule) RULE="${2:-}"; shift 2 ;;
        --kill-switch) KILL="${2:-}"; shift 2 ;;
        --reason) REASON="${2:-}"; shift 2 ;;
        --cleanup) CLEANUP="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$OWNER" ]] || { echo "error: --owner is required" >&2; exit 1; }
    [[ -n "$DEFAULT" ]] || { echo "error: --default is required" >&2; exit 1; }
    [[ -n "$SCOPE" ]] || { echo "error: --scope is required" >&2; exit 1; }
    ensure_release
    insert_after_header "$FLAGS" "| ${NAME} | ${OWNER} | ${DEFAULT} | ${SCOPE} | ${RULE} | ${KILL} | ${REASON} | ${CLEANUP} | ${RELATED} |"
    echo "logged: docs/release/FEATURE_FLAGS.md"
    aw_refresh_engineering_index
    ;;
  gate)
    TASK_ID=""
    RUN_VERIFY=false
    RUN_SECURITY=false
    STRICT_POLICY=false
    STRICT_REPORT=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task) TASK_ID="${2:-}"; shift 2 ;;
        --run-verify) RUN_VERIFY=true; shift ;;
        --run-security) RUN_SECURITY=true; shift ;;
        --strict-policy) STRICT_POLICY=true; shift ;;
        --strict-report) STRICT_REPORT=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    ensure_release
    echo "== release gate =="
    err=0
    "${SCRIPT_DIR}/aw-changelog.sh" check || err=1
    if $STRICT_POLICY; then
      AW_POLICY_STRICT=1 "${SCRIPT_DIR}/aw-policy.sh" check || err=1
    else
      "${SCRIPT_DIR}/aw-policy.sh" check || err=1
    fi
    "${SCRIPT_DIR}/aw-security.sh" check || err=1
    "${SCRIPT_DIR}/aw-service-catalog.sh" check || err=1
    "${SCRIPT_DIR}/aw-ops.sh" gate || err=1
    "${SCRIPT_DIR}/aw-agents.sh" gate || err=1
    "${SCRIPT_DIR}/aw-metrics.sh" summary || err=1
    if $STRICT_REPORT; then
      "${SCRIPT_DIR}/aw-report.sh" check --kind release --strict || err=1
    else
      "${SCRIPT_DIR}/aw-report.sh" check --kind release || true
    fi
    if grep -q '待确认' "$ENV_FILE" 2>/dev/null; then
      echo "warn  docs/release/ENVIRONMENTS.md contains 待确认 placeholders" >&2
    else
      echo "ok  environments filled"
    fi
    if $RUN_VERIFY; then
      if [[ -n "$TASK_ID" ]]; then
        "${SCRIPT_DIR}/aw-verify.sh" --task "$TASK_ID" || err=1
      else
        "${SCRIPT_DIR}/aw-verify.sh" || err=1
      fi
    else
      echo "skip verify execution (pass --run-verify)"
    fi
    if $RUN_SECURITY; then
      "${SCRIPT_DIR}/aw-security.sh" scan --run || err=1
    else
      "${SCRIPT_DIR}/aw-security.sh" scan >/dev/null || true
      echo "skip security execution (pass --run-security)"
    fi
    if grep -q '| .* | .* | .* | .* | .* | .* | .* | .* | .* | .* |' "$RECORD" 2>/dev/null; then
      echo "ok  release record table present"
    else
      echo "warn  no release record rows yet; use aw release record before production release" >&2
    fi
    if [[ "$err" -eq 0 ]]; then
      echo "release gate: ok"
    else
      echo "release gate: failed" >&2
      exit "$err"
    fi
    ;;
  flag-check)
    ensure_release
    echo "== feature flag lifecycle check =="
    err=0
    if grep -q '待确认' "$FLAGS" 2>/dev/null; then
      echo "warn  docs/release/FEATURE_FLAGS.md contains 待确认 placeholders" >&2
    fi
    while IFS= read -r line; do
      [[ "$line" =~ ^\| ]] || continue
      [[ "$line" == *"| Flag |"* || "$line" == *"|------"* ]] && continue
      name="$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')"
      cleanup="$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $9); print $9}')"
      [[ -z "$name" || "$name" == "待填写" ]] && continue
      if [[ -z "$cleanup" || "$cleanup" == "待确认" || "$cleanup" == "—" ]]; then
        echo "warn  flag missing cleanup plan: ${name}" >&2
        err=1
      else
        echo "ok  flag cleanup plan: ${name}"
      fi
    done < "$FLAGS"
    if [[ "$err" -eq 0 ]]; then
      echo "feature flag lifecycle: ok"
    else
      echo "feature flag lifecycle: review needed" >&2
    fi
    ;;
  check)
    echo "== release check =="
    err=0
    for f in "$ENV_FILE" "$RECORD" "$FLAGS"; do
      if [[ -f "$f" ]]; then
        echo "ok  ${f#"${ROOT}/"}"
      else
        echo "missing  ${f#"${ROOT}/"} (run: aw release init)" >&2
        err=1
      fi
    done
    "${SCRIPT_DIR}/aw-release.sh" flag-check || true
    exit "$err"
    ;;
  list)
    ensure_release
    sed -n '1,120p' "$RECORD"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
