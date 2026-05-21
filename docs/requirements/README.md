# 需求记录（Requirements）

**规则：** 用户提出的每一条**独立需求**（功能、流程、文档、约束变更）都应留下一条 **`REQ-`** 记录，**不因对话结束而消失**。实现可以合并进 PR，但 REQ 文件保留轨迹。

---

## 编号与文件命名

| 规则 | 示例 |
|------|------|
| `REQ-YYYYMMDD-序号-短英文slug.md` | `REQ-20260515-001-my-feature.md` |
| 序号三位：`001`、`002`… | 同日多条递增 |

新建文件时复制 [`_TEMPLATE.md`](./_TEMPLATE.md)。

---

## 索引

权威列表：**[`INDEX.md`](./INDEX.md)**（表格维护所有 REQ 的状态与链接）。

---

## 与 Issue / PR 的关系

| 载体 | 用途 |
|------|------|
| **REQ** | 需求由来、范围、验收、状态——**跨 AI / 跨会话**可读 |
| **GitHub Issue** | 讨论、排期、指派（可选，与 REQ 互相引用） |
| **PR** | 实现；描述区写 `Refs REQ-…` 或 `Closes REQ-…`（若团队约定） |

---

## 自动化（脚本）

- [`scripts/new-req.sh`](../../scripts/new-req.sh)：生成下一个 `REQ-YYYYMMDD-NN`、从 `_TEMPLATE.md` 写出文件，并**默认**把表格行插入 [`INDEX.md`](./INDEX.md) 顶部（去掉「尚无更多」占位行）。
- [`scripts/check-req-index.sh`](../../scripts/check-req-index.sh)：校验「每个 REQ 文件都在 INDEX 中有链接」——CI 中会跑。
- [`scripts/draft-handoff.sh`](../../scripts/draft-handoff.sh)：打印可粘贴进 [`PROJECT_HANDOFF.md`](../handoff/PROJECT_HANDOFF.md) 的草稿片段。
- 详见 [`scripts/README.md`](../../scripts/README.md)。

---

## 谁更新

- **创建：** 收到需求后尽快新建 REQ（可与实现并行）；可用 `./scripts/new-req.sh slug "标题"`。
- **关闭：** 验收通过后把状态改为 **已完成**，填写完成日期与 PR/commit。
- **Handoff：** `docs/handoff/PROJECT_HANDOFF.md` 中「关联需求」只列**活跃**项；已完成 REQ 留在 INDEX 可查。
