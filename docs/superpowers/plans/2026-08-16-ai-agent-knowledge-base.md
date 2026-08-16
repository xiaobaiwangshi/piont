# AI Agent Knowledge Base Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a full-stack-developer-to-AI-Agent learning path with mandatory LLM foundations, production Agent engineering, optional model training/deployment and source/version governance.

**Architecture:** Ten topic documents under `knowledge-base/09-AI与大模型/` own the learning sequence and engineering decisions. Two deep chapters under `knowledge-base/07-核心机制深入/` own model formulas and Agent state/reliability reasoning; the existing README and global learning route link the new domain without changing either raw source directory.

**Tech Stack:** Markdown, 96 source Markdown files, 92 source PDFs, current stable concepts from primary papers/specifications/official documentation, static link/fence/whitespace/source-integrity checks.

---

### Task 1: Establish source and navigation boundaries

**Files:**
- Create: `knowledge-base/09-AI与大模型/00-AI-Agent转型路线.md`
- Modify: `knowledge-base/README.md`
- Modify: `knowledge-base/00-学习路线.md`

- [x] **Step 1:** Record the ten-year full-stack skill mapping and the mandatory-versus-elective learning order.
- [x] **Step 2:** Link the AI Agent domain from both knowledge-base entry documents.
- [x] **Step 3:** State that `raw_llm/` and `raw_llm_doc/` remain read-only and no model/vector/GPU experiment is run.

### Task 2: Build mandatory LLM foundations

**Files:**
- Create: `knowledge-base/09-AI与大模型/01-AI与大模型基础Transformer.md`
- Create: `knowledge-base/07-核心机制深入/10-大模型核心机制.md`

- [x] **Step 1:** Explain AI/ML/DL/NLP/LLM boundaries and the minimum vector, probability, loss and gradient foundations.
- [x] **Step 2:** Explain tokenization, embedding, language-model objectives and the Transformer data flow.
- [x] **Step 3:** Cover Attention, mask, position, residual/norm/FFN, MHA/MQA/GQA, MoE and decoder-only boundaries.
- [x] **Step 4:** Cover logits, sampling/decoding, pretraining/SFT/alignment/inference stages and model limitations.
- [x] **Step 5:** Add deep tensor-shape, Attention complexity, parameter/training memory, LoRA and KV Cache calculations.
- [x] **Step 6:** Add misconceptions, version boundaries and self-test answers without turning this into a research-training course.

### Task 3: Build the model-interface chapter

**Files:**
- Create: `knowledge-base/09-AI与大模型/02-LLM应用基础与模型接口.md`

- [x] **Step 1:** Cover message roles, prompt/context structure, few-shot and instruction-conflict boundaries.
- [x] **Step 2:** Cover structured output, JSON Schema and tool-call validation as untrusted input handling.
- [x] **Step 3:** Cover streaming, cancellation, timeout, retry, rate limit, idempotency, fallback and provider abstraction.
- [x] **Step 4:** Add token/cost/latency calculations, failure evidence chains, misconceptions and self-test answers.

### Task 4: Build RAG, context and memory

**Files:**
- Create: `knowledge-base/09-AI与大模型/03-RAG上下文与长期记忆.md`

- [x] **Step 1:** Cover the ingestion path from PDF/OCR/layout through chunking, metadata, indexing and updates.
- [x] **Step 2:** Cover BM25, embeddings, ANN, hybrid retrieval, query rewrite, rerank and context packing.
- [x] **Step 3:** Separate messages, working memory, long-term memory and authoritative knowledge with lifecycle/permission rules.
- [x] **Step 4:** Cover Recall@K/MRR/nDCG, faithfulness/answer/citation evaluation and common failure chains.
- [x] **Step 5:** Add cases, calculations, misconceptions, GraphRAG/multimodal boundaries and self-test answers.

### Task 5: Build tool calling, MCP and integration

**Files:**
- Create: `knowledge-base/09-AI与大模型/04-工具调用MCP与系统集成.md`

