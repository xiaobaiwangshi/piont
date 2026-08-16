# Data Structures and Algorithms Sample Chapters Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refine the existing data-structures and algorithms chapters into one complete knowledge-only tutorial plus one focused engineering-deep chapter.

**Architecture:** The main chapter owns the learning sequence, definitions, calculations, selection cases, misconceptions and self-test answers. The existing engineering chapter owns invariants, amortized/probabilistic/external/concurrent reasoning and links back to the main chapter; no source-code project or runnable lab is created.

**Tech Stack:** Markdown, existing `raw_doc_` references, local open textbooks, static heading/link/fence/whitespace validation.

---

### Task 1: Establish the two-file boundary

**Files:**
- Modify: `knowledge-base/01-基础/04-数据结构与算法.md`
- Modify: `knowledge-base/07-核心机制深入/03-数据结构与算法工程.md`

- [ ] **Step 1:** Add learning objectives, prerequisites and a reading map to the main chapter.
- [ ] **Step 2:** State that pseudocode and calculations are explanatory only and no program, test or benchmark is run.
- [ ] **Step 3:** Keep definitions and calculations in the main chapter and reserve deep derivations for the engineering chapter.

### Task 2: Complete complexity and basic structures

**Files:**
- Modify: `knowledge-base/01-基础/04-数据结构与算法.md`

- [ ] **Step 1:** Expand asymptotic time/space analysis with best, average, worst, expected and amortized boundaries.
- [ ] **Step 2:** Complete arrays, linked lists, stacks, queues and deques with locality and operation-precondition caveats.
- [ ] **Step 3:** Complete hash tables with collision, load factor, resize, expected/degenerate cost and capacity calculations.
- [ ] **Step 4:** Complete tree/heap selection: BST, balanced trees, heap, B/B+ tree, Trie, segment and Fenwick trees.
- [ ] **Step 5:** Complete graph and disjoint-set representation, traversal, topological order, shortest paths, MST and connectivity boundaries.

### Task 3: Complete algorithms, calculations and cases

**Files:**
- Modify: `knowledge-base/01-基础/04-数据结构与算法.md`

- [ ] **Step 1:** Complete binary search, comparison/non-comparison sorting, selection and stability/in-place boundaries.
- [ ] **Step 2:** Complete divide-and-conquer, greedy proof/counterexample, dynamic-programming state dependencies and backtracking pruning.
- [ ] **Step 3:** Add calculations for complexity growth, dynamic-array amortization, Top K, graph storage, Bloom Filter and external merge sorting.
- [ ] **Step 4:** Connect structures to MySQL B+ trees, Redis dict/skiplist, Kafka logs, LRU and dependency scheduling without claiming source-level identity.
- [ ] **Step 5:** Add a selection evidence chain, ten misconceptions, ten self-test questions and concise answers with assumptions.

### Task 4: Focus the engineering-deep chapter

**Files:**
- Modify: `knowledge-base/07-核心机制深入/03-数据结构与算法工程.md`

- [ ] **Step 1:** Expand structural and loop invariants, proof obligations and minimal counterexamples.
- [ ] **Step 2:** Add potential/accounting reasoning for dynamic-array and hash-table amortized costs.
- [ ] **Step 3:** Add Bloom Filter formulas and clarify Count-Min Sketch, HyperLogLog and reservoir-sampling error boundaries.
- [ ] **Step 4:** Expand concurrent structure ownership, CAS/ABA/reclamation and external-sort failure/recovery reasoning.
- [ ] **Step 5:** Replace executable validation/benchmark wording with non-executed evaluation methods and link duplicated formulas to the main chapter.

### Task 5: Static acceptance

**Files:**
- Modify: `docs/superpowers/plans/2026-08-16-data-structures-algorithms-sample-chapters.md`

- [ ] **Step 1:** Scan headings and required keywords against the approved design.
- [ ] **Step 2:** Verify both Markdown files have balanced code fences and valid local links.
- [ ] **Step 3:** Verify no trailing whitespace or placeholder text appears in either file.
- [ ] **Step 4:** Verify `raw_doc_` remains at 16 source files with no PNG/JPG/TXT sidecars.
- [ ] **Step 5:** Run `git diff --check` and mark all checkboxes complete only after checks pass.
