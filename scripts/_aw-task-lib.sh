#!/usr/bin/env bash
# Task / workflow helpers (source from aw-task.sh, aw-next.sh, aw-verify.sh).

aw_workflow_json_path() {
  local root
  root="$(aw_repo_root)"
  echo "${root}/docs/.aw-workflow.json"
}

aw_task_requirement_confirm_path() {
  local root
  root="$(aw_repo_root)"
  echo "${root}/docs/.aw-task-requirement-confirmed.tsv"
}

aw_read_metadata_status() {
  local file="$1"
  [[ -f "$file" ]] || { echo "—"; return; }
  local line
  line="$(grep -E '^\|[[:space:]]*\*?\*?状态\*?\*?[[:space:]]*\|' "$file" 2>/dev/null | head -1 || true)"
  if echo "$line" | grep -q '已审'; then echo "已审"
  elif echo "$line" | grep -q '可执行'; then echo "可执行"
  elif echo "$line" | grep -q '草稿'; then echo "草稿"
  else echo "（未解析）"; fi
}

aw_resolve_dsl_file() {
  local root
  root="$(aw_repo_root)"
  local wf="${root}/docs/.aw-workflow.json"
  local active="${root}/docs/.aw-active-dsl"
  local f=""
  if [[ -f "$wf" ]]; then
    f="$(grep -E '"dsl_file"' "$wf" 2>/dev/null | sed -E 's/.*"dsl_file"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' | head -1 || true)"
    [[ -n "$f" && -f "${root}/${f}" ]] && { echo "$f"; return 0; }
  fi
  if [[ -f "$active" ]]; then
    f="$(tr -d '[:space:]' < "$active")"
    [[ -n "$f" && -f "${root}/${f}" ]] && { echo "$f"; return 0; }
    [[ -n "$f" && -d "${root}/${f}" && -f "${root}/${f}/INDEX.md" ]] && { echo "${f%/}/INDEX.md"; return 0; }
  fi
  local c
  for c in "${root}"/docs/dsl/DSL_DRAFT.md "${root}"/docs/dsl/DSL_*.md; do
    [[ -f "$c" ]] || continue
    local b
    b="$(basename "$c")"
    case "$b" in DSL_SPEC_TEMPLATE.md|FRONTEND_PAGE_SPEC_TEMPLATE.md|README.md) continue ;; esac
    echo "docs/dsl/${b}"
    return 0
  done
  for c in "${root}"/docs/dsl/DSL_*; do
    [[ -d "$c" && -f "$c/INDEX.md" ]] || continue
    echo "docs/dsl/$(basename "$c")/INDEX.md"
    return 0
  done
  return 1
}

aw_resolve_plan_file() {
  local root
  root="$(aw_repo_root)"
  local wf="${root}/docs/.aw-workflow.json"
  local active="${root}/docs/.aw-active-plan"
  if [[ -f "$active" ]]; then
    local f
    f="$(tr -d '[:space:]' < "$active")"
    [[ -n "$f" && -f "${root}/${f}" ]] && { echo "$f"; return 0; }
  fi
  if [[ -f "$wf" ]]; then
    local f
    f="$(grep -E '"plan_file"' "$wf" 2>/dev/null | sed -E 's/.*"plan_file"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' | head -1 || true)"
    [[ -n "$f" && -f "${root}/${f}" ]] && { echo "$f"; return 0; }
  fi
  local p
  for p in "${root}"/docs/plans/PLAN_*.md; do
    [[ -f "$p" ]] || continue
    echo "docs/plans/$(basename "$p")"
    return 0
  done
  return 1
}

aw_resolve_atomic_tasks_file() {
  local root plan_rel="${1:-}"
  root="$(aw_repo_root)"
  local wf="${root}/docs/.aw-workflow.json"
  if [[ -f "$wf" ]]; then
    local f
    f="$(grep -E '"atomic_tasks_file"' "$wf" 2>/dev/null | sed -E 's/.*"atomic_tasks_file"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' | head -1 || true)"
    [[ -n "$f" && -f "${root}/${f}" ]] && { echo "$f"; return 0; }
  fi
  local active="${root}/docs/.aw-active-atomic-tasks"
  if [[ -f "$active" ]]; then
    local f
    f="$(tr -d '[:space:]' < "$active")"
    [[ -n "$f" && -f "${root}/${f}" ]] && { echo "$f"; return 0; }
  fi
  if [[ -n "$plan_rel" ]]; then
    local base slug
    base="$(basename "$plan_rel" .md)"
    slug="${base#PLAN_}"
    if [[ -f "${root}/docs/plans/ATOMIC_TASKS_${slug}.md" ]]; then
      echo "docs/plans/ATOMIC_TASKS_${slug}.md"
      return 0
    fi
  fi
  local p
  for p in "${root}"/docs/plans/ATOMIC_TASKS_*.md; do
    [[ -f "$p" ]] || continue
    echo "docs/plans/$(basename "$p")"
    return 0
  done
  return 1
}

