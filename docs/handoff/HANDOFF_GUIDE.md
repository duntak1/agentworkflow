# 上下文压缩指南（类比 Claude Code compact）

Claude Code 一类工具的 **compact**：丢掉逐轮闲聊，保留**决策、约束、路径、未完成项**。这里用仓库里的 Markdown **手工完成同类效果**（不依赖某一厂商会话功能）。

---

## 何时更新 `PROJECT_HANDOFF.md`

| 时机 | 动作 |
|------|------|
| 结束一段连续开发 / 对话 | 用下方清单压缩进 `PROJECT_HANDOFF.md` |
| 切换另一个 AI 或新开窗口 | **先读再聊**：把本文件 + `docs/requirements/INDEX.md` 贴给新会话 |
| 每日站会或同步前 | 刷新「当前焦点」「阻塞」「下一步」 |
| 重大合并或发版后 | 更新里程碑；可选把过时细节删掉（历史在 Git） |

---

## 与 `docs/memory/` 的边界

| 功能 | 记录什么 | 生命周期 |
|------|----------|----------|
| Handoff | 当前目标、阶段进度、阻塞、下一步、待确认 | 短期，随任务推进刷新 |
| Memory | 稳定事实、已拍板决策、偏好、可复用流程、反复风险 | 长期，直到过期或归档 |

提炼规则：

- Handoff 先记录“现在做到哪、接下来做什么”。
- Memory 只记录“以后还会复用的结论”。
- 聊天可以进入 Memory，但必须是摘要：记录讨论背景、已确认决定、待办、待确认和关联对象，不保存完整逐字聊天。
- 如果一个 handoff 结论未来 2 次以上任务可能会用，运行 `aw memory add ...` 单独记录。
- 不要把整段 Handoff 原文、完整逐字聊天、日志或 secret 塞进 Memory。

---

## 压缩检查清单（按需删减，优先短的）

1. **当前目标（1～3 句）**  
   这一块工作在服务什么业务结果？

2. **硬约束**  
   栈、禁令、必须跑的命令（指向 [`REPOSITORY.md`](../../agent-workflow/REPOSITORY.md) / [`CLAUDE.md`](../../agent-workflow/CLAUDE.md)，勿全文粘贴）。

3. **已拍板决策**  
   「我们为什么选 A 不选 B」——只留结论 + 日期。

4. **仓库地图（_delta）**  
   本轮**新出现或频繁改动**的路径；全量结构见 `docs/README.md`。

5. **未完成（Next）**  
   编号列表，每条可到验收标准；避免「继续优化」这种虚词。

6. **阻塞 / 待确认**  
   需要人类答复的点。

7. **关联需求**  
   `REQ-…` 编号链接到 `docs/requirements/`。

8. **刻意不写**  
   长对话原文、大段日志、已合并 PR 的全文 diff——用 Issue/PR/commit 链接代替。  
   **也不要写**：整理文档目录 / 工作流包怎么拷贝 / Agent 规则闲聊等**过程性沟通**——除非已落成 REQ 或直接影响交付与门禁（一般人只看结论链到 PR/commit 即可）。

---

## 可复制骨架（粘贴进 `PROJECT_HANDOFF.md` 再改）

```markdown
## 当前目标（1～3 句）


## 硬约束
- 栈 / 禁令：见包内 `CLAUDE.md`（勿全文粘贴）
- 必跑命令：见 `REPOSITORY.md` 本地验证 / 本轮实际：`<!-- 一行 -->`

## 已拍板决策
- （日期）结论摘要；备选方案未选原因：

## 仓库地图（本轮 delta）
- `path/…` — 用途一句话

## 未完成（Next）
1. … → 验收：

## 阻塞 / 待确认
- …

## 关联需求
- [REQ-…](../requirements/REQ-….md) / Issue #…

## 刻意不写
- 长对话与完整日志；链接代替：PR / Issue / commit
```

### 给下一轮 AI 省 Token

- 新会话：**只**提供 `PROJECT_HANDOFF.md` + `INDEX.md`（或 REQ 路径）+ **本轮要动的文件路径列表**，不要把上轮对话整屏粘贴进来。  
- Handoff 正文里用 **包内 `CLAUDE.md` § 引用** 代替粘贴整章（例如「栈见 CLAUDE 技术栈」）。  
- 与 [`AICODING_WORKFLOW.md`](../../agent-workflow/AICODING_WORKFLOW.md)「Token / 上下文预算」一节一致。

