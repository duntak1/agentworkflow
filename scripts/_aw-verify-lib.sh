#!/usr/bin/env bash
# Verify spec parsing (source from aw-verify.sh, check-plan.sh)

# Split AT-T Verify cell: shell commands and TP:path refs (semicolon-separated)
aw_verify_specs_from_cell() {
  local cell="$1"
  cell="$(echo "$cell" | tr -d '`')"
  local part
  IFS=';' read -ra parts <<< "$cell"
  for part in "${parts[@]}"; do
    part="$(echo "$part" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -n "$part" ]] && printf '%s\n' "$part"
  done
}

aw_resolve_tp_path() {
  local spec="$1"
  local root
  root="$(aw_repo_root)"
  local p="${spec#TP:}"
  p="$(echo "$p" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [[ -z "$p" ]] && return 1
  if [[ -f "${root}/${p}" ]]; then
    echo "${p}"
    return 0
  fi
  if [[ -f "$p" ]]; then
    echo "${p#${root}/}"
    return 0
  fi
  # id slug: TP-20250519-001 or TP-20250519-001-foo
  local f
  for f in "${root}"/docs/quality/test-plans/${p}.md "${root}"/docs/quality/test-plans/${p}-*.md; do
    [[ -f "$f" ]] || continue
    echo "docs/quality/test-plans/$(basename "$f")"
    return 0
  done
  return 1
}

aw_is_tp_spec() {
  [[ "$1" == TP:* ]] && return 0
  [[ "$1" == *"/docs/quality/test-plans/TP-"* ]] && return 0
  [[ "$1" =~ ^TP-[0-9]{8}- ]] && return 0
  return 1
}
