# 仓库落地自检清单

面向维护者：把「文档上的流程」变成**可执行门禁**。完成项勾选并可在季度回顾时复查。

---

## 一次性配置

- [ ] **已执行 `./scripts/init-project.sh`**（`reference/`、`docs/dsl/`、`docs/plans/`、`docs/PROJECT_CONFIG.md`）
- [ ] **`./scripts/check-aw-layout.sh`** 通过
- [ ] **已执行 `./scripts/aw hooks`**（或 `./scripts/install-git-hooks.sh`；见 [`meta/PRE_COMMIT_AND_HOOKS.md`](./meta/PRE_COMMIT_AND_HOOKS.md)）
- [ ] **已执行 `./scripts/aw sync-skill`**（本机 Cursor skill，可选）
- [ ] **`REPOSITORY.md`「团队真源」块已填写**（Issue 系统、版本字段路径、CI 状态、默认分支、本地命令）；根 `README.md` 入口已指向文档包
- [ ] **包内 `CLAUDE.md`「构建与测试命令」已为真实命令**（非注释占位）
- [ ] **子项目（若有）README 指向同一套验证命令**，与 CI 一致
- [ ] **Issue 模板**：Bug + 功能（`.github/ISSUE_TEMPLATE/`）与自有平台字段对齐
- [ ] **`SECURITY.md`**（包内正文 + 根目录 GitHub 摘要）中「报告漏洞」渠道已改为团队真实联系方式

---

## 合并与发布门禁

- [ ] **Branch protection**：默认分支要求 PR + Review（及 CI 通过，若已启用）
- [ ] **无 CI 时**：书面规定「Reviewer 本地必须执行的命令」，并在 PR 模板中可追溯
- [ ] **发版责任人**：谁有权 bump 版本、打 tag、写 `[Unreleased]` 归档（写在 `REPOSITORY.md` 或内部 wiki 一句即可）

---

## 产品输入（阶段 0）

- [ ] `reference/manifest.yaml` 已填写，材料已放入 `reference/inputs/` 或 `source/`
- [ ] 目标 DSL 元数据 **状态 = 已审** 后才生成 Plan / 写业务代码
- [ ] `docs/plans/` 与 DSL、REQ 互链
- [ ] 任务确认后已运行 **`./scripts/aw confirm`**，根目录 **`ENGINEERING_INDEX.md`** 已生成（勿给 AI 读）

## 质量习惯（抽样）

- [ ] 切换 AI 或结束大块工作前已更新 [`PROJECT_HANDOFF.md`](../docs/handoff/PROJECT_HANDOFF.md)
- [ ] 用户级需求均有 **`docs/requirements/REQ-…`** 且 **INDEX** 已更新
- [ ] 最近 3 个 PR 均关联 Issue 或理由注明
- [ ] 用户可见变更均有包内 `CHANGELOG.md` `[Unreleased]` 条目（对照 [`VERSION_CHANGELOG_QUALITY_LOOP.md`](./VERSION_CHANGELOG_QUALITY_LOOP.md) §2；根目录另有入口）
- [ ] Bug 关闭含验证版本/tag（模板结论区）

---

## 变更记录

- 初版：与 README / CI / SECURITY 联动。
