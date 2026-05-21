#!/usr/bin/env bash
# Generate human-readable Engineering Harness reports.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
REPORT_DIR="${ROOT}/docs/reports"
CMD="${1:-handoff}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw report handoff [--write] [--focus "..."]
  aw report release [--write] [--focus "..."]
  aw report check [--strict] [--kind handoff|release]
  aw report list

Generates Markdown summaries for engineers: workflow state, requirements,
plans/tasks, bugs, verification, release, metrics, ops, agents, and trace gates.
EOF
  exit "${1:-0}"
}

json_field() {
  local key="$1" input="$2"
  printf '%s\n' "$input" | grep -E "\"${key}\"" | head -1 | sed -E 's/.*"'"${key}"'"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true
}

last_matching_lines() {
  local file="$1" pattern="$2" count="${3:-8}"
  if [[ -f "$file" ]]; then
    grep -E "$pattern" "$file" 2>/dev/null | tail -n "$count" || true
  fi
}

section_or_empty() {
  local title="$1" body="$2"
  echo "## ${title}"
  echo ""
  if [[ -n "$body" ]]; then
    printf '%s\n' "$body"
  else
    echo "—"
  fi
  echo ""
}

run_capture() {
  "$@" 2>&1 || true
}

write_report() {
  local kind="$1" content="$2" slug
  mkdir -p "$REPORT_DIR"
  slug="$(date -u +"%Y%m%dT%H%M%SZ")-${kind}"
  out="${REPORT_DIR}/REPORT-${slug}.md"
  printf '%s\n' "$content" > "$out"
  echo "written: ${out#"${ROOT}/"}"
  aw_refresh_engineering_index
}

latest_report() {
  local kind="$1"
  if [[ -d "$REPORT_DIR" ]]; then
    find "$REPORT_DIR" -maxdepth 1 -name "REPORT-*${kind}.md" | sort | tail -1
  fi
}

check_report_file() {
  local file="$1" kind="$2" err=0
  echo "check ${file#"${ROOT}/"}"

  for section in \
    "# Engineering Report" \
    "## Workflow State" \
    "## Metrics Summary" \
    "## Traceability Snapshot" \
    "## Engineer Checklist"; do
    if grep -qF "$section" "$file"; then
      echo "  ok: ${section}"
    else
      echo "  missing: ${section}"
      err=1
    fi
  done

  if [[ "$kind" == "release" ]]; then
    for section in "## Release Gate Snapshot" "## Service Discovery Snapshot"; do
      if grep -qF "$section" "$file"; then
        echo "  ok: ${section}"
      else
        echo "  missing: ${section}"
        err=1
      fi
    done
  fi

  return "$err"
}

check_reports() {
  local strict="$1" kind="$2" err=0 file
  echo "== report check =="
  if [[ ! -d "$REPORT_DIR" ]]; then
    echo "warn  docs/reports missing"
    $strict && return 1 || return 0
  fi

  if [[ "$kind" == "all" ]]; then
    file="$(latest_report handoff)"
    if [[ -n "$file" ]]; then
      check_report_file "$file" handoff || err=1
    else
      echo "warn  no handoff report yet"
      $strict && err=1
    fi
    file="$(latest_report release)"
    if [[ -n "$file" ]]; then
      check_report_file "$file" release || err=1
    else
      echo "warn  no release report yet"
      $strict && err=1
    fi
  else
    file="$(latest_report "$kind")"
    if [[ -n "$file" ]]; then
      check_report_file "$file" "$kind" || err=1
    else
      echo "warn  no ${kind} report yet"
      $strict && err=1
    fi
  fi

  return "$err"
}

