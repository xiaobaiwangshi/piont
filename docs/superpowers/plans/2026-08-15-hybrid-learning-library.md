# Hybrid Learning Library Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 下载可合法离线保存的系统教材、官方文档和实验资料，并生成与现有知识库衔接的中文导读和可追溯清单。

**Architecture:** 用一个 TSV 清单声明 GitHub 快照和官方文件；同步脚本把 GitHub 分支解析为固定提交后下载归档，并为每项生成 `SOURCE.md`。下载内容放在独立的 `learning-materials/`，整理结果只新增到 `knowledge-base/08-资料导读/`，不修改原始资料。

**Tech Stack:** POSIX shell、Git、curl、tar、Markdown、TSV

---

### Task 1: 建立可验证的来源清单

**Files:**
- Create: `config/learning-materials.tsv`
- Create: `scripts/sync-learning-materials.sh`

- [ ] **Step 1: 写入来源清单**

清单字段固定为：`type category name url ref version purpose`。写入以下完整内容（字段之间为 Tab）：

```tsv
type	category	name	url	ref	version	purpose
github	01-计算机基础	ossu-computer-science	https://github.com/ossu/computer-science	master	rolling	综合课程路线
github	01-计算机基础	cs-self-learning	https://github.com/PKUFlyingPig/cs-self-learning	master	rolling	中文自学路线
github	01-计算机基础	riscv-isa-manual	https://github.com/riscv/riscv-isa-manual	main	rolling	指令集与体系结构
github	01-计算机基础	nemu	https://github.com/NJU-ProjectN/nemu	master	rolling	计算机系统实验
github	01-计算机基础	ics-pa-gitbook	https://github.com/NJU-ProjectN/ics-pa-gitbook	master	rolling	南京大学PA讲义
github	01-计算机基础	xv6-riscv	https://github.com/mit-pdos/xv6-riscv	riscv	rolling	操作系统源码实验
github	01-计算机基础	xv6-riscv-book	https://github.com/mit-pdos/xv6-riscv-book	xv6-riscv	rolling	xv6教材源码
github	01-计算机基础	ostep-code	https://github.com/remzi-arpacidusseau/ostep-code	master	rolling	OSTEP配套示例
github	01-计算机基础	computer-networks-systems-approach	https://github.com/SystemsApproach/book	master	rolling	开放网络教材
github	01-计算机基础	open-data-structures	https://github.com/patmorin/ods	master	rolling	开放数据结构教材
github	01-计算机基础	cp-algorithms	https://github.com/cp-algorithms/cp-algorithms	main	rolling	算法原理与实现
github	01-计算机基础	the-algorithms-python	https://github.com/TheAlgorithms/Python	master	rolling	算法示例
github	01-计算机基础	linux-kernel	https://github.com/torvalds/linux	master	rolling	Linux实现参考
github	02-Web与服务端	http-core	https://github.com/httpwg/http-core	main	rolling	HTTP标准
github	02-Web与服务端	mdn-content	https://github.com/mdn/content	main	rolling	Web系统教程与参考
github	02-Web与服务端	whatwg-html	https://github.com/whatwg/html	main	rolling	HTML标准
github	02-Web与服务端	everything-curl	https://github.com/curl/everything-curl	master	rolling	网络客户端开放教材
github	02-Web与服务端	php-doc-zh	https://github.com/php/doc-zh	master	rolling	PHP中文手册
github	02-Web与服务端	php-doc-en	https://github.com/php/doc-en	master	rolling	PHP英文手册
github	02-Web与服务端	nginx-documentation	https://github.com/nginx/documentation	main	rolling	Nginx官方文档
github	02-Web与服务端	nodejs-documentation	https://github.com/nodejs/nodejs.org	main	rolling	Node.js官方文档
github	02-Web与服务端	vue3-documentation	https://github.com/vuejs/docs	main	3.x	Vue3官方文档
github	02-Web与服务端	react-documentation	https://github.com/reactjs/react.dev	main	rolling	React官方文档
file	03-数据库与中间件	mysql-5.7-manual	https://downloads.mysql.com/docs/refman-5.7-en.pdf	-	5.7	MySQL完整官方手册
file	03-数据库与中间件	mysql-8.0-manual	https://downloads.mysql.com/docs/refman-8.0-en.pdf	-	8.0	MySQL完整官方手册
file	03-数据库与中间件	mysql-8.4-manual	https://downloads.mysql.com/docs/refman-8.4-en.pdf	-	8.4	MySQL完整官方手册
github	03-数据库与中间件	mysql-server-8.0	https://github.com/mysql/mysql-server	8.0	8.0	MySQL源码参考
github	03-数据库与中间件	redis-docs	https://github.com/redis/docs	main	rolling	Redis官方文档
github	03-数据库与中间件	elasticsearch-docs	https://github.com/elastic/docs-content	main	rolling	Elastic官方文档
github	03-数据库与中间件	mongodb-docs	https://github.com/mongodb/docs	main	rolling	MongoDB官方文档
github	03-数据库与中间件	kafka	https://github.com/apache/kafka	trunk	rolling	Kafka文档与源码
github	03-数据库与中间件	rabbitmq-documentation	https://github.com/rabbitmq/rabbitmq-website	main	rolling	RabbitMQ官方文档
github	03-数据库与中间件	memcached	https://github.com/memcached/memcached	master	rolling	Memcached文档与源码
github	03-数据库与中间件	grpc-documentation	https://github.com/grpc/grpc.io	main	rolling	gRPC官方文档
github	03-数据库与中间件	thrift	https://github.com/apache/thrift	master	rolling	Thrift文档与源码
github	04-分布式与架构	design-patterns-php	https://github.com/RefactoringGuru/design-patterns-php	main	rolling	PHP设计模式案例
github	04-分布式与架构	java-design-patterns	https://github.com/iluwatar/java-design-patterns	master	rolling	设计模式案例库
github	04-分布式与架构	system-design-primer	https://github.com/donnemartin/system-design-primer	master	rolling	系统设计教程
github	04-分布式与架构	system-design-101	https://github.com/ByteByteGoHq/system-design-101	main	rolling	系统设计图解
github	04-分布式与架构	architecture-center	https://github.com/MicrosoftDocs/architecture-center	main	rolling	架构模式与案例
github	04-分布式与架构	openapi-specification	https://github.com/OAI/OpenAPI-Specification	main	rolling	API设计标准
github	04-分布式与架构	etcd	https://github.com/etcd-io/etcd	main	rolling	分布式一致性组件
github	04-分布式与架构	zookeeper	https://github.com/apache/zookeeper	master	rolling	分布式协调组件
github	04-分布式与架构	rocketmq	https://github.com/apache/rocketmq	develop	rolling	消息队列实现
github	04-分布式与架构	nacos	https://github.com/alibaba/nacos	develop	rolling	注册与配置中心
github	05-运维可观测性与安全	docker-docs	https://github.com/docker/docs	main	rolling	容器官方文档
github	05-运维可观测性与安全	kubernetes-website	https://github.com/kubernetes/website	main	rolling	Kubernetes官方文档
github	05-运维可观测性与安全	prometheus-docs	https://github.com/prometheus/docs	main	rolling	指标监控官方文档
github	05-运维可观测性与安全	opentelemetry-docs	https://github.com/open-telemetry/opentelemetry.io	main	rolling	可观测性官方文档
github	05-运维可观测性与安全	owasp-cheat-sheets	https://github.com/OWASP/CheatSheetSeries	master	rolling	Web安全实践
```