- [x] **Step 1:** Define tool contracts, Schema validation, error taxonomy and read/write trust levels.
- [x] **Step 2:** Explain sync/async tools, webhook/polling, cancellation, retry, idempotency, compensation and approval.
- [x] **Step 3:** Explain MCP client/server, tools/resources/prompts, transport, capability and authorization boundaries.
- [x] **Step 4:** Map database/search/browser/file/queue/code tools to full-stack risks and controls.
- [x] **Step 5:** Add threat cases, misconceptions, version boundaries and self-test answers.

### Task 6: Build Agent architecture and deep mechanisms

**Files:**
- Create: `knowledge-base/09-AI与大模型/05-Agent架构编排与多Agent.md`
- Create: `knowledge-base/07-核心机制深入/11-Agent运行机制与可靠性.md`

- [x] **Step 1:** Model Agent as an explicit state/action/result/termination loop and distinguish deterministic workflow from autonomy.
- [x] **Step 2:** Cover ReAct, plan-and-execute, router, reflection, supervisor/worker and human-in-the-loop boundaries.
- [x] **Step 3:** Cover graph/state/checkpoint concepts and when multi-Agent roles/parallelism justify their cost.
- [x] **Step 4:** Deepen event logs, checkpoint/replay, context budgets, at-least-once tools, idempotency, compensation and multi-Agent loops.
- [x] **Step 5:** Add architecture selection cases, misconceptions and self-test answers.

### Task 7: Build production reliability

**Files:**
- Create: `knowledge-base/09-AI与大模型/06-Agent生产工程与可靠性.md`

- [x] **Step 1:** Define session/task/step/tool-call/artifact/event persistence and concurrency models.
- [x] **Step 2:** Cover sync/async/queue/event workflows, timeout/retry/backoff/circuit-breaker/dead-letter/fallback behavior.
- [x] **Step 3:** Cover SSE, cancellation, backpressure, partial results, pause/resume, orphan cleanup and human approval.
- [x] **Step 4:** Cover prompt/model/tool/data/evaluation versioning, tracing, SLO and cost attribution.
- [x] **Step 5:** Add enterprise assistant, ticket Agent, code/operations assistant and business-process cases with failure recovery.

### Task 8: Build evaluation, security and governance

**Files:**
- Create: `knowledge-base/09-AI与大模型/07-评测安全成本与治理.md`

- [x] **Step 1:** Define node, retrieval, trajectory and end-to-end Agent evaluation layers.
- [x] **Step 2:** Cover golden/regression sets, mocked tools, deterministic assertions, semantic judges, human review and online feedback.
- [x] **Step 3:** Cover direct/indirect prompt injection, privilege escalation, leakage, cross-tenant memory, dangerous tools and supply chain threats.
- [x] **Step 4:** Cover layered controls, audit/incident response, evaluation versioning and cost/quality/safety release gates.
- [x] **Step 5:** Add misconceptions, evidence chains and self-test answers.

### Task 9: Build optional training/deployment and source guide

**Files:**
- Create: `knowledge-base/09-AI与大模型/08-模型训练与推理部署选学.md`
- Create: `knowledge-base/09-AI与大模型/09-资料导读与版本风险.md`

- [x] **Step 1:** Explain prompt/RAG versus SFT/LoRA/continued-pretraining/alignment selection.
- [x] **Step 2:** Explain data/quality/licensing, distributed-training concepts and why framework practice is elective.
- [x] **Step 3:** Explain prefill/decode, batching, PagedAttention, quantization, speculative decoding and serving metrics.
- [x] **Step 4:** Build a topic map for the 96 Markdown and 92 PDF sources, marking stable, elective and historical/version-risk material.
- [x] **Step 5:** Add build-versus-buy cases, misconceptions and self-test answers.

### Task 10: Static acceptance

**Files:**
- Modify: `docs/superpowers/plans/2026-08-16-ai-agent-knowledge-base.md`

- [x] **Step 1:** Verify ten topic documents, two deep chapters and two entry-point updates exist and link correctly.
- [x] **Step 2:** Scan mandatory LLM and Agent-engineering concepts and all required quantitative relationships.
- [x] **Step 3:** Verify balanced code fences, valid local links, no trailing whitespace and no placeholder text.
- [x] **Step 4:** Verify `raw_llm/` remains 838 files and `raw_llm_doc/` remains 103 files with unchanged type counts.
- [x] **Step 5:** Run `git diff --check` and mark all checkboxes complete only after checks pass.
