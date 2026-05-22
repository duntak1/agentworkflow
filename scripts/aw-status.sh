#!/usr/bin/env bash
# Print workflow state and suggested next command.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"
# shellcheck source=_aw-task-lib.sh
source "${SCRIPT_DIR}/_aw-task-lib.sh"

JSON=false
case "${1:-}" in
  --json) JSON=true; shift ;;
  -h|--help)
    cat <<'EOF'
Usage: aw status [--json]

Print workflow state and suggested next command.
EOF
    exit 0
    ;;
esac

ROOT="$(aw_repo_root)"
WORKFLOW_STATE="$(aw_workflow_json_path)"
LEGACY_STATE="${ROOT}/docs/.aw-task-confirmed.json"

read_status() {
  local file="$1"
  [[ -f "$file" ]] || { echo "—"; return; }
  local line
  line="$(grep -E '^\|[[:space:]]*\*?\*?状态\*?\*?' "$file" 2>/dev/null | head -1 || true)"
  if echo "$line" | grep -q '已审'; then echo "已审"
  elif echo "$line" | grep -q '可执行'; then echo "可执行"
  elif echo "$line" | grep -q '草稿'; then echo "草稿"
  else echo "（未解析）"; fi
}

dsl_file=""
[[ -f "${ROOT}/docs/.aw-active-dsl" ]] && dsl_file="$(tr -d '[:space:]' < "${ROOT}/docs/.aw-active-dsl")"
if [[ -z "$dsl_file" ]]; then
  for c in "${ROOT}"/docs/dsl/DSL_DRAFT.md "${ROOT}"/docs/dsl/DSL_*.md; do
    [[ -f "$c" ]] || continue
    b="$(basename "$c")"
    case "$b" in DSL_SPEC_TEMPLATE.md|FRONTEND_PAGE_SPEC_TEMPLATE.md|README.md) continue ;; esac
    dsl_file="docs/dsl/${b}"
    break
  done
fi
if [[ -z "$dsl_file" ]]; then
  for c in "${ROOT}"/docs/dsl/DSL_*; do
    [[ -d "$c" && -f "$c/INDEX.md" ]] || continue
    dsl_file="docs/dsl/$(basename "$c")/INDEX.md"
    break
  done
fi

plan_file=""
for p in "${ROOT}"/docs/plans/PLAN_*.md; do
  [[ -f "$p" ]] || continue
  plan_file="docs/plans/$(basename "$p")"
  break
done

dsl_st="—"
plan_st="—"
[[ -n "$dsl_file" && -f "${ROOT}/${dsl_file}" ]] && dsl_st="$(read_status "${ROOT}/${dsl_file}")"
[[ -n "$plan_file" && -f "${ROOT}/${plan_file}" ]] && plan_st="$(read_status "${ROOT}/${plan_file}")"

confirmed="—"
[[ -f "$WORKFLOW_STATE" ]] && confirmed="$(grep -E '"confirmed_at"' "$WORKFLOW_STATE" 2>/dev/null | sed -E 's/.*"confirmed_at"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' | head -1 || true)"
[[ "$confirmed" == "—" && -f "$LEGACY_STATE" ]] && confirmed="$(grep -E '"confirmed_at"' "$LEGACY_STATE" 2>/dev/null | sed -E 's/.*"confirmed_at"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' | head -1 || true)"
[[ -z "$confirmed" ]] && confirmed="—"

atomic_file=""
current_task_id=""
current_task_line=""
if [[ -f "$WORKFLOW_STATE" ]]; then
  atomic_file="$(grep -E '"atomic_tasks_file"' "$WORKFLOW_STATE" 2>/dev/null | sed -E 's/.*"atomic_tasks_file"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' | head -1 || true)"
  current_task_id="$(grep -E '"current_task_id"' "$WORKFLOW_STATE" 2>/dev/null | sed -E 's/.*"current_task_id"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' | head -1 || true)"
fi
if [[ -z "$atomic_file" ]]; then
  atomic_file="$(aw_resolve_atomic_tasks_file "$plan_file" 2>/dev/null || true)"
fi
if [[ -n "$current_task_id" && -n "$atomic_file" && -f "${ROOT}/${atomic_file}" ]]; then
  current_task_line="$(aw_task_get_row "${ROOT}/${atomic_file}" "$current_task_id" 2>/dev/null || true)"
fi

