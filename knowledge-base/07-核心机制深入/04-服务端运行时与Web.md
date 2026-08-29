# 服务端运行时与 Web 核心机制

## Nginx 请求阶段

Nginx HTTP 请求不是只做一次 location 匹配，可概括为：读取请求 → server/location 选择 → rewrite → access → content → filter → log。模块把处理器挂到不同阶段，rewrite 的内部重定向可能重新匹配 location。

### 缓冲与背压

- 请求缓冲：Nginx 可先读完客户端 body，再交上游，保护慢上传影响上游。
- 响应缓冲：Nginx 可快速读完上游，慢慢发给客户端，释放上游 worker。
- 流式接口：SSE/大模型输出需关闭相关缓冲并及时 flush，但会让上游连接保持更久。

缓冲本质是用内存/磁盘和延迟隔离上下游速度。关闭缓冲不是通用性能优化。

### 排队与容量边界

Nginx 能维持大量等待连接，不代表 PHP-FPM、Go handler、数据库连接池也能无限并发。请求在监听队列、FPM listen queue、应用 semaphore、连接池和消息队列中的任一处排队，都会增加长尾延迟。

排查时记录每层“正在执行、等待数量、等待时间、拒绝数量和上限”，再决定扩容、限流或减少下游耗时。只增加最外层连接数通常只是把故障推迟并放大。

## PHP 生命周期

典型 FPM worker 对每个请求执行：初始化请求环境 → 解析/加载脚本 → 执行 → shutdown/destructor → 请求级内存回收。worker 进程会复用，但普通请求变量不会自动跨请求保留。

### OPcache

PHP 源码解析并编译为 opcode；OPcache 缓存编译结果，减少重复解析。发布需设计：

- 文件时间戳验证与 revalidate 周期。
- 原子切换发布目录，避免半新半旧。
- 必要时 reset/warmup，但 reset 会带来抖动。
- preload 适合稳定类库，变更与内存治理更复杂。

### PHP 内存

PHP array 是通用有序映射，存大量整数的成本远高于紧凑 C 数组。批量处理优先生成器、游标和流；但数据库 unbuffered query 会长期占连接，需在内存和连接占用间取舍。

## Go 运行时

### GMP 与 netpoll

goroutine 发起可由 runtime netpoll 管理的非阻塞网络 I/O 时，G 可被挂起，M/P 继续运行其他 G；I/O 就绪后 G 重新进入可运行队列。普通文件 I/O、CGO 或某些系统调用可能阻塞线程，runtime 会按需调度其他 M。

### 逃逸与分配

编译器决定值在栈还是堆上，返回指针不必然错误，逃逸到堆也不必然慢。用 `go build -gcflags=-m` 查看分析，用 benchmark 的 `allocs/op` 判断是否值得优化。

### GC

Go 使用并发标记清扫并包含短暂 STW 阶段。GC 成本与堆大小、分配速率和指针数量相关。对象池可能降低分配，也可能持有大对象和增加复杂度；只有 profile 证明后使用。

## Web 身份状态

### Session 与 Token

- 服务端 Session：浏览器保存随机 session id，状态在 Redis/数据库；易撤销，服务端有状态。
- 自包含 Token：验证不必查会话库，但撤销、权限变化和泄露窗口更复杂。
- OAuth 2.0：授权框架；OpenID Connect 在其上增加身份层。JWT 只是 Token 格式，不等于 OAuth。

浏览器 Cookie 建议使用 Secure、HttpOnly、SameSite，并有 CSRF 设计。Token 不应长期放在容易被 XSS 读取的 localStorage 中而不评估风险。

## API 演进

- Schema 变更优先增加可选字段，旧客户端忽略未知字段。
- 删除/改义需要版本和弃用窗口。
- 分页使用稳定排序；高写入数据用 cursor/keyset 避免 offset 漂移和深分页。
- 错误响应包含稳定机器码、可读消息和 request_id，不泄露堆栈/SQL。

## 设计从模式走向领域

设计模式解决局部结构；领域建模解决业务规则归属：

- Entity 有身份和生命周期。
- Value Object 以值相等，适合金额、时间区间等。
- Aggregate 定义强一致边界。
- Domain Event 表示已发生事实。

不需要为简单后台 CRUD 套完整 DDD。核心是把不变量放在明确位置，不让 Controller、SQL 和消息消费者各写一份规则。

## 验证实验

1. 对同一 SSE 接口分别开启/关闭代理缓冲，观察首字节与连接占用。
2. PHP 开关 OPcache，对比冷启动和稳态吞吐。
3. Go 用 pprof 比较无界 goroutine 与固定并发池的内存/延迟。
4. 构造重复幂等键，验证 API 只产生一个业务结果。

5. 用浏览器 Performance 面板对 DOM 变更前后比较 style、layout、paint 和 composite 时间，避免把服务端快误当成页面快。
6. 固定下游容量，逐步增加 Nginx/FPM/Go 并发，观察排队位置和 p95/p99 何时突增。

来源与版本边界见 [`raw_doc_` 原始资料主题索引](../99-原始资料主题索引.md)。浏览器实现、Nginx 阶段、PHP/Go 运行时和框架默认值都属于版本相关内容，必须记录测试版本。
