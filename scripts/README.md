# Scripts（agent-workflow · 工具无关）

**统一入口（推荐）：** [`aw`](./aw)

```bash
./scripts/aw install [path] | setup | doctor | demo | init | status | capabilities | dashboard | memory | dsl | plan | confirm | check | req new | next | paste ...
```

| 脚本 | 用途 |
|------|------|
| [`aw`](./aw) | 上述子命令的统一 CLI |
| [`init-project.sh`](./init-project.sh) | 初始化 `reference/`、`docs/dsl/`、`docs/plans/` 等 |
| [`draft-dsl.sh`](./draft-dsl.sh) | 由 `aw dsl` 调用：打印 DSL prompt（路径 A/B/C） |
| [`draft-plan.sh`](./draft-plan.sh) | 打印 Plan 生成 prompt（需 DSL 已审） |
| [`aw-dsl-apply.sh`](./aw-dsl-apply.sh) | `aw dsl apply`：校验并落盘 DSL |
| [`aw-plan-apply.sh`](./aw-plan-apply.sh) | `aw plan apply`：校验并落盘 Plan + ATOMIC |
| [`aw-dsl-select.sh`](./aw-dsl-select.sh) | `aw dsl list|use` |
| [`aw-plan-select.sh`](./aw-plan-select.sh) | `aw plan list|use` |
| [`aw-config.sh`](./aw-config.sh) | `aw config init` 填写 PROJECT_CONFIG |
| [`aw-rules.sh`](./aw-rules.sh) | `aw rules init|review|check` 工程规范 |
| [`aw-ci.sh`](./aw-ci.sh) | `aw ci install` 安装 GitHub Actions 模板 |
| [`aw-doctor.sh`](./aw-doctor.sh) | `aw doctor` 安装/闸门/适配器诊断 |
| [`aw-demo.sh`](./aw-demo.sh) | `aw demo` 端到端演示；源码仓会转入完整 e2e smoke |
| [`aw-capabilities.sh`](./aw-capabilities.sh) | `aw capabilities` 能力、适配器、证明路径摘要 |
| [`aw-dashboard.sh`](./aw-dashboard.sh) | `aw dashboard` 只读终端视图 |
| [`aw-memory.sh`](./aw-memory.sh) | `aw memory` 文件化跨会话记忆 |
| [`aw-setup.sh`](./aw-setup.sh) | `aw setup` 一键初始化常用路径 |
| [`aw-upgrade.sh`](./aw-upgrade.sh) | `aw upgrade` / `aw update` 刷新 package/scripts；`--from-github` 会重装本机 skill 并替换当前项目 |
| [`aw-remove.sh`](./aw-remove.sh) | `aw remove` 预览/删除集成文件 |
| [`check-docs-commands.sh`](./check-docs-commands.sh) | 检查 Skill/Invocation 命令文档同步 |
| [`check-plugin-metadata.sh`](./check-plugin-metadata.sh) | 检查 Codex plugin / marketplace metadata |
| [`check-memory.sh`](./check-memory.sh) | 检查 docs/memory 布局、字段与敏感信息 |
| [`check-aw-layout.sh`](./check-aw-layout.sh) | 校验目录骨架 |
| [`aw-approve.sh`](./aw-approve.sh) | DSL → 已审 / Plan → 可执行 |
| [`check-dsl-business-gate.sh`](./check-dsl-business-gate.sh) | pre-commit：DSL 未已审时拦业务代码 |
| [`aw-confirm.sh`](./aw-confirm.sh) | 任务确认 + 生成 `ENGINEERING_INDEX.md` |
| [`generate-engineering-index.sh`](./generate-engineering-index.sh) | 仅刷新工程师索引 |
| [`generate-file-index.sh`](./generate-file-index.sh) | 生成 `docs/FILE_INDEX.md`，代码优先覆盖前端、后端、共享、测试和运行配置文件说明 |
| [`aw-code-map.sh`](./aw-code-map.sh) | 生成 / 查询 `docs/context/CODE_MAP.md`，用于模块、入口、Symbol、路由/API、import 和测试映射定位，避免 AI 全仓扫描 |
| [`install-aw-adapters.sh`](./install-aw-adapters.sh) | IDE 适配：`aw adapters --all`（Claude/Codex/Copilot/Cursor/Windsurf/Cline/Continue） |
| [`sync-skill.sh`](./sync-skill.sh) | 同步到 `~/.cursor/skills/agent-workflow/`；`AW_SYNC_LEGACY_SKILL=1` 时额外生成旧别名 `aw-delivery` |
| [`check-skill-source.sh`](./check-skill-source.sh) | 校验仓库 `skill/` 真源 |
| [`check-skill-package.sh`](./check-skill-package.sh) | 校验已 sync 的 Skill 目录 |
| [`install-cursor-skill.sh`](./install-cursor-skill.sh) | 安装 Skill（本地路径或 `AW_SKILL_REPO_URL`） |
| [`e2e-smoke.sh`](./e2e-smoke.sh) | 端到端：skill → install → init → confirm |
| [`build-skill-archive.sh`](./build-skill-archive.sh) | 打包 `dist/agent-workflow-skill-*.tar.gz` |
| [`aw-status.sh`](./aw-status.sh) | 工作流状态与下一步建议；`--json` 输出机器可读状态 |
| [`aw-req.sh`](./aw-req.sh) | `aw req new|change`，口述新增和研发中变更统一写入 REQ 表，用需求类型区分；变更回写 DSL/Plan/ATOMIC |
| [`new-req.sh`](./new-req.sh) | 新建 REQ + 更新 INDEX（兼容入口） |
| [`check-req-index.sh`](./check-req-index.sh) | REQ 与 INDEX 一致性 |
| [`check-dsl.sh`](./check-dsl.sh) | DSL 元数据与 manifest 路径 |
| [`check-aw-all.sh`](./check-aw-all.sh) | `aw check` 聚合 |
| [`aw-next.sh`](./aw-next.sh) | 下一个 AT-T*（须已 confirm） |
| [`aw-task.sh`](./aw-task.sh) | `aw task brief|confirm|start|blocked|complete|done|show`、`aw paste task` |
| [`aw-verify.sh`](./aw-verify.sh) | `aw verify [--task AT-T…]` |
| [`_aw-task-lib.sh`](./_aw-task-lib.sh) | 任务表解析、闸门、`docs/.aw-workflow.json` |
| [`check-plan.sh`](./check-plan.sh) | `aw check plan` |
| [`check-project-config.sh`](./check-project-config.sh) | `aw check config` |
| [`aw-atomic.sh`](./aw-atomic.sh) | `aw atomic list|use` |
| [`aw-commit.sh`](./aw-commit.sh) | `aw commit` 验证 + 提交信息建议 |
| [`aw-tp.sh`](./aw-tp.sh) | `aw tp list|show|new|link` |
| [`aw-bug.sh`](./aw-bug.sh) | `aw bug add|list|path` |

