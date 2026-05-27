# Codex Context Continuity

Codex 原生上下文压缩用于让当前会话继续推理；agent-workflow 的 Handoff / Memory 用于工程交接，让新会话可审计地接上旧会话。

## 新 Codex 会话启动

在新会话开始时先运行：

```bash
./scripts/aw handoff --check
./scripts/aw memory inject
./scripts/aw status
./scripts/aw next
```

然后读取：

1. `agent-workflow/INVOCATION.md`
2. `docs/handoff/PROJECT_HANDOFF.md`
3. `docs/requirements/INDEX.md`
4. `docs/memory/INDEX.md` 与 `aw memory inject` 输出中相关条目

不要把 `ENGINEERING_INDEX.md` 加入 AI 上下文；它只给人类工程师快速定位文件和状态。

## 旧会话结束前

大需求、AT-T 或一段连续对话结束时：

```bash
./scripts/aw compact "本轮目标或完成 AT-T..." --write --snapshot
```

如果用户要求记住聊天，用摘要记忆，不保存完整逐字聊天：

```bash
./scripts/aw compact "本轮目标或完成 AT-T..." --write --snapshot \
  --memory-summary "聊天背景和对后续工作的意义" \
  --decisions "已确认决定" \
  --memory-todos "后续事项" \
  --memory-open "待确认问题" \
  --memory-related "REQ / DSL / Plan / AT-T / 文件路径"
```

`aw compact` 会更新并检查 `PROJECT_HANDOFF.md`，生成 `docs/handoff/LAST_AUTO_SNAPSHOT.md` 和 `docs/handoff/PASTE_IN_NEW_CHAT.txt`。Codex 原生 compaction 目前不能被 skill 直接监听；这个命令是 AgentWorkflow 给 Codex 的标准手动联动入口。

正式需求仍写 `docs/requirements/`；当前进度仍写 `docs/handoff/PROJECT_HANDOFF.md`。

## 与 Codex 原生能力的边界

| 层 | 作用 |
|----|------|
| Codex 原生 compaction | 当前会话内部继续推理 |
| `PROJECT_HANDOFF.md` | 新会话恢复当前目标、进度、阻塞、下一步 |
| `docs/memory/` | 长期决策、偏好、流程、风险和聊天摘要 |
| `docs/requirements/` | 口述新增、补充需求和研发中变更 |

默认不要让自动化每轮覆盖 `PROJECT_HANDOFF.md`；优先检查、提醒、生成草稿，确认后再 `--write`。
