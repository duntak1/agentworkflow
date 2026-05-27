#!/usr/bin/env bash
# Demonstrate agent-workflow end to end in a temporary repository.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ -f "${SOURCE_ROOT}/skill/SKILL.md" && -x "${SCRIPT_DIR}/e2e-smoke.sh" ]]; then
  exec "${SCRIPT_DIR}/e2e-smoke.sh"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
APP_DIR="${TMP}/aw-demo-app"
DEMO_DSL="${TMP}/aw-demo-dsl.md"
DEMO_PLAN="${TMP}/aw-demo-plan.md"
DEMO_ATOMIC="${TMP}/aw-demo-atomic.md"

echo "== aw demo =="
echo "tmp: ${TMP}"

mkdir -p "${APP_DIR}"
cd "${APP_DIR}"

"${SCRIPT_DIR}/aw" install . --adapters
chmod +x scripts/aw scripts/*.sh
./scripts/aw init
./scripts/aw project scan
./scripts/aw config init \
  --project-stage "1" \
  --project-kind "2" \
  --sync-center "2" \
  --build-target "1" \
  --language "shell" \
  --package-manager "none" \
  --frontend "shell" \
  --ui "none" \
  --backend "none" \
  --database "none" \
  --lint "./scripts/aw check layout" \
  --format "./scripts/aw check layout" \
  --typecheck "./scripts/aw check layout" \
  --test "./scripts/aw check tp" \
  --build "./scripts/aw check plan" \
  --e2e "./scripts/aw check tp"
./scripts/aw rules init
./scripts/aw check rules

cat > "$DEMO_DSL" <<'EOF'
# DSL — aw demo

## 元数据

| 字段 | 内容 |
|------|------|
| **状态** | 草稿 |
| **关联 REQ** | — |

## 验收（可检查）

- [ ] demo workflow passes
EOF

./scripts/aw dsl apply --file "$DEMO_DSL"
./scripts/aw approve dsl docs/dsl/DSL_DRAFT.md

cat > "$DEMO_PLAN" <<'EOF'
# Plan — aw demo

## 元数据

| 字段 | 内容 |
|------|------|
| **状态** | 草稿 |
| **关联 DSL** | docs/dsl/DSL_DRAFT.md |

## 目标

Demonstrate the workflow gate.
EOF

cat > "$DEMO_ATOMIC" <<'EOF'
# Atomic tasks — aw demo

| ID | 任务 | 状态 | 依赖 | 验证 |
|----|------|------|------|------|
| AT-T1-001 | demo task | 待办 | — | ./scripts/aw check layout |
EOF

./scripts/aw plan apply --plan-file "$DEMO_PLAN" --atomic-file "$DEMO_ATOMIC" --slug DEMO
./scripts/aw approve plan docs/plans/PLAN_DEMO.md
./scripts/aw confirm docs/dsl/DSL_DRAFT.md docs/plans/PLAN_DEMO.md
./scripts/aw task brief AT-T1-001 >/dev/null
./scripts/aw task confirm AT-T1-001 "已确认：范围=演示 aw demo 的最小任务流；验收=layout 与 TP/e2e 检查通过；非目标=不实现真实业务功能"
./scripts/aw context plan --task AT-T1-001
./scripts/aw context gate --task AT-T1-001
./scripts/aw task start AT-T1-001
./scripts/aw tp new demo "demo TP"
TP_FILE="$(ls docs/quality/test-plans/TP-*demo*.md 2>/dev/null | head -1)"
./scripts/aw tp link AT-T1-001 "$TP_FILE"
./scripts/aw task complete AT-T1-001 --run-e2e
./scripts/aw status

echo ""
echo "aw demo: ok"
