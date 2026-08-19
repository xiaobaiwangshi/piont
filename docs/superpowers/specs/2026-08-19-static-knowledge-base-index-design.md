# Knowledge Base 静态目录页设计

## 目标

在 `knowledge-base/index.html` 提供知识库目录页。部署到现有 Nginx 目录后，访问 `/knowledge/` 即可看到目录，点击条目可直接打开对应 Markdown 文件。

## 实现

- 使用单个静态 `index.html`，不引入构建工具、服务端代码或第三方依赖。
- 按 `knowledge-base/` 当前目录结构分组展示全部 `.md` 文件。
- 所有链接使用相对路径，中文路径进行 URL 编码，确保本地和 Nginx 部署路径均可使用。
- 页面提供基础响应式样式，支持桌面和手机浏览；不增加搜索、Markdown 渲染或动态目录扫描。
- 目录内容由生成脚本读取文件系统生成，避免手工漏项；脚本生成后不需要部署到服务器。

## 发布

现有 `rsync_test.sh` 已递归同步 `knowledge-base/` 到：

```text
/var/www/html/knowledge/
```

因此新增的 `knowledge-base/index.html` 会自动上传，无需修改同步逻辑。Nginx 默认索引包含 `index.html` 时，可通过 `/knowledge/` 访问。

## 错误处理

- 生成时只收录 `.md` 普通文件，忽略 `.DS_Store` 和生成的 HTML。
- 链接必须采用相对路径，避免绑定本机或服务器绝对路径。
- 若 Nginx 未把 `index.html` 配置为默认索引，可直接访问 `/knowledge/index.html`。

## 验收

1. `knowledge-base/index.html` 存在且是有效 HTML。
2. 页面列出的 Markdown 文件数与目录实际文件数一致。
3. 每个链接解析后都指向存在的本地文件。
4. 本地静态 HTTP 服务访问首页和抽样链接均返回成功。
5. `rsync_test.sh` 的源目录仍是 `knowledge-base/`，新增页面处于其同步范围内。