- [ ] **Step 2: 编写最小同步脚本**

脚本必须支持：

```text
--check       只校验清单格式、路径和重复项
--category X  只下载指定分类
--name X      只下载指定资料
--retry-failed 只重试失败项
```

GitHub 下载流程必须是：`git ls-remote` 解析分支提交 → `codeload.github.com` 下载该提交归档 → `tar` 解压 → 生成 `SOURCE.md`。文件下载使用 `curl --fail --location --retry 3`。单项失败写入 `learning-materials/download-failures.tsv`，不能删除已成功资料。

- [ ] **Step 3: 校验脚本语法与清单**

Run:

```bash
bash -n scripts/sync-learning-materials.sh
bash scripts/sync-learning-materials.sh --check
```

Expected: 两个命令退出码均为 0；清单无空字段、非法分类或重复本地名称。

### Task 2: 下载计算机基础教材、课程和实验

**Files:**
- Create: `learning-materials/01-计算机基础/**`

- [ ] **Step 1: 下载第一分类**

Run:

```bash
bash scripts/sync-learning-materials.sh --category 01-计算机基础
```

资料包括 OSSU、计算机自学指南、RISC-V ISA、NEMU、南京大学 PA 讲义、xv6 源码与教材、OSTEP 示例、Computer Networks: A Systems Approach、Open Data Structures、cp-algorithms 和 TheAlgorithms/Python。

- [ ] **Step 2: 验证教材、实验和算法三层均存在**

Run:

```bash
find learning-materials/01-计算机基础 -name SOURCE.md -print
```

Expected: 每个成功下载项目都有 `SOURCE.md`；失败项目明确进入失败清单。

### Task 3: 下载 Web、语言和 LNMP 资料

**Files:**
- Create: `learning-materials/02-Web与服务端/**`

- [ ] **Step 1: 下载第二分类**

Run:

```bash
bash scripts/sync-learning-materials.sh --category 02-Web与服务端
```

资料包括 HTTP Core、MDN、WHATWG HTML、Everything curl、PHP 中英文文档、Nginx 文档、Node.js 文档、Vue 3 和 React 文档。

- [ ] **Step 2: 验证文档正文存在**

Run:

