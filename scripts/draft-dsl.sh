#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
MANIFEST="${ROOT}/reference/manifest.yaml"
PROMPT_FILE="${TEMPLATES}/prompts/PROMPT-DSL.md"

PATH_CHOICE="${1:-}"
if [[ -z "$PATH_CHOICE" ]]; then
  PATH_CHOICE="$(aw_detect_dsl_path "$MANIFEST")"
fi

case "${PATH_CHOICE}" in
  A|a) SECTION="路径 A：仅需求 / 规格 MD → DSL" ;;
  B|b) SECTION="路径 B：设计说明 → DSL" ;;
  C|c) SECTION="路径 C：参考源码（± 规格）→ DSL" ;;
  *)
    echo "Usage: $0 [A|B|C]" >&2
    exit 1
    ;;
esac

echo "=============================================="
echo " DSL draft prompt — $(echo "$PATH_CHOICE" | tr '[:lower:]' '[:upper:]')"
echo " Repo: ${ROOT}"
echo "=============================================="
echo ""
echo "Paste into Cursor. Attach:"
echo "  @reference/manifest.yaml"
echo "  @reference/inputs/ (and source/ if path C)"
echo "  @docs/dsl/DSL_SPEC_TEMPLATE.md"
echo "  @docs/requirements/ (if any REQ)"
echo ""
echo "--- PROMPT (${SECTION}) ---"
echo ""

awk -v section="$SECTION" '
  $0 ~ section { found=1 }
  found && /^```text$/ { inblock=1; next }
  found && inblock && /^```$/ { exit }
  found && inblock { print }
' "${PROMPT_FILE}"

echo ""
echo "--- END PROMPT ---"
echo ""
echo "L2 write block: ./scripts/aw paste dsl-write  (or: aw dsl write)"
echo "Then: aw check dsl → aw dsl review ... --write → aw approve dsl docs/dsl/DSL_DRAFT.md --plan"
