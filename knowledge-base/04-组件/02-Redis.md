# Redis

## 基础知识

Redis 是内存数据结构服务器，适合低延迟访问、缓存、计数、排行榜、集合计算和轻量协调。它不是自动正确的“数据库加速器”；需要设计容量、一致性、过期和故障行为。

### 常用类型

| 类型 | 常见用途 |
|---|---|
| String | 缓存、计数、位图、分布式锁值 |
| Hash | 对象字段、稀疏属性 |
| List | 简单队列、时间线 |
| Set | 去重、关系、交并差 |
| Sorted Set | 排行榜、延迟队列、时间索引 |
| Stream | 消息流、消费者组 |
| Bitmap/HyperLogLog | 状态统计、近似去重计数 |
| Geo | 地理位置查询 |

原始笔记中的“Tag”若指 RediSearch Tag 字段，它属于 Redis Stack/RediSearch 模块，不是 Redis 核心类型。使用前需确认部署包含该模块。

### 命令执行与 I/O

Redis 的命令执行在单个分片上大多串行完成，避免大量共享状态锁。Redis 6 起可使用 I/O threads 处理部分网络读写；后台线程/子进程也负责释放、持久化等工作，因此简单称“Redis 完全单线程”不准确。

### 内部编码

Redis 会根据类型、元素数量和值大小选择紧凑编码或通用结构。新版本广泛使用 listpack、quicklist、哈希表、整数集合和跳表；旧笔记中的 ziplist 阈值与固定数字具有版本依赖，不能作为永久规则。

常见演进线索：Redis 5 引入 Stream；Redis 6 引入 ACL 与可选网络 I/O 线程；Redis 7 进一步使用 listpack 替代多处 ziplist，并提供 Functions 等能力。精确编码选择必须用目标版本的 `OBJECT ENCODING` 和配置验证。

#### String、SDS 与对象开销

Redis 字符串底层常使用 SDS，记录长度、可用空间和字符数组，支持二进制安全与常数时间取长度。一个键值的真实内存不只是 `key bytes + value bytes`，还可能包括：

- 全局字典条目和哈希表桶。
- key/value 的 Redis Object 与 SDS 头。
- 指针、对齐和 jemalloc size class 浪费。
- 过期字典条目。
- 复制缓冲、客户端缓冲、AOF 缓冲和内存碎片。

因此“1000 万个 10 字节值只需约 100MB”会严重低估。用真实样本验证：

```redis
MEMORY USAGE some:key SAMPLES 5
INFO memory
MEMORY STATS
```

抽样多个真实 key 后估算：

```text
数据内存 ≈ 平均 MEMORY USAGE × key 数量
进程 RSS ≈ 数据内存 + 缓冲/复制/碎片/模块/客户端等
```

容量规划需预留峰值、fork copy-on-write 和故障转移空间，不能把 `maxmemory` 设置到机器全部内存。

#### Dict、渐进式 rehash 与跳表

Redis 字典扩缩容时通常使用两张哈希表渐进搬迁：普通命令顺带迁移一部分桶，避免一次 rehash 长时间阻塞。迁移期间内存会暂时增加。

Sorted Set 在元素较少时可使用紧凑 listpack，超过配置阈值后通常由 dict + skiplist 组合：dict 快速按 member 定位 score，skiplist 支持按 score 排序和范围遍历。阈值应查询当前配置和版本，不使用旧笔记固定数字。

## 高阶知识

### 过期与淘汰

- 过期删除：惰性删除与主动周期扫描结合。
- 内存淘汰：达到 `maxmemory` 后按策略处理，如 noeviction、allkeys-lru、allkeys-lfu、volatile-ttl 等。

LRU/LFU 通常是近似采样算法。`noeviction` 不代表整个 Redis “不服务”，而是可能拒绝会增加内存的写命令，读命令仍可工作。

### 持久化

- RDB：某时点快照，恢复快，可能丢失快照后的数据。
- AOF：记录写命令，持久性可调，文件更大，需要重写。
- 混合持久化：结合 RDB 基础和 AOF 增量。

`fork` 期间写流量会触发 copy-on-write，内存和延迟风险必须监控。

### 复制、Sentinel 与 Cluster

- 主从复制：异步为主，提供读扩展和副本。
- Sentinel：监控、选主和客户端发现，不负责分片。
- Redis Cluster：固定 16384 个哈希槽分布到多个主节点，每个主节点可带副本。

