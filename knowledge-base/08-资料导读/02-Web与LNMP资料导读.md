# Web 与 LNMP 资料导读

## 1. HTTP 与浏览器

- [HTTP Core](../../learning-materials/02-Web与服务端/http-core/) 是 HTTP 语义、缓存和消息规范的一级来源。
- [MDN Content](../../learning-materials/02-Web与服务端/mdn-content/) 适合从教程进入 HTML、CSS、JavaScript、HTTP 和 Web API。
- [WHATWG HTML](../../learning-materials/02-Web与服务端/whatwg-html/) 用于核对浏览器标准行为。
- [Everything curl](../../learning-materials/02-Web与服务端/everything-curl/) 用于理解 DNS、连接、TLS、代理、认证、重试和命令行验证。

推荐沿一次请求阅读：URL 解析 → DNS → TCP/QUIC → TLS → HTTP → 代理 → 应用 → 响应缓存 → 浏览器渲染。

## 2. PHP 服务端

- [PHP 中文文档](../../learning-materials/02-Web与服务端/php-doc-zh/) 用于快速学习。
- [PHP 英文文档](../../learning-materials/02-Web与服务端/php-doc-en/) 用于解决翻译缺失和版本歧义。

学习顺序：语言与类型 → 错误和异常 → Composer/自动加载 → HTTP 输入输出 → PDO → 会话和安全 → PHP-FPM 生命周期 → 性能分析。PHP 7.4 只用于维护遗留项目，新代码按 PHP 8.x 的类型、错误和弃用规则编写。

## 3. Nginx 与 LNMP

[Nginx 官方文档](../../learning-materials/02-Web与服务端/nginx-documentation/) 负责配置语义。结合现有 LNMP 文档，按以下层次学习：

1. master/worker、事件循环、连接和文件描述符。
2. server/location 匹配、静态文件、反向代理、FastCGI。
3. 超时、缓冲、请求体限制、缓存和负载均衡。
4. TLS、访问控制、限流和日志。
5. Nginx → PHP-FPM → MySQL/Redis 的超时预算和故障传播。

案例必须区分 `proxy_*` 和 `fastcgi_*` 指令，并说明 499、502、504 分别在哪一层产生。

## 4. Node.js 与现代前端

- [Node.js 官方文档源码](../../learning-materials/02-Web与服务端/nodejs-documentation/) 取代旧 Node.js 0.x 材料。
- [Vue 3 文档](../../learning-materials/02-Web与服务端/vue3-documentation/) 和 [React 文档](../../learning-materials/02-Web与服务端/react-documentation/) 用于补充已停止维护的 AngularJS 知识。

旧 jQuery、Bootstrap 和 AngularJS 文档保留作遗留项目参考，但不作为新项目默认方案。

## 5. 推荐实验

1. 用 curl 分解 DNS、连接、TLS、首字节和总耗时。
2. 配置 Nginx 静态文件、反向代理和 FastCGI，并分别制造上游拒绝、连接超时和读取超时。
3. 在 PHP-FPM 中观察 worker 饱和、慢请求和数据库连接等待。
4. 验证 HTTP 缓存头、Cookie 属性、CORS 和幂等重试。

## 6. 验收

- 能画出浏览器到数据库的请求链路和各层超时。
- 能从日志和抓包区分客户端、代理、应用和依赖故障。
- 能说明旧前端/PHP/Node.js 行为与现代版本的差异。
