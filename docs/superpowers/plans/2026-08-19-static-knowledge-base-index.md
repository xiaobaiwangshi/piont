# Static Knowledge Base Index Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a static Nginx-compatible knowledge-base directory page whose links cover every Markdown document.

**Architecture:** Add one dependency-free `knowledge-base/index.html`. It contains responsive CSS and relative anchors grouped by the existing top-level directories; deployment continues to use the existing recursive rsync source.

**Tech Stack:** HTML5, CSS, relative URLs, shell and Node.js verification

---

### Task 1: Add the static directory page

**Files:**
- Create: `knowledge-base/index.html`
- Verify only: `rsync_test.sh`

- [ ] **Step 1: Record the failing precondition**

Run:

```bash
test -f knowledge-base/index.html
```

Expected: exit status `1`, because the index does not exist yet.

- [ ] **Step 2: Create the minimal static page**

Use `apply_patch` to create a complete HTML5 page with:

```html
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>个人计算机与 Web 服务端知识库</title>
  <style>
    :root { color-scheme: light dark; font-family: system-ui, sans-serif; }
    body { max-width: 960px; margin: auto; padding: 2rem 1rem; line-height: 1.6; }
    h1 { margin-bottom: .25rem; }
    section { margin-top: 2rem; }
    ul { padding-left: 1.4rem; }
    li { margin: .45rem 0; }
    a { color: #1677ff; text-decoration: none; }
    a:hover, a:focus-visible { text-decoration: underline; }
  </style>
</head>
<body>
  <header>
    <h1>个人计算机与 Web 服务端知识库</h1>
    <p>选择目录中的文档开始阅读。</p>
  </header>
  <main>
    <!-- One section per top-level directory and one relative anchor per Markdown file. -->
  </main>
</body>
</html>
```

Replace the single HTML comment during the patch with sections generated from the sorted result of:

```bash
find knowledge-base -type f -name '*.md' | sort
```

Each file must appear exactly once. Anchor labels use the filename without `.md`; `href` values are relative to `knowledge-base/` and URL-encode path segments.

- [ ] **Step 3: Verify every Markdown file has one valid link**

Run:

```bash
node --input-type=module -e 'import fs from "node:fs";import path from "node:path";const root="knowledge-base";const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.name===".DS_Store"?[]:e.isDirectory()?walk(path.join(d,e.name)):e.name.endsWith(".md")?[path.relative(root,path.join(d,e.name))]:[]);const html=fs.readFileSync(path.join(root,"index.html"),"utf8");const links=[...html.matchAll(/href="([^"]+\.md)"/g)].map(m=>decodeURIComponent(m[1]));const files=walk(root).sort();if(JSON.stringify(links.sort())!==JSON.stringify(files))throw new Error(`links=${links.length}, files=${files.length}`);for(const link of links)if(!fs.existsSync(path.join(root,link)))throw new Error(`missing: ${link}`);console.log(`PASS: ${files.length} Markdown links`);'
```

Expected: `PASS: 49 Markdown links` if the current 49 Markdown files are unchanged; otherwise the current discovered count.

- [ ] **Step 4: Verify HTML structure and rsync coverage**

Run:

```bash
rg -n '<!doctype html>|<html lang="zh-CN">|<main>|</main>|</html>' knowledge-base/index.html
rg -n 'knowledge-base/|/var/www/html/knowledge/' rsync_test.sh
git diff --check -- knowledge-base/index.html
```

Expected: all structural markers are present, rsync source and destination still cover the knowledge base, and `git diff --check` exits `0`.

- [ ] **Step 5: Serve and smoke-test locally**

Run a temporary server from the repository root:

```bash
python3 -m http.server 8765
```

In another shell, run:

```bash
curl -fsS http://127.0.0.1:8765/knowledge-base/index.html >/dev/null
curl -fsS 'http://127.0.0.1:8765/knowledge-base/README.md' >/dev/null
```

Expected: both commands exit `0`.

- [ ] **Step 6: Review the final diff without committing user-owned changes**

Run:

```bash
git status --short
git diff --check -- knowledge-base/index.html
```

Expected: `knowledge-base/index.html` is present under the existing untracked knowledge-base tree, and no unrelated file was modified by this implementation.