写入型命令（REQ、Bug、TP、DSL、Plan、DSL review、rules init）成功后会自动刷新 `ENGINEERING_INDEX.md`；刷新工程师索引前会先尝试刷新 `docs/FILE_INDEX.md`。刷新失败只给 warning，不回滚原写入。
| [`check-test-plan-index.sh`](./check-test-plan-index.sh) | `aw check tp` |
| [`_aw-verify-lib.sh`](./_aw-verify-lib.sh) | Verify 列解析（命令 + `TP:path`） |
| [`aw-install.sh`](./aw-install.sh) | 安装包到目标仓库 |

## 环境变量

| 变量 | 说明 |
|------|------|
| `AW_TEMPLATES_DIR` | 覆盖模板目录（默认 `agent-workflow/templates`） |
| `AW_SKILL_ROOT` | 使用 Cursor skill 内 `templates/` 时设置 |
| `AW_SKILL_REPO_URL` / `AW_SKILL_REF` | 安装或 `aw upgrade --from-github` 时覆盖 GitHub 来源和分支 / tag |
| `AW_KEEP_OLD_SKILLS` | `install-cursor-skill.sh` 保留旧 skill 目录而不是清理替换 |
| `AW_SYNC_LEGACY_SKILL` | 设为 `1` 时同步旧版 `aw-delivery` skill 别名 |

## 快速开始

```bash
chmod +x scripts/*.sh
./scripts/init-project.sh
./scripts/check-aw-layout.sh
```

模板真源：`agent-workflow/templates/`。
