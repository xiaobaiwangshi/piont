# Agent 生产工程与可靠性

## 学习目标

生产 Agent 本质上是“模型参与决策的分布式业务系统”。本章把已有的 Web、MySQL、Redis、Kafka、任务系统、可观测性和安全经验映射到 Agent 的持久化、并发、恢复与发布流程。

## 最小数据模型

| 实体 | 关键字段 | 职责 |
|---|---|---|
| session | tenant/user、channel、created_at | 用户交互容器，不等于业务任务 |
| task | goal、status、budget、version、owner | 一次可恢复目标 |
| step | task_id、sequence、type、status、attempt | 一个确定边界的状态转换 |
| tool_call | step_id、tool/version、request_hash、idempotency_key、status | 工具执行与去重 |
| artifact | URI/hash、media_type、ACL、version | 报告、代码、文件等大产物 |
| event | task_id、sequence、type、payload_ref、trace_id | 不可变审计与回放依据 |
| approval | action_hash、approver、status、expires_at | 人工批准/拒绝 |

关系型数据库保存权威状态和唯一约束；Redis 可做短期缓存、限流和租约，但不应成为无法恢复的唯一任务状态。消息队列负责解耦和重投，不替代数据库业务状态。

## 状态与并发控制

任务可使用如下有限状态：

```text
pending → running → waiting_tool / waiting_human
        → completed / failed / cancelled / budget_exceeded
```

- 用乐观版本 `UPDATE ... WHERE id=? AND version=?` 防止旧 worker 覆盖新状态。
- 长任务用带过期时间的 lease + heartbeat；失联后由恢复器接管。
- 数据库唯一键约束 `(task_id, logical_step)` 和 tool idempotency key。
- 终态默认不可逆；重新执行创建新 attempt/task 并保留关联。

分布式锁只保护临界区，不能代替数据库约束、工具幂等和状态检查。

## 同步、异步、队列与事件

- 简短问答可同步/流式响应。
- 需要多个工具、超过 HTTP 超时或等待人工的任务转异步，立即返回 task ID。
- worker 每完成一个可靠边界就提交状态/checkpoint，再发布后续事件。
- 数据库状态与发消息之间使用 transactional outbox；消费端用 inbox/dedup 防重复。
- 延迟重试和死信队列必须保留原 task/step、错误类别和 attempt。

不要让一个 Web 请求持有数据库事务并等待模型或外部工具；这会占用连接、扩大锁时间，并在断连时留下不清楚的执行状态。

## 超时、重试与降级

重试只针对明确的临时故障，并设置最大次数、指数退避和 jitter。参数错误、权限拒绝、业务冲突不应自动重试。

```text
delay ≈ min(cap, base × 2^attempt) + random_jitter
```

写工具超时先查询幂等状态。Circuit Breaker 在依赖持续失败时快速失败，减少级联；恢复阶段用少量探测请求。Fallback 应声明质量变化，例如切换小模型、只读模式、无 rerank 或转人工，不能静默改变业务语义。

死信表示自动策略已经耗尽，不是垃圾桶；需告警、诊断、人工重放入口和保留期限。

## 流式输出、取消与背压

SSE/WebSocket 流应区分文本增量、工具状态、审批请求、错误和终态事件，并带递增 event ID，客户端断线可从已确认位置恢复或查询快照。

取消采用协作式传播：标记 task cancelled → worker 在安全点检查 → 取消可取消的模型/工具/job → 禁止新动作 → 保留已完成产物。外部副作用已经发生时返回真实结果和补偿选项，不能伪装“全部撤销”。

背压控制包括租户队列上限、全局并发、RPM/TPM、工具连接池、最大 SSE 连接和 admission control。过载时尽早返回排队/重试信息，避免积压把所有请求拖到超时。

## Pause、Resume 与孤儿清理

`waiting_human` 和 `waiting_tool` 是持久状态，不占 worker。恢复前验证审批是否过期、工具结果是否已到达、上下文/工具版本是否仍兼容。

后台扫描：租约过期的 running task、长时间无回调的 tool call、无人处理的审批、孤立 artifact 和超期 session。清理动作先标记和审计；业务副作用未知的任务转人工，不能直接删除记录。

## 全链路版本

一次可复现运行应关联：

