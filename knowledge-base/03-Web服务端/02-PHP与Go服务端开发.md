# PHP 与 Go 服务端开发

## 基础知识

### PHP 请求模型

传统 LNMP 中，Nginx 通过 FastCGI 把动态请求交给 PHP-FPM：

```text
Nginx → FastCGI → PHP-FPM master → 空闲 worker → PHP 脚本 → 响应
```

FastCGI 是协议，PHP-FPM 是管理 PHP FastCGI worker 的进程管理器，两者不是同一个概念。

PHP-FPM 常见模式：

- `static`：固定 worker 数，容量稳定、内存可预测。
- `dynamic`：按空闲 worker 范围伸缩。
- `ondemand`：有请求时创建，适合低流量多池，冷启动延迟更高。

`pm.max_children` 必须依据单 worker 的真实峰值 RSS、机器可用内存和下游容量计算，不能按“每核固定多少进程”套公式。

### PHP 语言重点

- 数组是有序哈希表，功能强但内存成本高。
- `+` 是数组联合：保留左侧已有键；`array_merge` 对字符串键覆盖、数字键重新编号。
- `foreach` 引用变量在循环后仍保持引用，应 `unset($value)`。
- 生成器 `yield` 可流式处理数据，减少一次性内存占用。
- PCNTL 适合 CLI/Unix 多进程，不用于普通 FPM 请求内随意派生后台任务。
- PHP 8 的 Attribute 是语言级元数据；PHP 7 常见“注解”多由 DocBlock 库解析。

旧版 PHP 面向对象资料中仍可保留封装、组合、异常边界、反射和依赖注入思想，但代码必须按 PHP 8.x 复核：

- PHP 8 支持 union/intersection 等更丰富的类型表达，类型错误通常抛出 `TypeError`。
- 动态属性在 PHP 8.2 起被弃用（特定例外除外），应声明属性或使用明确的数据结构。
- 构造函数使用 `__construct`；与类同名的 PHP 4/早期 PHP 5 风格不能作为现代示例。
- 正则由 PCRE/PCRE2 提供，没有 JavaScript 式 `g` 修饰符；全局匹配使用 `preg_match_all`。
- `strict_types` 作用于调用处的标量类型强制规则，不会把 PHP 变成全局静态类型语言。

### Go 请求模型

Go HTTP 服务通常由少量操作系统线程承载大量 goroutine。运行时使用 GMP 调度：

- G：goroutine。
- M：操作系统线程。
- P：执行 Go 代码所需的调度资源。

goroutine 很轻，但不是免费。必须有退出条件、并发上限和取消机制。

### Go 语言重点

- 接口由方法集隐式实现，优先小接口。
- 接口值包含动态类型和动态值；装有 `nil` 指针的接口本身可能不等于 `nil`。
- 内嵌是组合与方法提升，不是继承。
- map 的键必须可比较；值可以是任意类型，包括 slice 和 map。原笔记中“映射的值必须可比较”是错误的。
- `context.Context` 用于取消、截止时间和请求范围数据；应作为第一个参数传递，不存入结构体作通用参数袋。
- channel 用于协调和传递所有权；互斥锁适合保护共享状态。不要机械套用“通过通信共享内存”。

## 高阶知识

### 错误处理

PHP 应区分可预期业务错误、基础设施错误和编程错误；统一异常边界记录上下文并返回安全响应。

Go 使用显式 `error`：

- 用 `%w` 包装并保留错误链。
- 用 `errors.Is` 判断已知错误，用 `errors.As` 提取具体类型。
- panic 用于不可恢复的程序不变量，不作为普通业务分支。
- goroutine 内 panic 不会自动被 HTTP recovery 中间件捕获，应在 goroutine 自己处理。

### 并发控制

并发数应受资源约束：

```go
sem := make(chan struct{}, 8)
for _, task := range tasks {
    sem <- struct{}{}
    go func(task Task) {
        defer func() { <-sem }()
        process(task)
    }(task)
}
```

生产代码还需要 `WaitGroup`/`errgroup`、context 取消和错误收集。循环变量捕获问题在新旧 Go 版本语义不同，仍建议显式传参以便代码清楚。

### 依赖注入

PHP/Laravel 容器和 Go 构造函数注入解决相同问题：装配依赖。业务对象不应到处主动访问全局容器。

## 使用案例

### Gin 处理器边界

```go
type CreateUserRequest struct {
    Email string `json:"email" binding:"required,email"`
}

func CreateUser(c *gin.Context) {
    var req CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
        return
    }
    // 调用显式注入的 service
}
```

注意 Gin 的方法名区分大小写：`GET`、`ShouldBind`、`ShouldBindUri`、`StatusOK`。原始 Gin 笔记存在 `Get`、`bind`、`ShouldBindUrl`、`JOSN` 等拼写错误，不能直接编译。

### PHP 多数据库写入

两个独立 MySQL 实例的本地事务不能组成真正原子事务。依次提交会出现第一个成功、第二个失败。优先选择：

1. 单库事务内完成核心一致性。
2. outbox + 消息消费者实现最终一致性。
3. 补偿和对账处理失败。
4. 只有强需求才评估 XA，并理解性能与运维成本。

## 常见问题与排查

- FPM 队列增长：查看空闲 worker、listen queue、慢日志和下游延迟，不先盲目增大进程数。
- Go goroutine 泄漏：检查阻塞 channel、未取消 context、无界任务和网络 body 未关闭。
- PHP 内存增长：用真实请求分组统计，检查大数组、静态缓存、循环引用和扩展。
- Go 数据竞争：使用 `go test -race`，明确共享状态所有权。
- 第三方上传中断：本地进度不等于服务端已确认进度；使用供应商支持的可恢复上传协议和服务端返回的 offset/session。

## 延伸阅读

- [服务端运行时与 Web 核心机制](../07-核心机制深入/04-服务端运行时与Web.md)：Nginx 阶段、PHP OPcache/内存、Go netpoll/逃逸/GC、身份与 API 演进。

## 版本边界与学习验收

- PHP 示例以 8.x 为主，遗留项目需分别核对 7.4/8.0/8.1/8.2+ 的类型、弃用和扩展兼容性。
- Go 的循环变量、标准库 API、运行时调度和 GC 会演进；语言保证与实现细节要分开说明。
- 框架方法名、绑定行为、中间件顺序和默认安全配置必须按项目锁定版本验证。

验收：计算 FPM worker 内存上限并用 status/slowlog 验证；为 PHP 和 Go 各实现一个带超时、取消、参数验证和错误映射的 API；制造 goroutine 泄漏或 FPM 排队并用证据定位。

来源线索见 [`raw_doc_` 原始资料主题索引](../99-原始资料主题索引.md)中的《PHP 高级编程》和《正则》，当前行为以 PHP、PCRE2、Go 与框架官方文档为准。
