# Core Knowledge Fusion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the approved legacy and current references into a coherent Chinese learning path inside `knowledge-base/`.

**Architecture:** Existing topic chapters remain canonical. Stable principles from `raw_doc_` are merged into those chapters, version-sensitive claims are corrected against `learning-materials/`, and one source index records provenance and page-selection status; no source is copied verbatim and no raw file is changed.

**Tech Stack:** Markdown, Poppler 26.04.0, Tesseract 5.5.2 with `tesseract-lang` 4.1.0, sevenzip 26.02, shell link checks.

---

### Task 1: Build the source-to-topic index

**Files:**
- Create: `knowledge-base/99-原始资料主题索引.md`
- Modify: `knowledge-base/99-勘误与来源.md`

- [ ] **Step 1:** Inventory all 15 files in `raw_doc_` with type, page count where applicable, text-layer status, stable topics, version risks, and target knowledge-base chapters.
- [ ] **Step 2:** Record the extraction rule: text PDFs use `pdftotext -layout`; scanned PDFs use targeted 300-DPI rendering and `chi_sim+eng`; ZIP/CHM expand only under `tmp/`.
- [ ] **Step 3:** Link the new index from `99-勘误与来源.md`.
- [ ] **Step 4:** Verify the raw directory still contains exactly the original 15 files and no generated sidecars.

### Task 2: Fuse the four computer-science foundations

**Files:**
- Modify: `knowledge-base/01-基础/01-计算机组成原理.md`
- Modify: `knowledge-base/01-基础/02-计算机网络.md`
- Modify: `knowledge-base/01-基础/03-操作系统.md`
- Modify: `knowledge-base/01-基础/04-数据结构与算法.md`
- Modify: `knowledge-base/07-核心机制深入/01-硬件与操作系统.md`
- Modify: `knowledge-base/07-核心机制深入/02-协议栈与网络性能.md`
- Modify: `knowledge-base/07-核心机制深入/03-数据结构与算法工程.md`

- [ ] **Step 1:** Add instruction execution, storage hierarchy, cache locality, interrupts, DMA, virtual memory, scheduling, filesystems, and I/O evidence chains without duplicating the deep-mechanism chapters.
- [ ] **Step 2:** Add TCP sliding/receive/congestion windows, slow start, congestion avoidance, retransmission, bandwidth-delay product, DNS/routing/TLS boundaries, formulas, examples, and packet-capture checks.
- [ ] **Step 3:** Connect arrays, hashes, trees, heaps, graphs, external sorting, B+ tree fan-out, and complexity to real server components.
- [ ] **Step 4:** Add explicit version boundaries, exercises, calculations, and experiments to all four foundation chapters.

### Task 3: Fuse Web, runtime, and LNMP knowledge

**Files:**
- Modify: `knowledge-base/02-设计/01-设计原则与设计模式.md`
- Modify: `knowledge-base/03-Web服务端/01-Web请求全链路.md`
- Modify: `knowledge-base/03-Web服务端/02-PHP与Go服务端开发.md`
- Modify: `knowledge-base/03-Web服务端/03-LNMP部署与调优.md`
- Modify: `knowledge-base/07-核心机制深入/04-服务端运行时与Web.md`

- [ ] **Step 1:** Add browser parse/layout/paint and modern multi-process boundaries to the URL-to-response path.
- [ ] **Step 2:** Correct legacy HTTP/1.1 material with current HTTP semantics and distinguish HTTP/1.1, HTTP/2, and HTTP/3 behavior.
- [ ] **Step 3:** Preserve stable PHP OOP/error/design concepts while marking PHP 5 behavior obsolete and using PHP 8.x for examples; retain Go comparisons.
- [ ] **Step 4:** Add Nginx worker/event/proxy/buffering, PHP-FPM capacity, Linux service-management version boundaries, deployment cases, and 502/504 evidence chains.

### Task 4: Fuse databases, cache, search, and messaging

**Files:**
- Modify: `knowledge-base/04-组件/01-MySQL.md`
- Modify: `knowledge-base/04-组件/02-Redis.md`
- Modify: `knowledge-base/04-组件/03-Elasticsearch.md`
- Modify: `knowledge-base/04-组件/04-Kafka与消息队列.md`
- Modify: `knowledge-base/07-核心机制深入/05-数据系统内部机制.md`

- [ ] **Step 1:** Add InnoDB page-size configuration, Buffer Pool page accounting, B+ tree fan-out/tree-height calculations, clustered/secondary index lookup cost, and MySQL 5.7/8.0/8.4 boundaries.
- [ ] **Step 2:** Add Redis object/encoding evolution, persistence, cache failure modes, hot/big key diagnosis, Cluster limits, and version boundaries.
- [ ] **Step 3:** Expand Elasticsearch segment, refresh, merge, mapping, shard sizing, deep pagination, and 7.x/8.x differences.
- [ ] **Step 4:** Combine Kafka and RabbitMQ around delivery, ordering, acknowledgements, retries, dead letters, backpressure, consumer failure experiments, quorum queues, and streams.

### Task 5: Connect architecture, navigation, and validation

**Files:**
- Modify: `knowledge-base/05-架构/01-架构基础.md`
- Modify: `knowledge-base/05-架构/02-高并发与高可用.md`
- Modify: `knowledge-base/06-实战/03-案例索引.md`
- Modify: `knowledge-base/07-核心机制深入/09-实验与验收清单.md`
- Modify: `knowledge-base/00-学习路线.md`
- Modify: `knowledge-base/README.md`

- [ ] **Step 1:** Connect stable architecture principles to quantified constraints, queues, caches, replication, partitioning, and failure domains; mark obsolete product recipes as historical only.
- [ ] **Step 2:** Add cross-topic cases for a Web request, slow query, cache incident, message backlog, and dependency timeout.
- [ ] **Step 3:** Update the learning route and README so the integrated chapters, experiments, and source index are reachable from the single entry point.
- [ ] **Step 4:** Run `bash scripts/check-learning-links.sh`, a Markdown local-link scan covering all `knowledge-base/`, `git diff --check`, and source-directory integrity checks.
- [ ] **Step 5:** Review every fixed number for a version/configuration qualifier and every core claim for a traceable source or reproducible experiment.