aw_write_workflow_json() {
  local dsl="$1" plan="$2" atomic="$3"
  local root
  root="$(aw_repo_root)"
  local now
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local dsl_st plan_st
  dsl_st="$(aw_read_metadata_status "${root}/${dsl}")"
  plan_st="$(aw_read_metadata_status "${root}/${plan}")"
  mkdir -p "${root}/docs"
  cat > "$(aw_workflow_json_path)" <<EOF
{
  "confirmed_at": "${now}",
  "dsl_file": "${dsl}",
  "dsl_status": "${dsl_st}",
  "plan_file": "${plan}",
  "plan_status": "${plan_st}",
  "atomic_tasks_file": "${atomic}",
  "current_task_id": ""
}
EOF
  echo "${dsl}" > "${root}/docs/.aw-active-dsl"
  echo "${atomic}" > "${root}/docs/.aw-active-atomic-tasks"
}

aw_gate_coding_ready() {
  local root msg=""
  root="$(aw_repo_root)"
  local dsl plan
  dsl="$(aw_resolve_dsl_file 2>/dev/null || true)"
  plan="$(aw_resolve_plan_file 2>/dev/null || true)"

  if [[ -z "$dsl" ]]; then
    echo "error: no DSL file (run aw init / aw dsl)" >&2
    return 1
  fi
  if [[ "$(aw_read_metadata_status "${root}/${dsl}")" != "已审" ]]; then
    echo "error: DSL must be 已审 before coding: ${dsl}" >&2
    echo "  fix: aw approve dsl ${dsl}" >&2
    return 1
  fi
  if [[ -z "$plan" ]]; then
    echo "error: no Plan file (run aw plan)" >&2
    return 1
  fi
  if [[ "$(aw_read_metadata_status "${root}/${plan}")" != "可执行" ]]; then
    echo "error: Plan must be 可执行 before coding: ${plan}" >&2
    echo "  fix: aw approve plan ${plan}" >&2
    return 1
  fi
  if [[ ! -f "$(aw_workflow_json_path)" ]] && [[ ! -f "${root}/docs/.aw-task-confirmed.json" ]]; then
    echo "error: task not confirmed (run aw confirm <dsl> <plan>)" >&2
    return 1
  fi
  local atomic
  atomic="$(aw_resolve_atomic_tasks_file "$plan" 2>/dev/null || true)"
  if [[ -z "$atomic" ]]; then
    echo "error: no ATOMIC_TASKS_*.md in docs/plans/" >&2
    return 1
  fi
  return 0
}

aw_trim() { echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'; }

aw_task_status_of() {
  local atomic_file="$1" task_id="$2"
  local row
  row="$(aw_task_get_row "$atomic_file" "$task_id" 2>/dev/null || true)"
  [[ -n "$row" ]] && echo "$row" | awk -F'\t' '{print $3}'
}

# Print next eligible AT-T: id\tdomain\ttitle\tstatus\tdeps\tverify
aw_task_find_next() {
  local atomic_file="$1"
  local line id domain title st dep ver ds nf
  while IFS= read -r line; do
    [[ "$line" =~ ^\|[[:space:]]*AT-T ]] || continue
    nf="$(awk -F'|' '{print NF}' <<< "$line")"
    if [[ "$nf" -ge 8 ]]; then
      IFS='|' read -r _ id domain title st dep ver _ <<< "$line"
    else
      domain="—"
      IFS='|' read -r _ id title st dep ver _ <<< "$line"
    fi
    id="$(aw_trim "$id")"
    domain="$(aw_trim "$domain")"
    title="$(aw_trim "$title")"
    st="$(aw_trim "$st")"
    dep="$(aw_trim "$dep")"
    ver="$(aw_trim "$ver")"
    [[ "$id" =~ ^AT-T ]] || continue
    [[ "$st" == "待办" || "$st" == "进行中" ]] || continue
    if [[ -n "$dep" && "$dep" != "—" && "$dep" != "-" ]]; then
      ds="$(aw_task_status_of "$atomic_file" "$dep")"
      [[ "$ds" == "已完成" ]] || continue
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$id" "$domain" "$title" "$st" "$dep" "$ver"
    return 0
  done < <(grep -E '\| AT-T[0-9]' "$atomic_file")
  return 1
}

aw_task_get_row() {
  local atomic_file="$1" task_id="$2"
  awk -F'|' -v want="$task_id" '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    /^\| AT-T/ {
      if (trim($2) == want) {
        if (NF >= 8) {
          print trim($2) "\t" trim($3) "\t" trim($4) "\t" trim($5) "\t" trim($6) "\t" trim($7)
        } else {
          print trim($2) "\t—\t" trim($3) "\t" trim($4) "\t" trim($5) "\t" trim($6)
        }
        found = 1
      }
    }
    END { exit (found ? 0 : 1) }
  ' "$atomic_file"
}

