# Network and MySQL Sample Chapters Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refine the existing network and MySQL chapters into two complete, knowledge-only sample tutorials with clear main/deep boundaries.

**Architecture:** The two main chapters own learning order, formulas, cases, troubleshooting, version boundaries, and self-test answers. The two existing deep chapters own kernel/storage internals and link back to the main explanation; no new chapter files or runnable labs are created.

**Tech Stack:** Markdown, existing `raw_doc_` references, RFC/open textbook/MySQL manual cross-checks, static link and fence validation.

---

### Task 1: Establish content ownership and source boundaries

**Files:**
- Modify: `knowledge-base/01-基础/02-计算机网络.md`
- Modify: `knowledge-base/04-组件/01-MySQL.md`

- [x] **Step 1:** Add learning objectives and prerequisite sections to both main chapters.
- [x] **Step 2:** Add a short reading map that sends protocol/storage implementation details to the matching deep chapter instead of duplicating them.
- [x] **Step 3:** State that commands and SQL are explanatory examples only; this phase does not require executing experiments.

### Task 2: Complete the network main tutorial

**Files:**
- Modify: `knowledge-base/01-基础/02-计算机网络.md`

- [x] **Step 1:** Complete link/network-layer knowledge: encapsulation, Ethernet, ARP/NDP, VLAN, MTU/MSS, IPv4/IPv6, CIDR, ICMP, longest-prefix routing, NAT and ports.
- [x] **Step 2:** Complete TCP transport knowledge: handshake, state, sequence/ACK/SACK, retransmission/RTO, receive and congestion windows, zero window, slow start, congestion avoidance, recovery, CUBIC/BBR boundaries and connection close.
- [x] **Step 3:** Add quantitative examples for CIDR capacity, BDP, `min(rwnd,cwnd)-flight_size`, throughput by window/RTT, MSS/MTU and average connection concurrency.
- [x] **Step 4:** Complete application-layer knowledge: DNS roles/cache, TLS 1.3, HTTP semantics and versions, SSE/WebSocket, proxy and timeout boundaries.
- [x] **Step 5:** Add evidence-chain troubleshooting for resolution failure, refusal, timeout, retransmission, low throughput, PMTU black holes, 502 and 504.
- [x] **Step 6:** Add misconceptions, ten self-test questions and concise reference answers with assumptions and boundaries.

### Task 3: Focus the network deep chapter

**Files:**
- Modify: `knowledge-base/07-核心机制深入/02-协议栈与网络性能.md`

- [x] **Step 1:** Add the Linux send/receive path from application buffers through socket, protocol stack, qdisc, driver, DMA, interrupt/NAPI and back.
- [x] **Step 2:** Explain SYN backlog, accept queue, socket buffers, conntrack, ephemeral ports, TIME_WAIT and file-descriptor capacity as distinct limits.
- [x] **Step 3:** Explain checksum/segmentation/receive offloads and why packet captures may not match wire segmentation.
- [x] **Step 4:** Replace duplicated formulas with links to the main chapter and add a kernel-versus-protocol implementation boundary.

### Task 4: Complete the MySQL main tutorial

**Files:**
- Modify: `knowledge-base/04-组件/01-MySQL.md`

- [x] **Step 1:** Add relational-model essentials and the MySQL Server/InnoDB responsibility boundary.
- [x] **Step 2:** Expand physical storage: tablespace, segment, extent, page, record, row format, overflow pages and page split/merge consequences.
- [x] **Step 3:** Complete Buffer Pool accounting, page lifecycle, free/LRU/flush roles, dirty-page/checkpoint pressure, hit-rate interpretation and memory-boundary caveats.
- [x] **Step 4:** Complete B+ tree calculations and index access paths: clustered/secondary, covering, lookup, range scan, fan-out/tree height and logical-versus-physical I/O.
- [x] **Step 5:** Expand index/optimizer knowledge: selectivity, cardinality estimates, histograms, ICP, MRR, join choices, sort/temp table, `EXPLAIN` and `EXPLAIN ANALYZE` version boundaries.
- [x] **Step 6:** Expand transactions: Read View and version chains, consistent versus locking reads, record/gap/next-key locks, deadlocks and isolation-level boundaries.
- [x] **Step 7:** Expand durability: undo, redo, binlog, group commit, two-phase commit, checkpoint, doublewrite and crash-recovery sequence.
- [x] **Step 8:** Expand replication/backup/recovery: GTID, async/semi-sync boundaries, replication lag, logical/physical backup, RPO/RTO and restore validation.
- [x] **Step 9:** Add common misconceptions, ten self-test questions and concise reference answers with calculations and version qualifiers.

### Task 5: Focus the MySQL deep section

**Files:**
- Modify: `knowledge-base/07-核心机制深入/05-数据系统内部机制.md`

- [x] **Step 1:** Add an InnoDB page lifecycle from read miss through modification, redo, dirty-page flushing and eviction.
- [x] **Step 2:** Add MVCC undo chains, purge boundaries and long-transaction consequences.
- [x] **Step 3:** Add redo/binlog coordination, checkpoint/doublewrite separation and crash recovery reasoning.
- [x] **Step 4:** Add secondary-index lookup/write-amplification and replication-recovery boundaries without changing Redis/Elasticsearch/Kafka sections.

### Task 6: Static acceptance

**Files:**
- Modify: `docs/superpowers/plans/2026-08-16-network-mysql-sample-chapters.md`

- [x] **Step 1:** Confirm all design-required topics appear once in their owning chapter using heading and keyword scans.
- [x] **Step 2:** Verify all four Markdown files have balanced code fences and valid local links.
- [x] **Step 3:** Verify `raw_doc_` contains 16 source files (one Linux PDF was added after the 15-file inventory) and no generated sidecars.
- [x] **Step 4:** Run `git diff --check` for the tracked plan and trailing-whitespace checks for the four knowledge files.
- [x] **Step 5:** Mark every plan checkbox complete only after all checks exit successfully.
