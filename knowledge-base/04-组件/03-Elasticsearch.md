# Elasticsearch

原始资料几乎没有系统性的 Elasticsearch 内容，本篇作为按现有 Web 服务端方向补充的基础框架。

## 基础知识

Elasticsearch 是基于 Lucene 的分布式搜索与分析引擎。适合全文搜索、日志检索、聚合分析，不替代所有关系数据库事务。

### 核心概念

- Index：逻辑文档集合。
- Document：JSON 文档。
- Field：文档字段。
- Mapping：字段类型和索引规则。
- Shard：索引的物理分片。
- Replica：分片副本，用于高可用和读扩展。

### 倒排索引

倒排索引从“词 → 包含该词的文档”组织数据。文本字段先经过 analyzer：字符过滤、分词和 token 过滤。`text` 用于全文检索，`keyword` 用于精确匹配、排序和聚合。

### 查询与过滤

- Query context：计算相关性分数，例如 `match`。
- Filter context：只判断是否匹配，适合范围、状态和权限过滤，通常更易缓存。
- `term` 用于精确 token，不应直接拿来搜索经过分词的自然语言 text。

## 高阶知识

### 写入与可见性

文档先进入内存缓冲和 translog，refresh 后生成可搜索 segment，因此 Elasticsearch 是近实时搜索，不是每次写入立刻对搜索可见。flush、refresh 和 merge 是不同操作。

- refresh：打开新的 segment 供搜索，频繁 refresh 会产生更多小 segment。
- flush：推进持久化边界并开始新的 translog generation，不等同于 refresh。
- merge：合并不可变 segment、回收删除标记，会消耗 I/O、CPU 和临时磁盘。

写入吞吐、可见延迟和 merge 压力互相制约。批量导入可暂时调整 refresh interval，但恢复设置前要验证搜索可见性和故障恢复要求。

### 分片设计

分片不是越多越好。过多分片增加堆内存、文件句柄、协调和恢复成本；分片过大则迁移恢复慢。根据数据量、增长、查询并发、节点数和恢复目标规划，并通过 rollover/ILM 管理时间序列数据。

分片大小没有跨场景固定答案。容量设计至少计算：每日原始数据、索引膨胀比例、副本数、保留天数、segment merge 临时空间、磁盘水位和目标恢复时间；再用真实 mapping 与查询压测。

### 一致性与主数据

MySQL 常作为业务真相源，Elasticsearch 作为可重建搜索视图。同步方式：

- 应用双写：简单但存在部分失败。
- Outbox + 消费者：可靠、可重试。
- CDC 读取 binlog：对业务侵入小，但需处理顺序、Schema 和重放。

所有方式都应有版本号、幂等 upsert、补偿重建和一致性巡检。

### 深分页

`from + size` 深分页会让各分片保留大量候选结果。用户连续翻页使用 `search_after` + 稳定排序；需要一致视图可结合 PIT。批量导出按官方当前版本推荐方式处理，不使用过时 scroll 作为普通分页。

## 使用案例

### 商品搜索

- `name`：text + keyword 多字段。
- `category_id/status`：keyword/integer 过滤。
- `price`：scaled_float 或合适数值类型。
- 拼音、同义词和分词器在索引设计阶段确定。

先满足召回，再调相关性；不要用大量脚本评分掩盖数据和 mapping 问题。

### 日志检索

使用数据流、生命周期策略、时间字段和结构化日志。敏感字段在进入集群前脱敏；高基数字段和动态 mapping 失控会显著增加资源成本。

## 常见问题与排查

- 集群 yellow：通常有副本未分配；单节点环境可解释，但生产要查分配原因。
- 集群 red：主分片不可用，优先保护数据并查看 allocation explain。
- JVM 堆高：检查聚合、字段基数、mapping、分片数和查询并发，不盲目扩大堆。
- 写入拒绝：线程池/队列饱和，检查下游磁盘、refresh、批量大小和背压。
- 查询慢：用 profile、slow log，检查分片扇出、脚本、深分页和排序字段。

## 延伸阅读

- [数据系统内部机制](../07-核心机制深入/05-数据系统内部机制.md)：Lucene segment、merge、BM25、WAL 对比与容量估算。

## Elasticsearch 7.x 与 8.x 边界

- mapping type 在 7.x 已进入移除路径，8.x 不应再按多 type 索引设计。
- 8.x 新集群的安全功能和 TLS 默认体验与旧版不同，客户端连接配置不能直接照搬 2.x/5.x/7.x 教程。
- 查询 DSL、聚合、ILM、模板、数据流、向量搜索和许可证能力会随小版本变化。
- `_all`、旧模板语法、旧 Zen discovery 等历史配置不得直接复制到现代集群。

验收：为一组真实文档设计显式 mapping；测量 refresh 前后可见性；比较单分片/多分片查询扇出；制造磁盘水位、未分配副本和写入拒绝，并用 allocation explain、节点/索引指标恢复。

本主题主要依据 [Elastic 官方文档](../08-资料导读/03-数据库与中间件资料导读.md)补全；旧 Elasticsearch 资料只用于识别历史配置，不作为当前默认值来源。
