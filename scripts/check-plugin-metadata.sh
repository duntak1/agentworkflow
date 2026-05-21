#!/usr/bin/env bash
# Validate Codex plugin and marketplace metadata.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PLUGIN="${ROOT}/.codex-plugin/plugin.json"
MARKET="${ROOT}/.agents/plugins/marketplace.json"
VERSION_FILE="${ROOT}/agent-workflow/VERSION"
ERR=0

echo "== plugin metadata check =="

if [[ ! -f "$PLUGIN" && ! -f "$MARKET" ]]; then
  echo "skip: no Codex plugin metadata in this repo"
  exit 0
fi

need_file() {
  local file="$1" label="$2"
  if [[ -f "$file" ]]; then
    echo "ok  ${label}"
  else
    echo "missing  ${label}" >&2
    ERR=1
  fi
}

json_ok() {
  local file="$1" label="$2"
  if command -v jq >/dev/null 2>&1; then
    if jq . "$file" >/dev/null 2>&1; then
      echo "ok  ${label} JSON"
    else
      echo "fail  ${label} JSON" >&2
      ERR=1
    fi
  else
    echo "warn  jq not found; skip ${label} JSON parse"
  fi
}

json_value() {
  local file="$1" expr="$2"
  if command -v jq >/dev/null 2>&1; then
    jq -r "$expr // empty" "$file" 2>/dev/null || true
  else
    return 1
  fi
}

need_file "$PLUGIN" ".codex-plugin/plugin.json"
need_file "$MARKET" ".agents/plugins/marketplace.json"

if [[ -f "$PLUGIN" ]]; then
  json_ok "$PLUGIN" "plugin.json"
fi
if [[ -f "$MARKET" ]]; then
  json_ok "$MARKET" "marketplace.json"
fi

if [[ -f "$PLUGIN" && -f "$VERSION_FILE" ]]; then
  plugin_ver="$(json_value "$PLUGIN" '.version')"
  pkg_ver="$(tr -d '[:space:]' < "$VERSION_FILE")"
  if [[ -n "$plugin_ver" && "$plugin_ver" == "$pkg_ver" ]]; then
    echo "ok  plugin version matches package (${plugin_ver})"
  else
    echo "fail  plugin version (${plugin_ver:-?}) != package (${pkg_ver:-?})" >&2
    ERR=1
  fi
fi

if [[ -f "$PLUGIN" && -f "$MARKET" ]]; then
  plugin_name="$(json_value "$PLUGIN" '.name')"
  market_entry_count="$(json_value "$MARKET" '[.plugins[]? | select(.name == "'"${plugin_name}"'")] | length')"
  market_path="$(json_value "$MARKET" '.plugins[]? | select(.name == "'"${plugin_name}"'") | .source.path' | head -1)"
  install_policy="$(json_value "$MARKET" '.plugins[]? | select(.name == "'"${plugin_name}"'") | .policy.installation' | head -1)"
  auth_policy="$(json_value "$MARKET" '.plugins[]? | select(.name == "'"${plugin_name}"'") | .policy.authentication' | head -1)"
  category="$(json_value "$MARKET" '.plugins[]? | select(.name == "'"${plugin_name}"'") | .category' | head -1)"

  if [[ "$market_entry_count" == "1" ]]; then
    echo "ok  marketplace has one ${plugin_name} entry"
  else
    echo "fail  marketplace entry count for ${plugin_name:-?}: ${market_entry_count:-?}" >&2
    ERR=1
  fi
  [[ "$market_path" == "." ]] && echo "ok  marketplace source.path ${market_path}" || { echo "fail  marketplace source.path ${market_path:-?}" >&2; ERR=1; }
  [[ "$install_policy" == "AVAILABLE" ]] && echo "ok  marketplace installation policy" || { echo "fail  marketplace installation policy ${install_policy:-?}" >&2; ERR=1; }
  [[ "$auth_policy" == "ON_INSTALL" ]] && echo "ok  marketplace authentication policy" || { echo "fail  marketplace authentication policy ${auth_policy:-?}" >&2; ERR=1; }
  [[ -n "$category" ]] && echo "ok  marketplace category ${category}" || { echo "fail  marketplace category missing" >&2; ERR=1; }
fi

if [[ -f "$PLUGIN" ]] && grep -q '\[TODO:' "$PLUGIN"; then
  echo "warn  plugin.json contains publish-time TODO fields"
fi

exit "$ERR"
