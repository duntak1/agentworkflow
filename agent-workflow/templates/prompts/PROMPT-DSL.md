# DSL 生成提示词（路径 A / B / C）

> 由 `./scripts/aw dsl` 拼入对话。模板真源：`agent-workflow/templates/dsl/`。

## 路径 A：仅需求 / 规格 MD → DSL

```text
你是资深产品 + 前端规格作者。请只根据【输入】撰写 DSL 草案（Markdown），保存到 docs/dsl/ 下指定文件。

【输入】
- 规格：@reference/inputs/ 与 @docs/requirements/ 中本轮 REQ。
- 骨架：@docs/dsl/DSL_SPEC_TEMPLATE.md；按路由拆页时用 @docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md。
- 省 token：每轮最多读取 3 个 reference 输入文件；大型材料先生成摘要 / 待确认清单，再分批补充 DSL。

【输出必须包含】
1. 元数据：名称、短标识、版本、关联 REQ、状态（草稿）。
2. 背景、用户场景、概念模型、不在范围内、成功标准。
3. 路由与信息架构（若有前端）。
4. 主屏业务组件清单；OV-ID 叠加层总表（无则写「无」）。
5. 可检查验收条目；notes / 待确认（禁止编造路径）。

【多文件 DSL 套件】
复杂项目优先使用 `aw dsl suite <slug> "title"`，并填写：
- `INDEX.md`：元数据与文件索引
- `00-requirements.md`：需求描述 / 用户 / 场景 / 范围
- `10-pages.md`：页面结构 / 路由 / 组件 / 信息架构
- `20-interactions.md`：交互行为 / 状态 / 权限 / 空态异常
- `30-events.md`：事件 / 输入输出 / 副作用 / 失败处理
- `40-boundaries.md`：联动边界 / 模块边界 / 接口契约
- `90-acceptance.md`：全量可检查验收

【禁止】不写 token/主题全文；不输出实现代码。
```

## 路径 B：设计说明 → DSL

```text
你是资深产品 + 前端规格作者。把【输入】设计说明译为研发 DSL，不新增设计未出现的页面或主流程。

【输入】
- 设计说明：@reference/inputs/ 中设计导出 MD。
- 骨架：@docs/dsl/FRONTEND_PAGE_SPEC_TEMPLATE.md。

【输出必须包含】
元数据、导航路由、每路由布局与交互、OV-ID 表、响应式文字分支、待确认列表。

【禁止】不写像素级样式；无参考工程时源码列写「无」。
```

## 路径 C：参考源码（± 规格）→ DSL

```text
你是资深前端 + 规格作者。根据【输入】参考源码撰写/更新 DSL，路径须存在于 reference/ 下。

【输入】
- 源码：仅 @reference/source/ 或 manifest 中列出的真实路径。
- 可选范围：@docs/requirements/ REQ。
- 省 token：先读 manifest 和目录/入口摘要，只读取与本轮 DSL 相关的源码文件；禁止把参考源码整仓塞入上下文。

【输出必须包含】
元数据、诚实边界、路由×源文件清单、主屏组件表、OV-ID 表、§BP 数据接入约定、notes。

【禁止】禁止编造仓库内不存在的路径。
```
