# Computer Architecture and OS Sample Chapters Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refine the existing computer architecture and operating-system chapters into two complete, knowledge-only sample tutorials with one shared deep-mechanism chapter.

**Architecture:** The two main chapters own learning order, formulas, cases, troubleshooting, version boundaries, misconceptions and self-test answers. The existing hardware/OS deep chapter owns microarchitecture and kernel-internal state transitions and links back to the main explanations; no new topic files or runnable labs are created.

**Tech Stack:** Markdown, existing `raw_doc_` references, local open textbooks and specifications, static link/fence/whitespace validation.

---

### Task 1: Establish the three-file boundary

**Files:**
- Modify: `knowledge-base/01-基础/01-计算机组成原理.md`
- Modify: `knowledge-base/01-基础/03-操作系统.md`
- Modify: `knowledge-base/07-核心机制深入/01-硬件与操作系统.md`

- [x] **Step 1:** Add learning objectives, prerequisites and a reading map to both main chapters.
- [x] **Step 2:** State that commands and calculations are explanatory examples only and no experiment is required.
- [x] **Step 3:** Keep formulas in their owning main chapter and reserve the deep chapter for implementation-state reasoning.

### Task 2: Complete the computer-architecture main tutorial

**Files:**
- Modify: `knowledge-base/01-基础/01-计算机组成原理.md`

- [x] **Step 1:** Add number representation, complement arithmetic, overflow, IEEE 754, endianness and ISA-versus-microarchitecture boundaries.
- [x] **Step 2:** Complete the instruction path, exception/interrupt boundary, pipeline hazards, superscalar, out-of-order execution, branch prediction and in-order retirement.
- [x] **Step 3:** Complete performance calculations for CPU time, CPI/IPC, clock rate, speedup, Amdahl's law, bandwidth transfer time and service CPU capacity.
- [x] **Step 4:** Complete memory hierarchy and cache calculations: line, locality, direct/set-associative mapping, tag/index/offset, misses, AMAT, write policy and prefetch limits.
- [x] **Step 5:** Add cache coherence, memory visibility, false sharing, DRAM/storage, bus, interrupt, DMA and zero-copy boundaries.
- [x] **Step 6:** Add an evidence-chain troubleshooting table, common misconceptions, ten self-test questions and concise reference answers with assumptions.

### Task 3: Complete the operating-system main tutorial

**Files:**
- Modify: `knowledge-base/01-基础/03-操作系统.md`

- [x] **Step 1:** Add user/kernel mode, system calls, exceptions/interrupts, process creation/exit, zombie/orphan state and thread/coroutine boundaries.
- [x] **Step 2:** Complete scheduling goals, run queues, preemption, priorities, CPU-versus-I/O workloads and context-switch costs.
- [x] **Step 3:** Complete synchronization: race conditions, mutex, read/write lock, semaphore, condition variable, atomics, memory ordering and deadlock handling.
- [x] **Step 4:** Complete virtual memory: address translation, page table/TLB, faults, COW, mmap, anonymous/file pages, swap, reclaim and OOM, with page-count/page-table estimates.
- [x] **Step 5:** Complete VFS/filesystem path: inode, dentry, file object, fd, page cache, writeback, fsync, journaling and deleted-open-file behavior.
- [x] **Step 6:** Clarify blocking/nonblocking, synchronous/asynchronous I/O, select/poll/epoll/io_uring, interrupt/DMA and container namespace/cgroup boundaries.
- [x] **Step 7:** Add evidence-chain troubleshooting, resource calculations, common misconceptions, ten self-test questions and concise answers without requiring experiments.

### Task 4: Focus the shared deep chapter

**Files:**
- Modify: `knowledge-base/07-核心机制深入/01-硬件与操作系统.md`

- [x] **Step 1:** Connect the internal path from instruction retirement and cache coherence through address translation and NUMA.
- [x] **Step 2:** Expand scheduling, wakeup, context-switch, synchronization and memory-ordering reasoning without repeating main-chapter definitions.
- [x] **Step 3:** Expand the system-call/VFS/page-cache/writeback/block-layer/device/DMA/interrupt path.
- [x] **Step 4:** Explain namespace/cgroup resource views and replace the experiment section with non-executed observation ideas and commands.

### Task 5: Static acceptance

**Files:**
- Modify: `docs/superpowers/plans/2026-08-16-computer-architecture-os-sample-chapters.md`

- [x] **Step 1:** Scan headings and required keywords against the approved design.
- [x] **Step 2:** Verify all three Markdown files have balanced code fences and valid local links.
- [x] **Step 3:** Verify no trailing whitespace or placeholder text appears in the three files.
- [x] **Step 4:** Verify `raw_doc_` remains unchanged at 16 source files with no PNG/JPG/TXT sidecars.
- [x] **Step 5:** Run `git diff --check` and mark every checkbox complete only after all checks pass.