原笔记中的 16348 是错误，正确是 16384。Cluster 多键操作要求键位于同一槽，可用 hash tag（如 `{user:1}:profile`）控制槽位；这与 RediSearch Tag 字段不是一回事。

槽位计算可概括为：

```text
slot = CRC16(key) mod 16384
```

若 key 含合法 `{...}`，只对花括号内非空内容计算。例如 `{user:42}:profile` 与 `{user:42}:orders` 位于同一槽，可执行需要同槽的多键命令。过度使用同一 hash tag 会形成单槽/单节点热点。

假设 3 个主分片平均分配槽位，每个主节点理论负责约 `16384 / 3 ≈ 5461` 个槽，但数据量不会自动均匀：槽数均匀不代表 key 数、value 大小和访问热度均匀。

### 事务与原子性

`MULTI/EXEC` 中命令按顺序执行且不会被其他客户端命令插入，但运行期某条命令失败不会回滚此前命令，因此不像关系数据库事务。`WATCH` 提供乐观并发控制；复杂原子操作可使用短小 Lua 脚本或 Redis Functions。

### 分布式锁

基本模式：

```text
SET lock_key unique_token NX PX ttl
```

释放时必须原子比较 token 后删除，避免删除别人的锁；长任务需要续期或 fencing token。单 Redis 锁无法在所有故障模型下提供严格互斥，关键数据仍要由数据库唯一约束、版本号或幂等机制兜底。

## 使用案例

### Cache Aside

读取：查缓存 → miss 查数据库 → 写缓存。写入：提交数据库 → 删除缓存。需要：

- 合理 TTL 和随机抖动。
- 空值短缓存或布隆过滤器防穿透。
- 热点互斥/逻辑过期防击穿。
- 限流、预热、多级缓存防雪崩。

“延迟双删”只能降低特定竞态概率，不是严格一致性协议。

### 排行榜

用 Sorted Set 的 score 排序，`ZINCRBY` 更新分数，`ZREVRANGE` 读取排名。并列规则、分数精度、赛季归档和重算来源应另行定义。

### 消息处理

List 适合简单工作队列；Stream 支持消费者组、pending 和确认，更适合可恢复消费。高吞吐持久消息和跨机房日志流通常使用 Kafka 等专用系统。

### Pipeline 的收益计算

不使用 pipeline 时，N 条命令的客户端延迟至少包含约 N 次网络往返；pipeline 把多条命令批量发送，再批量读取结果，主要节省 RTT 和系统调用：

```text
非 pipeline 时间 ≈ N × RTT + 服务端处理时间
pipeline 时间 ≈ 少量 RTT + 服务端处理时间
```

例如 RTT 1ms、100 条简单命令，串行网络等待可接近 100ms；一次 pipeline 的网络等待可降到约 1ms 量级。批次过大会增加客户端/服务端缓冲、单次延迟和其他请求等待，应分批实测。Pipeline 不提供事务原子性。

## 常见问题与排查

- 热 key：观察命令统计、延迟和业务访问分布；本地缓存、拆 key、复制读或业务分片。
- 大 key：渐进扫描和异步删除，修改数据模型，避免阻塞事件循环。
- 内存碎片：结合 used_memory、RSS、allocator 指标判断，不只看键大小。
- 延迟尖峰：检查慢命令、fork、AOF fsync、swap、透明大页和网络。
- 集群 MOVED/ASK：使用支持 Cluster 的客户端并刷新槽映射，不手写无限重试。

## 延伸阅读

- [数据系统内部机制](../07-核心机制深入/05-数据系统内部机制.md)
- [分布式系统核心](../07-核心机制深入/06-分布式系统核心.md)

## 版本边界与学习验收

- 旧资料中的 ziplist、配置名、默认阈值和持久化行为只作为历史线索；Redis 5/6/7 的 Stream、ACL、I/O threads、listpack、Functions 与 Cluster 行为需分别核对。
- 社区版、Redis Stack、云厂商兼容服务可能具有不同模块、命令、持久化和故障转移约束。
- `KEYS *`、大范围集合返回和长 Lua/Function 在小数据测试中无害，不代表生产安全。

验收：抽样真实 key 计算内存；构造热 key、大 key、缓存击穿、fork COW 与主从切换；记录命令延迟、事件循环阻塞、RSS、复制缓冲和客户端重试，再验证限流与恢复策略。

来源线索见 [`raw_doc_` 原始资料主题索引](../99-原始资料主题索引.md)中的《Redis 入门指南第2版》，当前命令和内部编码以目标 Redis 官方文档及实测为准。