- system prompt、模板和策略版本。
- 模型 provider/name/snapshot、采样参数和上下文限制。
- 工具名称、Schema、实现/服务版本和 MCP server 版本。
- 检索索引、embedding、chunk、语料和 ACL 版本。
- workflow/graph、代码发布和 feature flag 版本。
- 评测集、judge prompt/model 和评分规则版本。

模型服务可能在同名别名下升级；严格回归需要可固定的版本或至少记录实际响应元数据和发布时间窗口。

## 可观测性

指标分四层：

1. 业务：完成率、人工接管率、正确办理率、用户修正率。
2. Agent：步骤数、终止原因、重复动作、恢复次数、工具成功率。
3. 模型/RAG：token、TTFT、总延迟、引用、检索命中和结构化输出失败。
4. 系统：队列延迟、worker 利用率、错误率、连接池、限流和成本。

日志、指标和 trace 通过 task/step/tool_call/trace ID 关联。SLO 以用户结果定义，例如“95% 低风险知识问答在 8 秒内返回带引用答案”；不要只监控模型 API 200。

## 成本归因

每个 task 记录输入/输出 token、模型价格版本、检索/rerank、工具、存储和人工成本。粗略模型费用：

```text
cost = input_tokens / 1_000_000 × input_price
     + output_tokens / 1_000_000 × output_price
```

实际还可能有缓存输入、批处理、地域和供应商计费差异。按租户、功能、workflow/version 和成功/失败分摊，才能发现无限循环、无效长上下文和昂贵失败。

## 案例一：企业知识助手

链路：身份/租户 → 查询改写 → ACL 检索 → rerank → 引用回答 → 引用/权限校验。检索不可用时返回受限降级，不能改成无依据回答；文档版本变化通过索引版本和 trace 定位。

## 案例二：工单 Agent

模型分类并抽取字段，规则校验后进入固定状态机。信息不足时询问用户；高风险动作生成 approval；执行 API 使用工单 ID + logical step 幂等。超时先查询工单状态，再决定完成、重试或人工接管。

## 案例三：代码/运维助手

仓库读取、补丁、测试、部署是不同权限域。修改产生 artifact 和 diff；测试失败可有限修订；部署必须绑定 commit、环境和审批。shell 在受限 workspace、网络和资源预算内执行，秘密不进入模型上下文。

## 案例四：业务办理

以退款为例：资格查询 → 方案计算 → 用户确认 → 服务端重新校验 → 幂等退款 → 查询验证 → 通知。模型可解释政策和补充信息，金额、资格、收款对象和事务状态由业务服务决定。

## 故障恢复证据链

```text
现象：用户收到两次通知
→ 查 task/step/tool_call 与 idempotency key
→ 判断是队列重投、客户端重试还是工具超时
→ 核对通知服务是否持久化去重结果
→ 修复共享执行边界，不只在 Agent Prompt 写“不要重复”
→ 重放故障用例，验证同一 logical step 只有一个业务结果
```

## 常见误区

1. 保存聊天记录就能恢复：错误，还缺状态、版本和副作用结果。
2. Redis 锁能保证恰好一次：错误，锁过期和外部调用仍有窗口。
3. 任何失败都可重试：错误，永久错误和状态未知需分类处理。
4. 客户端断开等于任务取消：错误，取消必须传播并持久化。
5. 流式文本发完就是完成：错误，工具/验证可能仍未结束。
6. 同名模型一直相同：错误，provider 可能更新别名实现。
7. 只看平均延迟即可：错误，长尾、队列和人工等待决定体验。
8. 降级无需告知：错误，能力/证据变化必须显式呈现。

## 自测题与答案

1. **session 与 task 为什么分开？** 一次会话可产生多个独立、可恢复、不同终态的业务任务。
2. **lease 与乐观锁各解决什么？** lease 标识当前处理者并可超时接管，乐观锁阻止旧版本覆盖新状态。
3. **为何使用 outbox？** 让业务状态与待发送事件在同一数据库事务落盘，避免状态成功但消息丢失。
4. **取消为何是协作式？** 模型、队列和外部工具不共享一个可强杀事务，只能在边界传播并确认。
5. **SLO 为什么看业务结果？** 单个模型请求成功不代表检索、工具、验证和最终目标成功。
6. **成本为什么按失败归因？** 重试、循环和长上下文可能让失败任务成为主要成本来源。

版本边界：数据库、队列和状态机原则稳定；模型 provider、MCP、Agent 框架的 streaming、checkpoint、cancel API 会变化，必须按使用版本验证语义。
