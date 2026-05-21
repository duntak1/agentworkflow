#!/usr/bin/env bash
# Install tool-specific entry pointers (optional). Truth stays in agent-workflow/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
AW="${ROOT}/agent-workflow"

DO_CLAUDE=false
DO_CODEX=false
DO_COPILOT=false
DO_CURSOR=false
DO_WINDSURF=false
DO_CLINE=false
DO_CONTINUE=false
DO_ALL=false

usage() {
  cat <<EOF
Usage: $0 [--all] [--claude] [--codex] [--copilot] [--cursor] [--windsurf] [--cline] [--continue]

Installs optional IDE/Agent entry files that point to agent-workflow/INVOCATION.md.
Does not replace policy in agent-workflow/ — safe to re-run (skips existing files).

  --all       Install every supported adapter below
  --claude    CLAUDE.md stub (Claude Code, many tools read this)
  --codex     AGENTS.md stub (OpenAI Codex)
  --copilot   .github/copilot-instructions.md (GitHub Copilot / VS Code)
  --cursor    .cursor/rules/agent-workflow.mdc
  --windsurf  .windsurfrules (Windsurf Cascade)
  --cline     .clinerules (Cline)
  --continue  .continue/rules/agent-workflow.md (Continue)
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) DO_ALL=true ;;
    --claude) DO_CLAUDE=true ;;
    --codex) DO_CODEX=true ;;
    --copilot) DO_COPILOT=true ;;
    --cursor) DO_CURSOR=true ;;
    --windsurf) DO_WINDSURF=true ;;
    --cline) DO_CLINE=true ;;
    --continue) DO_CONTINUE=true ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown: $1" >&2; usage 1 ;;
  esac
  shift
done

if $DO_ALL; then
  DO_CLAUDE=true DO_CODEX=true DO_COPILOT=true DO_CURSOR=true
  DO_WINDSURF=true DO_CLINE=true DO_CONTINUE=true
fi

if ! $DO_CLAUDE && ! $DO_CODEX && ! $DO_COPILOT && ! $DO_CURSOR && \
   ! $DO_WINDSURF && ! $DO_CLINE && ! $DO_CONTINUE; then
  usage 1
fi

[[ -d "$AW" ]] || [[ -f "${ROOT}/agent-workflow/INVOCATION.md" ]] || {
  echo "error: run ./scripts/aw install . first (missing agent-workflow/)" >&2
  exit 1
}

write_if_missing() {
  local path="$1"
  shift
  if [[ -f "${ROOT}/${path}" ]]; then
    echo "skip (exists): ${path}"
  else
    mkdir -p "$(dirname "${ROOT}/${path}")"
    cat > "${ROOT}/${path}" <<EOF
$*
EOF
    echo "created: ${path}"
  fi
}

RULES_BLOCK='# agent-workflow（工具无关）

执行研发前必读：
- `agent-workflow/INVOCATION.md` — 调用与闸门
- `agent-workflow/AGENT_RULES.md` — 精简规则
- `docs/PROJECT_CONFIG.md` — 栈与验证命令

**闸门：** `docs/dsl/` 元数据状态非 **已审** 时，只改文档，不写业务代码（`src/`、`frontend/` 等）。
**勿读：** 根目录 `ENGINEERING_INDEX.md`（仅供人类）。

CLI：`./scripts/aw status` · `./scripts/aw dsl` · `./scripts/aw plan` · `./scripts/aw confirm`'

if $DO_CLAUDE; then
  write_if_missing "CLAUDE.md" "# CLAUDE.md

${RULES_BLOCK}

正文：[\`agent-workflow/CLAUDE.md\`](./agent-workflow/CLAUDE.md)
"
fi

if $DO_CODEX; then
  write_if_missing "AGENTS.md" "# AGENTS.md

${RULES_BLOCK}

路由：[\`agent-workflow/AGENTS.md\`](./agent-workflow/AGENTS.md) · [Codex 适配说明](./agent-workflow/adapters/codex.md)
"
fi

if $DO_COPILOT; then
  write_if_missing ".github/copilot-instructions.md" "# GitHub Copilot / VS Code — 项目指令

${RULES_BLOCK}

详见 [\`agent-workflow/adapters/copilot.md\`](./agent-workflow/adapters/copilot.md)
"
fi

if $DO_CURSOR; then
  write_if_missing ".cursor/rules/agent-workflow.mdc" "---
description: agent-workflow — tool-agnostic delivery pipeline
alwaysApply: true
---

${RULES_BLOCK}

详见 [\`agent-workflow/adapters/cursor.md\`](./agent-workflow/adapters/cursor.md)
"
fi

if $DO_WINDSURF; then
  write_if_missing ".windsurfrules" "${RULES_BLOCK}

Windsurf：见 \`agent-workflow/adapters/windsurf.md\`
"
fi

if $DO_CLINE; then
  write_if_missing ".clinerules" "${RULES_BLOCK}

Cline：见 \`agent-workflow/adapters/cline.md\`
"
fi

if $DO_CONTINUE; then
  write_if_missing ".continue/rules/agent-workflow.md" "${RULES_BLOCK}

Continue：见 \`agent-workflow/adapters/continue.md\`
"
fi

echo ""
echo "Done. Core truth: agent-workflow/INVOCATION.md"
echo "Index: agent-workflow/adapters/README.md"
