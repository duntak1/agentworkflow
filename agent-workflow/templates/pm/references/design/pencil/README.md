# Pencil 设计稿

| 目录 | 用途 |
|------|------|
| `source/` | Pencil 原始 `.pen` 文件 |
| `exports/` | 导出的 HTML / PDF / Markdown / JSON 等可读说明 |
| `screenshots/` | 关键页面、流程或圆形图截图 |

规则：

- `.pen` 文件不使用普通文本解析。
- 优先通过 Pencil 工具导出或截图，再让 Agent 读取导出物。
- 每个设计稿必须关联 REQ。
- 设计稿变更必须记录到 `../DESIGN_CHANGELOG.md`。
