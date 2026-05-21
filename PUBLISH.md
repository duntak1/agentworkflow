# 发布与安装 agent-workflow Skill

## 产物是什么

| 位置 | 内容 |
|------|------|
| `skill/SKILL.md` | Skill 主文件（真源，sync 时拷贝） |
| `~/.cursor/skills/agent-workflow/` | 个人 Skill：scripts + templates + `package/` |
| 业务仓 `agent-workflow/` | `aw install` 从 skill 或源码仓拷贝的政策包 |

## 本机安装（开发者）

```bash
git clone <repo-url> agentworkflow && cd agentworkflow
./scripts/sync-skill.sh
# 可选：AW_SYNC_PROJECT_SKILL=0 跳过写入 .cursor/skills/
```

校验：

```bash
./scripts/check-skill-package.sh
# 或
~/.cursor/skills/agent-workflow/scripts/check-skill-package.sh
```

## 用户安装（无需 clone 全仓）

```bash
# 方式 A：本地路径
/path/to/agentworkflow/scripts/install-cursor-skill.sh

# 方式 B：远程仓库（直接传 URL）
./scripts/install-cursor-skill.sh https://github.com/duntak1/agentworkflow.git

# 方式 C：远程仓库（环境变量，适合 README/CI）
export AW_SKILL_REPO_URL=https://github.com/duntak1/agentworkflow.git
./scripts/install-cursor-skill.sh

# 可选：指定分支或 tag
AW_SKILL_REF=v1.1.0 ./scripts/install-cursor-skill.sh https://github.com/duntak1/agentworkflow.git
```

## 接入业务项目（任意 IDE）

```bash
cd /path/to/your-app
/path/to/agentworkflow/scripts/aw install . --adapters
chmod +x scripts/aw scripts/*.sh
./scripts/aw init && ./scripts/aw status
./scripts/aw hooks   # 可选
```

`--adapters` 会生成：`CLAUDE.md`、`AGENTS.md`、Copilot、Cursor、Windsurf、Cline、Continue 入口文件（已存在则跳过）。

仅 Cursor 额外可选：`./scripts/sync-skill.sh`（个人 Skill，非必须）。

## 项目级 Skill（团队共享）

在业务仓提交 `.cursor/skills/agent-workflow/`（由 `sync-skill` 生成到源码仓，或 `install-cursor-skill` 后复制）。

或在业务仓 `package.json` / README 中记录：

```bash
./scripts/install-cursor-skill.sh /path/to/agentworkflow
# 或
./scripts/install-cursor-skill.sh https://github.com/duntak1/agentworkflow.git
```

## 发版 checklist

1. 更新 `agent-workflow/VERSION` 与 `CHANGELOG.md`
2. `./scripts/check-skill-source.sh`
3. `./scripts/e2e-smoke.sh`
4. `./scripts/build-skill-archive.sh` → `dist/agent-workflow-skill-<version>.tar.gz`
5. `git tag v1.x.x && git push --tags`（触发 [`.github/workflows/release.yml`](.github/workflows/release.yml) 上传 Release 资产）

## GitHub Actions 模板

业务仓可复用本仓模板：

```yaml
name: agent-workflow

on:
  pull_request:
  push:
    branches: [main]

jobs:
  aw:
    uses: <org>/<repo>/.github/workflows/agent-workflow-reusable.yml@main
    with:
      run_e2e_smoke: true
```

### 从 Release  tarball 安装

```bash
mkdir -p ~/.cursor/skills/agent-workflow
tar -xzf agent-workflow-skill-1.0.0.tar.gz -C ~/.cursor/skills/
# 解压得到 ~/.cursor/skills/agent-workflow/
```

## 别名

`~/.cursor/skills/aw-delivery/` 与 `agent-workflow` 内容相同，仅 `name:` 不同（兼容旧触发语）。