**Bug / 测试失败：** Agent 须在 [`AI_BUG_LOG.md`](./AI_BUG_LOG.md) 追加流水（见包内 `AGENT_RULES.md`）；人类接手时可把重要项升为 Issue / REQ。

---

## 长度建议

- `PROJECT_HANDOFF.md` 目标 **800～2000 汉字**（或同等英文）；超出则搬到 `docs/requirements/` 或 ADR，Handoff 只留链接。

---

## 与新对话的固定开场（可复制）

### 通用最短版（任意模块）

```text
请先阅读并按此执行：
1. docs/handoff/PROJECT_HANDOFF.md
2. docs/requirements/INDEX.md（如有与我相关的 REQ 请打开）

本轮任务：<一句话>
```

### 本仓库 Vue 查房前端（推荐详稿）

- **真源：** [`NEW_CHAT_PASTE_TEMPLATE.md`](./NEW_CHAT_PASTE_TEMPLATE.md) — 内含**整段可复制**的首条消息与 **维护核对表**（完成一批 `AT-T*` 后请人工改表内「近期已完成 / 下一步」）。  
- **Cursor：** `preCompact` 达到阈值时写入的 [`PASTE_IN_NEW_CHAT.txt`](./PASTE_IN_NEW_CHAT.txt) 会**提示打开上述模板**；详稿仍以 `NEW_CHAT_PASTE_TEMPLATE.md` 为准。

---

## 半自动草稿

运行 `./scripts/aw handoff "本轮目标"` 可自动读取当前 DSL、Plan、ATOMIC、当前任务、下一任务、REQ、Bug、项目配置、Git branch / HEAD 和验证命令，生成可覆盖 `PROJECT_HANDOFF.md` 的 Markdown 草稿。

推荐用法一：先输出临时草稿，人工删改后再合并：

```bash
./scripts/aw handoff "完成 AT-T1-001 导出权限" > /tmp/PROJECT_HANDOFF.md
```

推荐用法二：草稿内容确认后，直接备份旧文件并覆盖当前交接快照：

```bash
./scripts/aw handoff "完成 AT-T1-001 导出权限" --write
./scripts/aw handoff --check
```

`--check` 会检查 `PROJECT_HANDOFF.md` 是否包含当前目标、状态、下一步、风险/待确认、新会话启动等关键章节，是否疑似写入 secret，以及是否把 `ENGINEERING_INDEX.md` 当成 AI 上下文内容塞进交接。

任务完成后 `aw task complete <AT-T>` 会提示同时做两件事：询问是否提交当前分支，以及刷新 handoff 快照。

## Codex：一键工程化压缩

Codex 原生上下文压缩不能被 skill 直接监听。需要切换模型、新开会话、长时间暂停、上下文明显变长，或完成一个大需求 / AT-T 批次时，运行：

```bash
./scripts/aw compact "本轮目标" --write --snapshot
```

它会更新并检查 `PROJECT_HANDOFF.md`，生成 `LAST_AUTO_SNAPSHOT.md` 和 `PASTE_IN_NEW_CHAT.txt`。如果本轮聊天里有需要长期记住的摘要，可追加：

```bash
./scripts/aw compact "本轮目标" --write --snapshot \
  --memory-summary "聊天摘要" \
  --memory-decisions "已确认决定" \
  --memory-todos "待办" \
  --memory-open "待确认问题"
```

## Cursor：将近占满时自动提醒

若使用 Cursor，可启用 **`.cursor/hooks.json`**：在 `preCompact` 且 **`context_usage_percent` ≥ 95%**（默认，可调）时自动生成 `LAST_AUTO_SNAPSHOT.md` / `PASTE_IN_NEW_CHAT.txt` 并通过 **`user_message`** 提示新开窗口。详见 [`CURSOR_CONTEXT_HOOK.md`](./CURSOR_CONTEXT_HOOK.md)。

---

## 变更记录

- [`NEW_CHAT_PASTE_TEMPLATE.md`](./NEW_CHAT_PASTE_TEMPLATE.md)：Vue 前端新会话整段粘贴真源；与 `preCompact` 生成的 `PASTE_IN_NEW_CHAT.txt` 联动。
- 初版：压缩清单与更新时机。