has_aw=no
has_pkg=no
[[ -x "${ROOT}/scripts/aw" ]] && has_aw=yes
[[ -f "${ROOT}/agent-workflow/INVOCATION.md" ]] && has_pkg=yes

next=""
if [[ "$has_pkg" != yes || "$has_aw" != yes ]]; then
  next='Run: ~/.cursor/skills/agent-workflow/scripts/aw install .  (or from source repo: ./scripts/aw install .)'
elif [[ ! -d "${ROOT}/reference" ]] || [[ ! -f "${ROOT}/docs/PROJECT_CONFIG.md" ]]; then
  next="./scripts/aw init"
elif [[ -z "$dsl_file" ]]; then
  next="Fill reference/ → ./scripts/aw dsl → aw paste dsl-write"
elif [[ "$dsl_st" != "已审" ]]; then
  next="./scripts/aw approve dsl ${dsl_file}"
elif [[ -z "$plan_file" ]]; then
  next="./scripts/aw plan ${dsl_file} → aw paste plan-write"
elif [[ "$plan_st" != "可执行" ]]; then
  next="./scripts/aw approve plan ${plan_file}"
elif [[ "$confirmed" == "—" ]]; then
  next="./scripts/aw confirm ${dsl_file} ${plan_file}"
elif aw_gate_coding_ready 2>/dev/null; then
  next="./scripts/aw next → aw task brief <id> → aw task confirm <id> \"已确认：...\" → aw context plan --task <id> → aw context gate --task <id> → aw task start <id> → aw paste task → aw task complete <id>"
else
  next="./scripts/aw next (after gates pass)"
fi

json_escape() {
  printf '%s' "$1" | awk '{
    gsub(/\\/,"\\\\");
    gsub(/"/,"\\\"");
    gsub(/\t/,"\\t");
    gsub(/\r/,"\\r");
    gsub(/\n/,"\\n");
    printf "%s", $0
  }'
}

if $JSON; then
  task_json="null"
  if [[ -n "$current_task_line" ]]; then
    IFS=$'\t' read -r cur_id cur_title cur_status cur_deps cur_verify <<< "$current_task_line"
    task_json="$(printf '{"id":"%s","title":"%s","status":"%s","deps":"%s","verify":"%s"}' \
      "$(json_escape "$cur_id")" \
      "$(json_escape "$cur_title")" \
      "$(json_escape "$cur_status")" \
      "$(json_escape "$cur_deps")" \
      "$(json_escape "$cur_verify")")"
  elif [[ -n "$current_task_id" ]]; then
    task_json="$(printf '{"id":"%s","status":"missing","atomic_file":"%s"}' \
      "$(json_escape "$current_task_id")" \
      "$(json_escape "${atomic_file:-}")")"
  fi
  cat <<EOF
{
  "repo": "$(json_escape "$ROOT")",
  "package_installed": "${has_pkg}",
  "cli_executable": "${has_aw}",
  "dsl_file": "$(json_escape "${dsl_file:-}")",
  "dsl_status": "$(json_escape "$dsl_st")",
  "plan_file": "$(json_escape "${plan_file:-}")",
  "plan_status": "$(json_escape "$plan_st")",
  "confirmed_at": "$(json_escape "$confirmed")",
  "atomic_tasks_file": "$(json_escape "${atomic_file:-}")",
  "current_task": ${task_json},
  "next": "$(json_escape "$next")"
}
EOF
  exit 0
fi

echo "== agent-workflow status =="
echo "repo:     ${ROOT}"
echo "package:  ${has_pkg}  cli: ${has_aw}"
echo ""
echo "DSL:      ${dsl_file:-（无）}  [${dsl_st}]"
echo "Plan:     ${plan_file:-（无）}  [${plan_st}]"
echo "confirm:  ${confirmed}"
if [[ -n "$atomic_file" ]]; then
  echo "ATOMIC:   ${atomic_file}"
fi
if [[ -n "$current_task_line" ]]; then
  IFS=$'\t' read -r cur_id cur_title cur_status cur_deps cur_verify <<< "$current_task_line"
  echo "Task:     ${cur_id}  [${cur_status}] ${cur_title}"
elif [[ -n "$current_task_id" ]]; then
  echo "Task:     ${current_task_id}  [missing from ${atomic_file:-ATOMIC}]"
else
  echo "Task:     —"
fi
echo ""
echo "Next:     ${next}"
echo ""
echo "Harness:  aw gate check · aw contract gate · aw github-pr gate · aw score record --scope current · aw recover context"
