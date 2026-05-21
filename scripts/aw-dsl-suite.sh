#!/usr/bin/env bash
# Create a multi-file DSL suite under docs/dsl/DSL_<slug>/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
slug="${1:-}"
title="${2:-}"

usage() {
  echo "Usage: aw dsl suite <slug> \"title\"" >&2
  exit 1
}

[[ -n "$slug" && -n "$title" ]] || usage
slug="$(echo "$slug" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-//;s/-$//')"
upper="$(echo "$slug" | tr '[:lower:]-' '[:upper:]_')"
dir="${ROOT}/docs/dsl/DSL_${upper}"
rel_dir="docs/dsl/DSL_${upper}"

if [[ -e "$dir" ]]; then
  echo "error: already exists: ${rel_dir}" >&2
  exit 1
fi

mkdir -p "$dir"

render() {
  local src="$1" dest="$2"
  sed -e "s/<name>/${title}/g" -e "s/<slug>/${slug}/g" "$src" > "$dest"
}

render "${TEMPLATES}/dsl/DSL_SUITE_INDEX.md" "${dir}/INDEX.md"
render "${TEMPLATES}/dsl/DSL_SUITE_REQUIREMENTS.md" "${dir}/00-requirements.md"
render "${TEMPLATES}/dsl/DSL_SUITE_PAGES.md" "${dir}/10-pages.md"
render "${TEMPLATES}/dsl/DSL_SUITE_INTERACTIONS.md" "${dir}/20-interactions.md"
render "${TEMPLATES}/dsl/DSL_SUITE_EVENTS.md" "${dir}/30-events.md"
render "${TEMPLATES}/dsl/DSL_SUITE_BOUNDARIES.md" "${dir}/40-boundaries.md"
render "${TEMPLATES}/dsl/DSL_SUITE_ACCEPTANCE.md" "${dir}/90-acceptance.md"

mkdir -p "${ROOT}/docs"
echo "${rel_dir}/INDEX.md" > "${ROOT}/docs/.aw-active-dsl"

echo "Created DSL suite: ${rel_dir}/"
echo "Active DSL: ${rel_dir}/INDEX.md"
aw_refresh_engineering_index
echo "Next: fill suite files → aw check dsl → aw dsl review ${rel_dir}/INDEX.md --write → aw approve dsl ${rel_dir}/INDEX.md --plan"