```bash
find learning-materials/02-Web与服务端 -type f \( -name '*.md' -o -name '*.html' -o -name '*.xml' \) | head
```

Expected: 输出至少一个正文文件，且各项目不是只有 README。

### Task 4: 下载数据库与中间件资料

**Files:**
- Create: `learning-materials/03-数据库与中间件/**`

- [ ] **Step 1: 下载第三分类**

Run:

```bash
bash scripts/sync-learning-materials.sh --category 03-数据库与中间件
```

资料包括 MySQL 5.7、8.0、8.4 官方完整参考手册，MySQL 8.0 源码快照，以及 Redis、Elasticsearch、MongoDB、Kafka、RabbitMQ、Memcached、gRPC 和 Thrift 的官方文档或仓库。

- [ ] **Step 2: 验证 MySQL 三个版本彼此独立**

Run:

```bash
file learning-materials/03-数据库与中间件/mysql-5.7-manual/refman-5.7-en.pdf
file learning-materials/03-数据库与中间件/mysql-8.0-manual/refman-8.0-en.pdf
file learning-materials/03-数据库与中间件/mysql-8.4-manual/refman-8.4-en.pdf
```

Expected: 三项均识别为 PDF document，不是 HTML 错误页。

### Task 5: 下载设计、架构、运维和安全资料

**Files:**
- Create: `learning-materials/04-分布式与架构/**`
- Create: `learning-materials/05-运维可观测性与安全/**`

- [ ] **Step 1: 下载设计与架构资料**

Run:

```bash
bash scripts/sync-learning-materials.sh --category 04-分布式与架构
```

资料包括 PHP/Java 设计模式、System Design Primer、Azure Architecture Center、OpenAPI、etcd、ZooKeeper、RocketMQ、Nacos 和系统设计图解。

- [ ] **Step 2: 下载运维、安全与可观测性资料**

Run:

```bash
bash scripts/sync-learning-materials.sh --category 05-运维可观测性与安全
```

资料包括 Docker、Kubernetes、Prometheus、OpenTelemetry 和 OWASP Cheat Sheet 官方文档。

- [ ] **Step 3: 汇总失败项并重试一次**

Run:

```bash
bash scripts/sync-learning-materials.sh --retry-failed
```

Expected: 可恢复的网络失败被补齐；仍失败的来源保留原因。

### Task 6: 生成中文学习导航

**Files:**
- Create: `knowledge-base/08-资料导读/00-混合资料总览.md`
- Create: `knowledge-base/08-资料导读/01-计算机基础资料导读.md`
- Create: `knowledge-base/08-资料导读/02-Web与LNMP资料导读.md`
- Create: `knowledge-base/08-资料导读/03-数据库与中间件资料导读.md`
- Create: `knowledge-base/08-资料导读/04-架构运维与安全资料导读.md`
- Create: `knowledge-base/08-资料导读/05-版本矩阵与迁移路线.md`
- Create: `learning-materials/README.md`
- Create: `learning-materials/manifest.tsv`

- [ ] **Step 1: 从实际下载结果生成 manifest**

Run:

```bash
bash scripts/sync-learning-materials.sh --manifest
```

Expected: 每行包含分类、资料名、URL、请求 ref、固定提交或版本、本地路径、状态和许可证文件位置。

- [ ] **Step 2: 编写五篇导读和离线资料入口**

每篇按“前置知识 → 基础教材 → 深入机制 → 实验案例 → 解决的问题 → 版本注意 → 验收”组织，链接只指向实际存在的本地目录或明确标记的外部资料。

- [ ] **Step 3: 标记社区资料的权威等级**

官方标准/官方文档标记为一级来源；开放教材和大学课程标记为二级来源；社区总结只作三级辅助来源，不能覆盖一级来源结论。

### Task 7: 完整性与安全验收

**Files:**
- Create: `learning-materials/verification-report.md`
- Create: `scripts/check-learning-links.sh`

- [ ] **Step 1: 检查空文件、错误页和来源记录**

Run:

```bash
bash scripts/sync-learning-materials.sh --verify
```

Expected: 报告资料总数、成功数、失败数、缺失 `SOURCE.md` 数、空文件数和可疑 HTML 错误页数。

- [ ] **Step 2: 检查 Markdown 内部链接**

Run:

```bash
bash scripts/check-learning-links.sh
```

Expected: 退出码 0；所有新增导读中的本地相对链接均存在。

- [ ] **Step 3: 确认原始资料没有被本任务修改**

Run:

```bash
git status --short -- raw raw_doc
```

Expected: 不出现本任务产生的已跟踪修改或删除；`applet.zip` 不出现在 manifest 和导读中。

- [ ] **Step 4: 检查最终容量和文件数量**

Run:

```bash
du -sh learning-materials
find learning-materials -type f | wc -l
```

Expected: 容量不超过当前约 48 GiB 可用空间，文件数大于零，并在验证报告记录实际数值。
