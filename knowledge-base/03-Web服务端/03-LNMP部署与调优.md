# LNMP 部署与调优

## 基础知识

LNMP 通常指 Linux + Nginx + MySQL + PHP。职责边界：

- Linux：进程、权限、网络、文件和资源管理。
- Nginx：TLS、静态文件、反向代理、限流和负载均衡。
- PHP-FPM：管理 PHP worker，执行动态请求。
- MySQL：持久化关系数据与事务。

Redis、消息队列和对象存储是常见扩展，但不是 LNMP 缩写的一部分。

## 基础配置

### Nginx 到 PHP-FPM

```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/app/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        try_files $uri =404;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_read_timeout 60s;
    }

    location ~ /\. {
        deny all;
    }
}
```

不要在 FastCGI location 中使用 `proxy_set_header`；那是 HTTP 反向代理指令。需要传递参数时使用 `fastcgi_param`。

### Vue 与 API 同域

```nginx
server {
    root /var/www/vue;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        try_files $uri $uri/ /api/index.php?$query_string;
    }

    location ~ ^/api/.+\.php$ {
        root /var/www/tp/public;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }
}
```

真实 ThinkPHP 入口路径和 URL 重写规则应按项目版本验证。更清晰的方式通常是 API 使用独立子域，减少 root/alias/rewrite 混合造成的路径错误。

## 高阶知识

### Nginx 进程与事件模型

- master：读取配置、绑定端口、管理 worker、处理信号和平滑升级。
- worker：事件循环处理连接和请求。
- `epoll`：通知描述符就绪，worker 再执行读写。

`worker_processes auto` 通常是合理起点。理论连接上限近似 `worker_processes × worker_connections`，但反向代理一次客户端请求可能同时占用上下游两个连接，还受文件描述符和内存限制。

一次代理请求可能经历客户端读取、请求缓冲、上游连接/写入、上游响应读取、响应过滤和客户端发送。缓冲可以用内存或临时文件隔离快慢两端：普通 API 往往受益，SSE/流式响应则通常需要关闭相应缓冲并及时 flush。关闭缓冲会让上游连接存活更久，不是免费的“实时开关”。

### `rewrite last` 与 `break`

- `last`：停止当前 rewrite，使用新 URI 重新进行 location 匹配。
- `break`：停止当前 rewrite 集，不重新做 location 匹配，继续当前 location 后续阶段。

能用 `try_files`、明确 location 或 `return` 解决时，不要堆叠 `if + rewrite`。

### PHP-FPM 容量

```text
max_children ≤ 分配给 FPM 的可用内存 / 单 worker 峰值 RSS
```

还要受到数据库连接数、CPU 和外部依赖容量约束。4 核 8G 配 250 个 worker 可能造成内存压力和调度开销；必须以实际 RSS、CPU time、队列和延迟决定。

### TLS 与真实 IP

只有直接可信的负载均衡/CDN 地址可加入 `set_real_ip_from`。信任过宽的私网或公网范围可能允许伪造客户端 IP。TLS 私钥权限最小化，证书自动续期后执行配置测试再 reload。

### Linux 服务管理的版本边界

现代主流发行版通常使用 systemd：用 unit、drop-in、`systemctl` 和 `journalctl` 管理服务。旧资料中的 `/etc/init.d/*`、`service` 和 SysV runlevel 仍可能出现在遗留系统，但不要与 systemd unit 混改。防火墙同样要区分 nftables、firewalld、ufw 与遗留 iptables 前端，先确认发行版实际后端。

## 使用案例

### 安全发布

1. `nginx -t` 或 `nginx -T` 验证配置。
2. 应用构建和测试。
3. 从负载均衡摘除少量实例。
4. 发布不可变版本并做健康检查。
5. 小流量验证错误率和延迟。
6. 逐步扩大，保留快速回滚版本。

不要在生产目录简单 `git pull` 后直接覆盖运行中代码；半更新状态、依赖变化和 PHP OPcache 都可能导致不一致。

### 日志轮转

使用 logrotate 管理切割、压缩、保留和 reload/reopen。只修改 `logrotate.timer` 的执行时间不会自动为自定义日志创建正确规则。

### 磁盘挂载

格式化和挂载必须针对同一设备或分区。原始笔记先写 `/dev/vdb1` 到 fstab、后格式化 `/dev/vdb`，存在破坏分区表和挂载失败风险。正确流程是确认目标 → 分区（可选）→ 格式化目标分区 → UUID 写入 fstab → `mount -a` 验证。

## 常见问题与排查

### `bind() to 0.0.0.0:80 failed`

用 `ss -lntp '( sport = :80 )'` 找占用者。若 Apache 占用，先确认业务依赖，再通过 systemd 停止/禁用或调整端口；不要仅反复重启 Nginx。

### 502

检查 FPM socket 是否存在、Nginx 用户权限、FPM 进程、listen queue、上游崩溃和 FastCGI 参数。

### 504

检查 FPM 慢日志、数据库锁、外部请求和超时预算。增大 `fastcgi_read_timeout` 只延后失败，不解决慢请求。

### 静态文件 404/API 路由错误

使用 `nginx -T` 查看生效配置；确认 `root` 与 `alias` 的路径拼接差异、location 优先级、文件权限和应用入口。

## 版本边界与学习验收

- 稳定原理：事件循环、反向代理、FastCGI、缓冲、连接与 worker 容量、最小权限、原子发布和证据链排障。
- 版本相关：TLS/HTTP 支持、Nginx 模块与默认值、PHP-FPM 参数、systemd unit、发行版路径和防火墙后端。
- 历史命令只用于明确的遗留环境；新配置必须先用 `nginx -t`/`nginx -T` 和隔离流量验证。

验收：计算客户端与上游连接对 fd 的占用；用 FPM 峰值 RSS 推导 `pm.max_children`；分别制造 socket 权限错误、FPM 队列饱和和上游超时，并从 Nginx/FPM/系统日志建立证据链。

来源线索见 [`raw_doc_` 原始资料主题索引](../99-原始资料主题索引.md)中的《Linux 服务器构建实战》和《Nginx 高性能 Web 服务器详解》，配置语义以目标 Nginx、PHP-FPM 和发行版文档为准。
