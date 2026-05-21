# MOCK_SERVER

## Mock 策略

| 字段 | 内容 |
|------|------|
| **OpenAPI 文件** | docs/contracts/API_CONTRACT.openapi.yaml |
| **Mock 工具** | 待确认 |
| **启动命令** | 待确认 |
| **端口** | 待确认 |
| **数据来源** | 待确认 |

## 规则

- 前端依赖后端接口前，必须优先对齐 OpenAPI。
- 后端改接口前，必须记录 API_CHANGELOG，并通知前端 Agent。
- 字段删除、类型变化、错误码变化属于破坏性变更，必须走 `aw contract change --breaking`。