aw_task_set_status() {
  local atomic_file="$1" task_id="$2" new_status="$3"
  local tmp
  tmp="$(mktemp)"
  awk -F'|' -v id="$task_id" -v st="$new_status" '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    /^\| AT-T/ {
      if (trim($2) == id) {
        if (NF >= 8) {
          printf "| %s | %s | %s | %s | %s | %s |\n", trim($2), trim($3), trim($4), st, trim($6), trim($7)
        } else {
          printf "| %s | %s | %s | %s | %s |\n", trim($2), trim($3), st, trim($5), trim($6)
        }
        next
      }
    }
    { print }
  ' "$atomic_file" > "$tmp"
  mv "$tmp" "$atomic_file"
}

aw_task_set_verify() {
  local atomic_file="$1" task_id="$2" new_verify="$3"
  local tmp
  tmp="$(mktemp)"
  awk -F'|' -v id="$task_id" -v ver="$new_verify" '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    /^\| AT-T/ {
      if (trim($2) == id) {
        if (NF >= 8) {
          printf "| %s | %s | %s | %s | %s | %s |\n", trim($2), trim($3), trim($4), trim($5), trim($6), ver
        } else {
          printf "| %s | %s | %s | %s | %s |\n", trim($2), trim($3), trim($4), trim($5), ver
        }
        next
      }
    }
    { print }
  ' "$atomic_file" > "$tmp"
  mv "$tmp" "$atomic_file"
}

aw_extract_meta_field() {
  local file="$1" field="$2"
  local line
  line="$(grep -E "^\|[[:space:]]*\*?\*?${field}\*?\*?[[:space:]]*\|" "$file" 2>/dev/null | head -1 || true)"
  [[ -z "$line" ]] && return 1
  echo "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}' | tr -d '`' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

aw_task_set_current() {
  local task_id="$1"
  local wf
  wf="$(aw_workflow_json_path)"
  if [[ ! -f "$wf" ]]; then
    return 0
  fi
  local tmp
  tmp="$(mktemp)"
  if grep -q '"current_task_id"' "$wf"; then
    sed -E "s/\"current_task_id\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"current_task_id\": \"${task_id}\"/" "$wf" > "$tmp"
  else
    cp "$wf" "$tmp"
  fi
  mv "$tmp" "$wf"
}

aw_task_requirement_confirmed() {
  local task_id="$1"
  local f
  f="$(aw_task_requirement_confirm_path)"
  [[ -f "$f" ]] || return 1
  grep -qE "^${task_id}[[:space:]]" "$f"
}

aw_task_mark_requirement_confirmed() {
  local task_id="$1" summary="$2"
  local f tmp now
  f="$(aw_task_requirement_confirm_path)"
  mkdir -p "$(dirname "$f")"
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  tmp="$(mktemp)"
  if [[ -f "$f" ]]; then
    grep -vE "^${task_id}[[:space:]]" "$f" > "$tmp" || true
  fi
  printf '%s\t%s\t%s\n' "$task_id" "$now" "$summary" >> "$tmp"
  mv "$tmp" "$f"
}

aw_parse_project_config_cmd() {
  local key="$1"
  local root cfg
  root="$(aw_repo_root)"
  cfg="${root}/docs/PROJECT_CONFIG.md"
  [[ -f "$cfg" ]] || return 1
  local line
  line="$(grep -E "^[[:space:]]*${key}[：:]" "$cfg" 2>/dev/null | head -1 || true)"
  [[ -n "$line" ]] || return 1
  line="$(echo "$line" | sed -E "s/^[[:space:]]*${key}[：:][[:space:]]*//")"
  line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '`')"
  [[ -z "$line" || "$line" == *"____"* || "$line" == *"________________"* ]] && return 1
  echo "$line"
}
