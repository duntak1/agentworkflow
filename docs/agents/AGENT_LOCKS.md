# AGENT_LOCKS

> 多 Agent 任务锁。每个 Agent 开始任务前必须 claim，完成 / 阻塞 / 交接时释放或转移。

| Task | Agent | Role | Scope | Allowed Paths | Status | Claimed At | Expires At | Heartbeat | Notes |
|------|-------|------|-------|---------------|--------|------------|------------|-----------|-------|
