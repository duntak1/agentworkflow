# `docs/` 目录说明

**流程真源：** 仓库根 [`agent-workflow/`](../agent-workflow/README.md)（`aw install` 会拷贝到目标业务仓）。

本目录在 **skill 源码仓** 仅保留 **模板与约定**；`aw init` 后在业务仓生成 `DSL_DRAFT.md`、`manifest.yaml`、`ENGINEERING_INDEX.md` 等实例文件。

```
docs/
├── handoff/          ← 交接约定与模板
├── requirements/     ← REQ 模板 + INDEX
├── dsl/              ← DSL / 页面规格模板
├── plans/            ← Plan / AT-T* 模板
├── quality/          ← 书面用例（TP）模板
├── workflow/         ← 导航 → agent-workflow/
└── PROJECT_CONFIG.md ← init 生成（业务仓）
```

**脚本：** [`scripts/aw`](../scripts/aw) · **同步 Skill：** `./scripts/sync-skill.sh`
