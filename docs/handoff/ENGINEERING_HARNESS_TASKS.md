# Engineering Harness 增强任务清单

目标：在继续保持 `agent-workflow` 轻量、工具无关的前提下，把 skill 从“AI 编码流程”增强为“工程交付控制协议”的最小可用形态。

## P0：先补强 AI 执行可控性

| ID | 状态 | 任务 | 产出 | 完成标准 |
|----|------|------|------|----------|
| EH-P0-001 | ✅ | Agent 执行审计 | `aw audit`、`docs/audit/AGENT_TRACE.md` | 可记录任务、动作、决策、命令、结果、证据和人工确认点 |
| EH-P0-002 | ✅ | Policy-as-Code 最小门禁 | `aw policy`、`docs/policy/POLICY.yml`、`docs/policy/POLICY_DECISIONS.md` | 可检查高风险变更、依赖准入、安全/发布/生产相关确认项 |
| EH-P0-003 | ✅ | 权限与执行边界 | policy 模板字段、skill 规则 | 明确哪些路径/命令/操作需要确认，例外必须留痕 |

## P1：补齐交付控制面

| ID | 状态 | 任务 | 产出 | 完成标准 |
|----|------|------|------|----------|
| EH-P1-001 | ✅ | 安全与依赖准入 | `aw security`、`docs/security/SECURITY_FINDINGS.md`、`docs/security/DEPENDENCY_REVIEW.md` | 新依赖、安全扫描、secret/SCA/SAST/DAST 等发现可登记、可追踪 |
| EH-P1-002 | ✅ | 服务目录 | `aw service-catalog`、`docs/SERVICE_CATALOG.md` | 每个服务/模块有 owner、职责、API、数据、依赖、验证、部署和告警入口 |
| EH-P1-003 | ✅ | 发布与环境闭环 | `aw release`、`docs/release/RELEASE_RECORD.md`、`docs/release/ENVIRONMENTS.md` | 发布计划、环境、灰度、回滚、验证、CHANGELOG/tag 对齐 |

## P2：形成可度量平台基础

| ID | 状态 | 任务 | 产出 | 完成标准 |
|----|------|------|------|----------|
| EH-P2-001 | ✅ | DORA / Flow Metrics | `aw metrics`、`docs/metrics/DELIVERY_METRICS.md` | 能记录部署频率、变更前置时间、失败率、恢复时间，并可 `aw metrics summary` 汇总 |
| EH-P2-002 | ✅ | SLO / Incident / Runbook | `aw ops`、`docs/ops/` | 生产健康、告警、事故、复盘和 runbook 可追踪，`aw ops gate` 可阻断未关闭高危事故 |
| EH-P2-003 | ✅ | Feature Flag / 渐进发布 | `aw release flag`、`docs/release/FEATURE_FLAGS.md` | flag owner、默认值、灰度、kill switch、清理计划可记录 |

## P3：形成治理闭环

| ID | 状态 | 任务 | 产出 | 完成标准 |
|----|------|------|------|----------|
| EH-P3-001 | ✅ | 发布门禁聚合 Harness | `aw release gate` | 发布前聚合 CHANGELOG、Policy、Security、Service Catalog、Environment、Ops、Agents、Metrics |
| EH-P3-002 | ✅ | 严格 Policy 门禁 | `aw policy gate --strict`、`AW_POLICY_STRICT=1` | 高风险 diff / 依赖清单变更可从 warn 升级为 block |
| EH-P3-003 | ✅ | 端到端追溯链检查 | `aw trace check` | REQ、DSL、Plan、AT-T、TP、Bug、Changelog、Audit、Policy、Security、Release、Metrics、Ops、Agents 可统一检查 |
| EH-P3-004 | ✅ | Agent 文件边界冲突检测 | `aw agents gate [--strict]` | 检测多个 Agent allowed paths 重叠；默认 warn，strict 模式 block |
| EH-P3-005 | ✅ | 服务目录深度发现 | `aw service-catalog discover` 增强 | 自动识别入口、端口/脚本、API 路由、数据库/队列、依赖清单、日志/观测关键词 |

## 执行顺序

1. 先实现 P0/P1 的模板和 CLI 检查入口。
2. 接入 `aw init`、`aw check all`、`aw capabilities`、`skill/SKILL.md`、`skill/reference.md`、`agent-workflow/INVOCATION.md`。
3. 跑 `aw demo` / `aw check all` / `check-skill-package` 验证。
4. P3 已形成轻量闭环；后续根据真实项目使用频率，继续增强 Service Catalog 的语言专用解析和 Agent 冲突策略配置。
