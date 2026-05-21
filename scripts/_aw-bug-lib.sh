#!/usr/bin/env bash
# Shared helpers for docs/handoff/AI_BUG_LOG.md.

aw_bug_log_path() {
  local root
  root="$(aw_repo_root)"
  printf '%s\n' "${root}/docs/handoff/AI_BUG_LOG.md"
}

aw_bug_ensure_log() {
  local bug_log
  bug_log="$(aw_bug_log_path)"
  mkdir -p "$(dirname "$bug_log")"
  if [[ ! -f "$bug_log" ]]; then
    cat > "$bug_log" <<'EOF'
# AI / 会话 Bug 流水

**用途：** 记录所有 Bug、测试失败、用户口述问题、审查发现与线上反馈；跨会话追溯。

| 字段 | 说明 |
|------|------|
| **来源** | `test` · `chat` · `review` · `runtime` · `prod` · `hook-*` |
| **状态** | `open` / `investigating` / `done` / `wontfix` |

---

## 流水（新在上）
EOF
  fi
}

aw_bug_append() {
  local source="$1" status="$2" scope="$3" summary="$4" evidence="$5"
  aw_bug_ensure_log
  local bug_log now tmp row
  bug_log="$(aw_bug_log_path)"
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  tmp="$(mktemp)"
  row="- ${now} | ${source} | ${status} | ${scope} | ${summary} | ${evidence}"
  awk -v row="$row" '
    BEGIN { inserted = 0 }
    /^## 流水/ {
      print
      print ""
      print row
      inserted = 1
      next
    }
    { print }
    END {
      if (!inserted) {
        print ""
        print "## 流水（新在上）"
        print ""
        print row
      }
    }
  ' "$bug_log" > "$tmp"
  mv "$tmp" "$bug_log"
}
