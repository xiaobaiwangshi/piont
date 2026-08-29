# Product Source Archive Pruning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the local collection learning-material-first by removing nine complete product source copies while retaining official source links in the guides.

**Architecture:** The download configuration remains the source of truth for locally synchronized materials. Product source entries are removed from that configuration and manifest, local copies are deleted, and guide links are changed from local paths to official upstream URLs; teaching code and documentation repositories remain untouched.

**Tech Stack:** TSV manifests, Markdown guides, shell verification scripts.

---

### Task 1: Remove product sources from synchronization metadata

**Files:**
- Modify: `config/learning-materials.tsv`
- Modify: `learning-materials/manifest.tsv`

- [x] **Step 1:** Remove the nine rows named `linux-kernel`, `mysql-server-8.0`, `kafka`, `memcached`, `thrift`, `etcd`, `zookeeper`, `rocketmq`, and `nacos`.
- [x] **Step 2:** Verify none of the nine names remains in either TSV file with `rg`.

### Task 2: Replace local source links with official links

**Files:**
- Modify: `knowledge-base/08-资料导读/01-计算机基础资料导读.md`
- Modify: `knowledge-base/08-资料导读/03-数据库与中间件资料导读.md`
- Modify: `knowledge-base/08-资料导读/04-架构运维与安全资料导读.md`

- [x] **Step 1:** Replace each removed local path with its official project or source URL and state that source is an optional high-level reference.
- [x] **Step 2:** Verify no guide points at the nine deleted directories.

### Task 3: Delete local copies and regenerate verification output

**Files:**
- Delete: the nine approved directories under `learning-materials/`
- Modify: `learning-materials/verification-report.md`

- [x] **Step 1:** Delete only the nine explicitly approved directories.
- [x] **Step 2:** Run `scripts/sync-learning-materials.sh --verify-only` if supported; otherwise run its documented non-download verification command.
- [x] **Step 3:** Run `scripts/check-learning-links.sh` and confirm all retained local links resolve.
- [x] **Step 4:** Confirm teaching repositories, official manuals, and documentation repositories still exist.
