#!/usr/bin/env bash
# Project intake scanner: infer new/existing stage and split-repo sync readiness before planning.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
OUT="${ROOT}/docs/PROJECT_SCAN.md"
CMD="${1:-scan}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw project scan
  aw project gate

`scan` inspects project contents and writes docs/PROJECT_SCAN.md.
`gate` blocks Plan generation until project scan/stage/build target/sync-center prerequisites are satisfied.
EOF
  exit "${1:-0}"
}

count_files() {
  find "$ROOT" \
    -path "${ROOT}/.git" -prune -o \
    -path "${ROOT}/node_modules" -prune -o \
    -path "${ROOT}/dist" -prune -o \
    -path "${ROOT}/build" -prune -o \
    -path "${ROOT}/coverage" -prune -o \
    -path "${ROOT}/.next" -prune -o \
    -path "${ROOT}/.nuxt" -prune -o \
    -path "${ROOT}/target" -prune -o \
    -path "${ROOT}/vendor" -prune -o \
    -path "${ROOT}/tmp" -prune -o \
    -type f -print 2>/dev/null | wc -l | tr -d ' '
}

count_code_files() {
  find "$ROOT" \
    -path "${ROOT}/.git" -prune -o \
    -path "${ROOT}/node_modules" -prune -o \
    -path "${ROOT}/dist" -prune -o \
    -path "${ROOT}/build" -prune -o \
    -path "${ROOT}/coverage" -prune -o \
    -path "${ROOT}/.next" -prune -o \
    -path "${ROOT}/.nuxt" -prune -o \
    -path "${ROOT}/target" -prune -o \
    -path "${ROOT}/vendor" -prune -o \
    -path "${ROOT}/tmp" -prune -o \
    -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.vue' -o -name '*.java' -o -name '*.kt' -o -name '*.go' -o -name '*.py' -o -name '*.rs' \) -print 2>/dev/null | wc -l | tr -d ' '
}

exists_any() {
  local p
  for p in "$@"; do
    [[ -e "${ROOT}/${p}" ]] && return 0
  done
  return 1
}

list_hits() {
  local p out=()
  for p in "$@"; do
    [[ -e "${ROOT}/${p}" ]] && out+=("$p")
  done
  if [[ ${#out[@]} -eq 0 ]]; then
    echo "—"
  else
    (IFS=', '; echo "${out[*]}")
  fi
}

scan_project() {
  mkdir -p "${ROOT}/docs"
  local total code stage confidence reason origin front_hits back_hits sync_state sync_harness sync_topology
  total="$(count_files)"
  code="$(count_code_files)"
  origin="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
  front_hits="$(list_hits package.json vite.config.ts vite.config.js next.config.js nuxt.config.ts src App.vue pages app)"
  back_hits="$(list_hits pom.xml build.gradle settings.gradle gradlew src/main/java src/main/kotlin go.mod pyproject.toml requirements.txt)"

  if [[ "$code" -ge 8 ]] || exists_any package.json pom.xml build.gradle go.mod pyproject.toml requirements.txt src/main/java src/main/kotlin src/main/resources src app pages; then
    stage="existing"
    confidence="high"
    reason="detected existing source/build files (${code} code files, ${total} total files)"
  elif [[ "$total" -le 25 ]]; then
    stage="new"
    confidence="medium"
    reason="few non-generated files detected (${total} total files, ${code} code files)"
  else
    stage="existing"
    confidence="medium"
    reason="many project files detected but few known source markers (${total} total files, ${code} code files)"
  fi

  sync_state="not-configured"
  sync_harness="—"
  sync_topology="待确认"
  if [[ -f "${ROOT}/docs/sync/SYNC_CONFIG.md" ]]; then
    sync_state="configured"
    sync_harness="$(awk -F'|' '/\*\*同步中心\*\*/ {gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3; exit}' "${ROOT}/docs/sync/SYNC_CONFIG.md")"
  fi

  cat > "$OUT" <<EOF
# Project Scan

| 字段 | 内容 |
|------|------|
| **扫描时间** | $(date -u +"%Y-%m-%dT%H:%M:%SZ") |
| **项目路径** | ${ROOT} |
| **建议项目阶段** | ${stage} |
| **置信度** | ${confidence} |
| **判断依据** | ${reason} |
| **文件总数** | ${total} |
| **代码文件数** | ${code} |
| **Git origin** | ${origin:-—} |
| **前端线索** | ${front_hits} |
| **后端线索** | ${back_hits} |
| **同步中心状态** | ${sync_state} |
| **同步中心路径** | ${sync_harness} |
| **前后端拓扑** | ${sync_topology} |

## 强制下一步

1. Agent 先向工程师复述本扫描结论，不得跳过。
2. 工程师确认项目阶段后执行：
   - 全新项目：\`./scripts/aw config init --project-stage 1\`
   - 已有 / 存量项目：\`./scripts/aw config init --project-stage 2\`
3. 立即询问工程师是否建立同步中心：
   - 建立 / 使用同步中心：\`./scripts/aw config init --sync-center 1 --sync-center-path <project-harness路径>\`
   - 不建立同步中心：\`./scripts/aw config init --sync-center 2\`
   - 稍后决定：\`./scripts/aw config init --sync-center 3\`（Plan 会保持阻断，直到改成 1 或 2）
4. 工程师确认代码托管平台和构建目标后执行：
   - GitHub：\`./scripts/aw config init --project-kind 1 --repo-url <url>\`
   - 本地 Git：\`./scripts/aw config init --project-kind 2\`
   - GitLab.com：\`./scripts/aw config init --project-kind 3 --repo-url <url>\`
   - Bitbucket：\`./scripts/aw config init --project-kind 4 --repo-url <url>\`
   - Gitee：\`./scripts/aw config init --project-kind 5 --repo-url <url>\`
   - GitCode：\`./scripts/aw config init --project-kind 6 --repo-url <url>\`
   - Gitea：\`./scripts/aw config init --project-kind 7 --repo-url <url>\`
   - Forgejo：\`./scripts/aw config init --project-kind 8 --repo-url <url>\`
   - GitLab CE：\`./scripts/aw config init --project-kind 9 --repo-url <url>\`
   - Gerrit：\`./scripts/aw config init --project-kind 10 --repo-url <url>\`
   - 阿里云云效 Codeup：\`./scripts/aw config init --project-kind 11 --repo-url <url>\`
   - 构建目标：\`./scripts/aw config init --build-target 1|2|3\`
5. 如果构建目标是前后端项目，并且前后端分仓 / 双项目开发，必须先建立同步中心：
   - 同电脑：\`./scripts/aw sync init <本地project-harness路径> --project <frontend|backend> --agent <agent-name> --role <frontend|backend>\`
   - 不同电脑：先创建 / clone 独立远程 \`project-harness\` 仓库，再执行同样的 \`aw sync init\`
6. 未完成项目扫描、阶段确认、同步中心决策、构建目标确认、必要同步中心配置前，\`aw plan\` / \`aw approve dsl --plan\` / \`aw plan apply\` 必须阻断。
EOF
  echo "written: docs/PROJECT_SCAN.md"
  echo "suggested project stage: ${stage} (${confidence})"
  echo "next: review docs/PROJECT_SCAN.md with engineer, then run aw config init --project-stage 1|2"
}

case "$CMD" in
  scan)
    scan_project
    ;;
  gate)
    aw_require_planning_intake_ready
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac
