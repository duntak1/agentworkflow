#!/usr/bin/env bash
# Security findings and dependency review helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
SEC_DIR="${ROOT}/docs/security"
FINDINGS="${SEC_DIR}/SECURITY_FINDINGS.md"
DEPS="${SEC_DIR}/DEPENDENCY_REVIEW.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw security init
  aw security finding "summary" [--source secret|sast|sca|dast|container|iac|review] [--severity low|medium|high|critical] [--scope "..."] [--status open|investigating|done|wontfix] [--evidence "..."]
  aw security dependency "name" --version "..." --purpose "..." [--license "..."] [--decision "..."]
  aw security scan [--run] [--secrets] [--deps] [--sast]
  aw security check
  aw security list
EOF
  exit "${1:-0}"
}

ensure_security() {
  mkdir -p "$SEC_DIR"
  [[ -f "$FINDINGS" ]] || cp "${TEMPLATES}/security/SECURITY_FINDINGS.md" "$FINDINGS"
  [[ -f "$DEPS" ]] || cp "${TEMPLATES}/security/DEPENDENCY_REVIEW.md" "$DEPS"
}

insert_after_header() {
  local file="$1" row="$2"
  local tmp
  tmp="$(mktemp)"
  awk -v row="$row" '
    /^\| 时间 \|/ {print; next}
    /^\|------/ && done==0 {print; print row; done=1; next}
    {print}
    END{if(done==0) print row}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

detect_security_tools() {
  echo "== security scan adapters =="
  for tool in gitleaks detect-secrets trufflehog npm pnpm yarn pip-audit osv-scanner semgrep bandit; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "ok  tool: $tool"
    else
      echo "miss tool: $tool"
    fi
  done
}

run_or_suggest() {
  local label="$1" cmd="$2" run="$3"
  echo "== ${label} =="
  if ! command -v "${cmd%% *}" >/dev/null 2>&1; then
    echo "skip: ${cmd%% *} not installed"
    return 0
  fi
  if [[ "$run" == "true" ]]; then
    echo "run: $cmd"
    (cd "$ROOT" && eval "$cmd") || {
      "${SCRIPT_DIR}/aw-security.sh" finding "${label} scan failed" --source review --severity medium --scope "$cmd" --status open --evidence "command failed"
      return 1
    }
    echo "ok: ${label}"
  else
    echo "suggest: $cmd"
  fi
}

case "$CMD" in
  init)
    ensure_security
    echo "created/ok: docs/security/"
    ;;
  finding)
    SUMMARY="${1:-}"
    [[ -n "$SUMMARY" ]] || { echo "error: aw security finding \"summary\"" >&2; exit 1; }
    shift || true
    SOURCE="review"
    SEVERITY="medium"
    SCOPE="—"
    STATUS="open"
    EVIDENCE="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --source) SOURCE="${2:-}"; shift 2 ;;
        --severity) SEVERITY="${2:-}"; shift 2 ;;
        --scope) SCOPE="${2:-}"; shift 2 ;;
        --status) STATUS="${2:-}"; shift 2 ;;
        --evidence) EVIDENCE="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    case "$SOURCE" in secret|sast|sca|dast|container|iac|review|runtime|prod) ;; *) echo "error: unsupported source: $SOURCE" >&2; exit 1 ;; esac
    case "$SEVERITY" in low|medium|high|critical) ;; *) echo "error: unsupported severity: $SEVERITY" >&2; exit 1 ;; esac
    case "$STATUS" in open|investigating|done|wontfix) ;; *) echo "error: unsupported status: $STATUS" >&2; exit 1 ;; esac
    ensure_security
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_after_header "$FINDINGS" "| ${now} | ${SOURCE} | ${SEVERITY} | ${SCOPE} | ${SUMMARY} | ${STATUS} | ${EVIDENCE} |"
    echo "logged: docs/security/SECURITY_FINDINGS.md"
    aw_refresh_engineering_index
    ;;
  dependency)
    NAME="${1:-}"
    [[ -n "$NAME" ]] || { echo "error: aw security dependency \"name\" --version ..." >&2; exit 1; }
    shift || true
    VERSION=""
    PURPOSE=""
    LICENSE="待确认"
    CONCLUSION="待确认"
    ALTERNATIVES="待确认"
    DECISION="待确认"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --version) VERSION="${2:-}"; shift 2 ;;
        --purpose) PURPOSE="${2:-}"; shift 2 ;;
        --license) LICENSE="${2:-}"; shift 2 ;;
        --conclusion|--security) CONCLUSION="${2:-}"; shift 2 ;;
        --alternatives) ALTERNATIVES="${2:-}"; shift 2 ;;
        --decision) DECISION="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$VERSION" ]] || { echo "error: --version is required" >&2; exit 1; }
    [[ -n "$PURPOSE" ]] || { echo "error: --purpose is required" >&2; exit 1; }
    ensure_security
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_after_header "$DEPS" "| ${now} | ${NAME} | ${VERSION} | ${PURPOSE} | ${LICENSE} | ${CONCLUSION} | ${ALTERNATIVES} | ${DECISION} |"
    echo "logged: docs/security/DEPENDENCY_REVIEW.md"
    aw_refresh_engineering_index
    ;;
  scan)
    RUN=false
    DO_SECRETS=false
    DO_DEPS=false
    DO_SAST=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --run) RUN=true; shift ;;
        --secrets) DO_SECRETS=true; shift ;;
        --deps) DO_DEPS=true; shift ;;
        --sast) DO_SAST=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    if ! $DO_SECRETS && ! $DO_DEPS && ! $DO_SAST; then
      DO_SECRETS=true
      DO_DEPS=true
      DO_SAST=true
    fi
    ensure_security
    detect_security_tools
    err=0
    if $DO_SECRETS; then
      if command -v gitleaks >/dev/null 2>&1; then
        run_or_suggest "secret scan" "gitleaks detect --source . --redact" "$RUN" || err=1
      elif command -v detect-secrets >/dev/null 2>&1; then
        run_or_suggest "secret scan" "detect-secrets scan" "$RUN" || err=1
      elif command -v trufflehog >/dev/null 2>&1; then
        run_or_suggest "secret scan" "trufflehog filesystem . --no-update" "$RUN" || err=1
      else
        echo "skip: no secret scanner installed"
      fi
    fi
    if $DO_DEPS; then
      if [[ -f "${ROOT}/package.json" ]]; then
        if command -v npm >/dev/null 2>&1; then run_or_suggest "dependency audit" "npm audit --audit-level=moderate" "$RUN" || err=1; fi
        if command -v pnpm >/dev/null 2>&1; then run_or_suggest "dependency audit" "pnpm audit --audit-level moderate" "$RUN" || err=1; fi
        if command -v yarn >/dev/null 2>&1; then run_or_suggest "dependency audit" "yarn npm audit --severity moderate" "$RUN" || err=1; fi
      fi
      if [[ -f "${ROOT}/requirements.txt" || -f "${ROOT}/pyproject.toml" ]]; then
        if command -v pip-audit >/dev/null 2>&1; then run_or_suggest "dependency audit" "pip-audit" "$RUN" || err=1; fi
      fi
      if command -v osv-scanner >/dev/null 2>&1; then
        run_or_suggest "osv scan" "osv-scanner -r ." "$RUN" || err=1
      fi
    fi
    if $DO_SAST; then
      if command -v semgrep >/dev/null 2>&1; then
        run_or_suggest "sast scan" "semgrep scan --config auto" "$RUN" || err=1
      elif command -v bandit >/dev/null 2>&1 && find "$ROOT" -name '*.py' -type f | head -1 | grep -q .; then
        run_or_suggest "python sast scan" "bandit -r ." "$RUN" || err=1
      else
        echo "skip: no SAST scanner installed"
      fi
    fi
    if [[ "$RUN" == "false" ]]; then
      echo ""
      echo "note: suggestions only. Re-run with --run to execute installed scanners."
    fi
    exit "$err"
    ;;
  check)
    echo "== security check =="
    err=0
    for f in "$FINDINGS" "$DEPS"; do
      if [[ -f "$f" ]]; then
        echo "ok  ${f#"${ROOT}/"}"
      else
        echo "missing  ${f#"${ROOT}/"} (run: aw security init)" >&2
        err=1
      fi
    done
    exit "$err"
    ;;
  list)
    ensure_security
    sed -n '1,120p' "$FINDINGS"
    echo ""
    sed -n '1,120p' "$DEPS"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
