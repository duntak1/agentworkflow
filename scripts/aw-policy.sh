#!/usr/bin/env bash
# Minimal policy-as-code helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
POLICY_DIR="${ROOT}/docs/policy"
POLICY="${POLICY_DIR}/POLICY.yml"
DECISIONS="${POLICY_DIR}/POLICY_DECISIONS.md"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw policy init
  aw policy decision --type "..." --related "REQ/AT-T/Bug" --decision "..." [--risk "..."] [--follow-up "..."] [--confirm "..."]
  aw policy check [--staged|--all]
  aw policy diff [--staged|--all]
  aw policy gate [--staged|--all] [--strict]
  aw policy list
  aw policy path
EOF
  exit "${1:-0}"
}

ensure_policy() {
  mkdir -p "$POLICY_DIR"
  [[ -f "$POLICY" ]] || cp "${TEMPLATES}/policy/POLICY.yml" "$POLICY"
  [[ -f "$DECISIONS" ]] || cp "${TEMPLATES}/policy/POLICY_DECISIONS.md" "$DECISIONS"
}

changed_files() {
  local mode="$1"
  if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    case "$mode" in
      staged) git -C "$ROOT" diff --cached --name-only ;;
      all) git -C "$ROOT" diff --name-only; git -C "$ROOT" diff --cached --name-only ;;
      *) git -C "$ROOT" diff --name-only; git -C "$ROOT" diff --cached --name-only ;;
    esac | sort -u
  else
    return 0
  fi
}

policy_diff_gate() {
  local mode="$1" strict="${2:-false}" err=0 high=false deps=false files f
  if [[ "${AW_POLICY_STRICT:-0}" == "1" ]]; then
    strict=true
  fi
  files="$(changed_files "$mode" || true)"
  echo "== policy diff gate =="
  if [[ -z "$files" ]]; then
    echo "ok  no git diff files to inspect"
    return 0
  fi
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    case "$f" in
      .github/workflows/*|.githooks/*|scripts/*|infra/*|migrations/*|agent-workflow/*)
        high=true
        echo "warn high-risk path: $f" >&2
        ;;
    esac
    case "$(basename "$f")" in
      package.json|pnpm-lock.yaml|package-lock.json|yarn.lock|requirements.txt|pyproject.toml|pom.xml|build.gradle|go.mod|Cargo.toml)
        deps=true
        echo "warn dependency manifest changed: $f" >&2
        ;;
    esac
  done <<< "$files"
  if $high; then
    echo "action: record/confirm with aw policy decision --type high_risk_change --related <REQ/AT-T> --decision \"...\"" >&2
    err=1
  fi
  if $deps; then
    echo "action: record dependency review with aw security dependency \"pkg\" --version \"...\" --purpose \"...\"" >&2
    err=1
  fi
  if [[ "$err" -eq 0 ]]; then
    echo "ok  no high-risk policy diff detected"
  else
    if $strict; then
      echo "block policy diff gate: strict mode requires policy/security decision before continuing" >&2
      return 1
    fi
    echo "warn policy diff gate needs review; not blocking unless your team enforces it" >&2
  fi
  return 0
}

case "$CMD" in
  init)
    ensure_policy
    echo "created/ok: docs/policy/"
    ;;
  decision)
    TYPE=""
    RELATED="—"
    DECISION=""
    RISK="—"
    FOLLOW="—"
    CONFIRM="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --type) TYPE="${2:-}"; shift 2 ;;
        --related|--task|--req|--scope) RELATED="${2:-}"; shift 2 ;;
        --decision) DECISION="${2:-}"; shift 2 ;;
        --risk|--reason) RISK="${2:-}"; shift 2 ;;
        --follow-up) FOLLOW="${2:-}"; shift 2 ;;
        --confirm) CONFIRM="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$TYPE" ]] || { echo "error: --type is required" >&2; exit 1; }
    [[ -n "$DECISION" ]] || { echo "error: --decision is required" >&2; exit 1; }
    ensure_policy
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    tmp="$(mktemp)"
    awk -v row="| ${now} | ${TYPE} | ${RELATED} | ${DECISION} | ${RISK} | ${FOLLOW} | ${CONFIRM} |" '
      /^\| 时间 \|/ {print; next}
      /^\|------/ && done==0 {print; print row; done=1; next}
      {print}
      END{if(done==0) print row}
    ' "$DECISIONS" > "$tmp"
    mv "$tmp" "$DECISIONS"
    echo "logged: docs/policy/POLICY_DECISIONS.md"
    aw_refresh_engineering_index
    ;;
  check)
    MODE="default"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --staged) MODE="staged"; shift ;;
        --all) MODE="all"; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    echo "== policy check =="
    err=0
    for f in "$POLICY" "$DECISIONS"; do
      if [[ -f "$f" ]]; then
        echo "ok  ${f#"${ROOT}/"}"
      else
        echo "missing  ${f#"${ROOT}/"} (run: aw policy init)" >&2
        err=1
      fi
    done
    if [[ -f "$POLICY" ]]; then
      for key in required_confirmations restricted_actions exceptions; do
        grep -q "^${key}:" "$POLICY" && echo "ok  policy key: ${key}" || { echo "missing  policy key: ${key}" >&2; err=1; }
      done
    fi
    if [[ "${AW_POLICY_STRICT:-0}" == "1" ]]; then
      policy_diff_gate "$MODE" true || err=1
    else
      policy_diff_gate "$MODE" false || true
    fi
    exit "$err"
    ;;
  diff|gate)
    MODE="default"
    STRICT=false
    [[ "$CMD" == "gate" ]] && STRICT=true
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --staged) MODE="staged"; shift ;;
        --all) MODE="all"; shift ;;
        --strict) STRICT=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    ensure_policy
    policy_diff_gate "$MODE" "$STRICT"
    ;;
  list)
    ensure_policy
    sed -n '1,140p' "$DECISIONS"
    ;;
  path)
    ensure_policy
    printf '%s\n%s\n' "${POLICY#"${ROOT}/"}" "${DECISIONS#"${ROOT}/"}"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
