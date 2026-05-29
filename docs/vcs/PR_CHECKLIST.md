# VCS_REVIEW_CHECKLIST

| 字段 | 内容 |
|------|------|
| **PR 标题** | 待确认 |
| **分支** | 待确认 |
| **关联 REQ** | 待确认 |
| **关联 DSL** | 待确认 |
| **关联 Plan** | 待确认 |
| **关联 AT-T** | 待确认 |
| **验证命令** | 待确认 |
| **Contract 检查** | 待确认 |
| **Score** | 待确认 |
| **Release 影响** | 待确认 |
| **Rollback** | 待确认 |

## 工程师 Review Checklist

- [ ] DSL 已审，Plan 可执行，AT-T 已确认。
- [ ] 代码改动只覆盖允许范围。
- [ ] 新增 / 删除 / 重命名业务文件已更新 `docs/FILE_INDEX.md`。
- [ ] API 变更已更新 `docs/contracts/` 并完成 schema diff。
- [ ] Bug / 失败测试已记录到 `AI_BUG_LOG.md`。
- [ ] 验证命令已执行并记录证据。
- [ ] CHANGELOG / release / rollback 信息已补齐。
