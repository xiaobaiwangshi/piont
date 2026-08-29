# 离线学习资料

这里保存开放教材、大学课程、官方文档、实验和必要源码的固定快照。原始资料仍在 `raw/`、`raw_doc/`，两者不会被本目录覆盖。

## 使用方法

1. 从 [`knowledge-base/08-资料导读/00-混合资料总览.md`](../knowledge-base/08-资料导读/00-混合资料总览.md) 选择学习路径。
2. 在 `manifest.tsv` 查看来源、请求分支、固定提交、版本、本地路径和下载状态。
3. 进入具体资料目录先读 `SOURCE.md`，再按该资料自身目录或构建说明阅读。
4. 官方标准和官方文档优先于社区总结；版本相关行为必须以对应版本资料为准。

## 权威等级

- 一级：标准组织、产品官方文档、官方参考手册。
- 二级：开放教材、大学课程、官方实验和作者维护的配套代码。
- 三级：社区路线、图解和案例仓库，只用于辅助理解。

## 更新与校验

```bash
bash scripts/sync-learning-materials.sh --check
bash scripts/sync-learning-materials.sh --retry-failed
bash scripts/sync-learning-materials.sh --manifest
bash scripts/sync-learning-materials.sh --verify
```

GitHub 项目按具体提交保存，不下载 Git 历史。商业书籍和无法确认再分发许可的资料不复制，只在导读中提供官方入口。
