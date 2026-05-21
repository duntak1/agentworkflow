# CLAUDE.md（详版 · 项目栈与禁令）

**流程文档**见同目录 `PRODUCT_INPUT_WORKFLOW.md`、`AICODING_WORKFLOW.md`。  
**本项目栈与命令真源：** 仓库根 [`docs/PROJECT_CONFIG.md`](../docs/PROJECT_CONFIG.md)（`init-project.sh` 生成，请人类填写）。

---

## 技术栈（模板 — init 后覆盖）

| 层 | 填写 |
|----|------|
| 前端框架 | ________________ |
| UI 库 | ________________ |
| 包管理 | ________________ |
| 后端（若有） | ________________ |

---

## 构建与测试命令（必须填真实命令）

```text
安装：________________
Lint：________________
单测：________________
构建：________________
E2E/冒烟（若有）：________________
```

---

## 禁令（默认）

1. 不猜业务规则；不确定 → 列选项问人。
2. 权限、金额、库表、安全：禁止为省事跳过评审与迁移说明。
3. 不顺手重构、不改无关文件（Karpathy 手术式）。
4. DSL 未 `已审` 不写业务代码。
5. 不在 UI 层硬编码大段 Mock（见 DSL §BP 约定）。

---

## SOP 摘要

| 步骤 | 文档 |
|------|------|
| Reference → DSL → Plan | `PRODUCT_INPUT_WORKFLOW.md` |
| 假设 → 验收 → 实现 → 验证 | `AICODING_WORKFLOW.md` |
| CHANGELOG / §11 / Bug | `VERSION_CHANGELOG_QUALITY_LOOP.md` |
| Issue / CI / 版本字段 | `REPOSITORY.md` |

---

## 对话触发语

同 [`AGENT_RULES.md`](./AGENT_RULES.md)。