generate_report() {
  local kind="$1" focus="$2" status_json dsl plan atomic current next
  status_json="$(run_capture "${SCRIPT_DIR}/aw-status.sh" --json)"
  dsl="$(json_field dsl_file "$status_json")"
  plan="$(json_field plan_file "$status_json")"
  atomic="$(json_field atomic_tasks_file "$status_json")"
  next="$(json_field next "$status_json")"
  current="$(printf '%s\n' "$status_json" | grep -E '"current_task"' -A6 | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' || true)"

  req="$(last_matching_lines "${ROOT}/docs/requirements/INDEX.md" '^\|[[:space:]]*`?REQ-' 10)"
  bugs="$(last_matching_lines "${ROOT}/docs/handoff/AI_BUG_LOG.md" '^\|[[:space:]]*BUG-|^- ' 10)"
  changelog="$(last_matching_lines "${ROOT}/agent-workflow/CHANGELOG.md" '^- ' 10)"
  [[ -n "$changelog" ]] || changelog="$(last_matching_lines "${ROOT}/CHANGELOG.md" '^- ' 10)"
  release="$(last_matching_lines "${ROOT}/docs/release/RELEASE_RECORD.md" '^\|[[:space:]]*[0-9]{4}-' 8)"
  metrics="$(run_capture "${SCRIPT_DIR}/aw-metrics.sh" summary)"
  ops="$(last_matching_lines "${ROOT}/docs/ops/INCIDENTS.md" '^\|[[:space:]]*[0-9]{4}-' 8)"
  agents="$(last_matching_lines "${ROOT}/docs/agents/AGENT_REVIEWS.md" '^\|[[:space:]]*[0-9]{4}-' 8)"
  trace="$(run_capture "${SCRIPT_DIR}/aw-trace.sh" check)"
  release_gate="$(run_capture "${SCRIPT_DIR}/aw-release.sh" gate)"
  service="$(run_capture "${SCRIPT_DIR}/aw-service-catalog.sh" discover)"

  cat <<EOF
# Engineering Report — ${kind}

生成时间：$(date -u +"%Y-%m-%dT%H:%M:%SZ")  
仓库：${ROOT}  
焦点：${focus:-—}

## Workflow State

| 项 | 值 |
|----|----|
| DSL | ${dsl:-—} |
| Plan | ${plan:-—} |
| ATOMIC | ${atomic:-—} |
| Current task | ${current:-—} |
| Next | ${next:-—} |

$(section_or_empty "Recent Requirements" "$req")
$(section_or_empty "Recent Bugs / Failures" "$bugs")
$(section_or_empty "Recent Changelog Entries" "$changelog")
$(section_or_empty "Release Records" "$release")
## Metrics Summary

\`\`\`text
${metrics}
\`\`\`

$(section_or_empty "Recent Incidents" "$ops")
$(section_or_empty "Recent Agent Reviews" "$agents")
## Release Gate Snapshot

\`\`\`text
${release_gate}
\`\`\`

## Traceability Snapshot

\`\`\`text
${trace}
\`\`\`

## Service Discovery Snapshot

\`\`\`text
${service}
\`\`\`

## Engineer Checklist

- [ ] REQ / DSL / Plan / AT-T 对齐，无未记录口述变更。
- [ ] Bug / 疑似 Bug 已记录，open 项有 owner 和下一步。
- [ ] Verify / TP / release gate / trace check 有证据。
- [ ] 如果这是大需求或 AT-T 完成点，已询问工程师是否提交当前分支。
- [ ] 交接前已更新 PROJECT_HANDOFF 或将本报告路径写入 handoff。
EOF
}

WRITE=false
FOCUS=""
case "$CMD" in
  handoff|release)
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --write) WRITE=true; shift ;;
        --focus) FOCUS="${2:-}"; shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    content="$(generate_report "$CMD" "$FOCUS")"
    if $WRITE; then
      write_report "$CMD" "$content"
    else
      printf '%s\n' "$content"
    fi
    ;;
  list)
    if [[ -d "$REPORT_DIR" ]]; then
      find "$REPORT_DIR" -maxdepth 1 -name 'REPORT-*.md' | sort | sed "s#^${ROOT}/##"
    else
      echo "no reports yet"
    fi
    ;;
  check)
    STRICT=false
    KIND="all"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --strict) STRICT=true; shift ;;
        --kind) KIND="${2:-all}"; shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    case "$KIND" in
      all|handoff|release) ;;
      *) echo "Unknown report kind: $KIND" >&2; usage 1 ;;
    esac
    check_reports "$STRICT" "$KIND"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
