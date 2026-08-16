# AI 与大模型知识库设计

## 目标

把 `raw_llm/` 与 `raw_llm_doc/` 中零散、重复且部分过时的 AI 资料，整理为从基础原理到训练、RAG、Agent、推理部署和安全评测的全栈学习资料。新文档进入 `knowledge-base/` 唯一入口；原始目录保持不变。

## 资料现状

- `raw_llm/`：838 个文件，约 145MiB；其中 96 份 Markdown、710 张 PNG，并含 PDF/WebP/JPEG/GIF 等配图。
- `raw_llm_doc/`：103 个文件，约 64MiB；核心是 92 份 2023—2024 年专题 PDF，另有少量脚本、IDE 和辅助文件。
- 两套资料主题高度重叠，覆盖 NLP/LLM 基础、Transformer、数据与训练、PEFT、分布式训练、RLHF、RAG、Agent、推理框架、评测与幻觉。
- PDF 与 Markdown 中包含大量面试问答、固定模型清单、旧安装命令和特定硬件性能倍数，不能原样当作当前结论。

## 方案选择

采用“八篇主题主线 + 一篇核心机制深入章”：

```text
knowledge-base/09-AI与大模型/
├── 00-学习路线.md
├── 01-大模型基础与Transformer.md
├── 02-训练微调与对齐.md
├── 03-RAG与知识库.md
├── 04-Agent与AI应用工程.md
├── 05-推理部署与性能.md
├── 06-评测安全与治理.md
└── 07-资料导读与版本风险.md

knowledge-base/07-核心机制深入/
└── 10-大模型核心机制.md
```

并更新：

- `knowledge-base/README.md`
- `knowledge-base/00-学习路线.md`

未采用的方案：镜像原目录会保留重复问答和旧分类；合并成三篇大文档会使训练、检索与部署难以维护；建立代码/实验项目不符合本轮“创建学习资料”的目标。

## 统一章节结构

主题章节按需要采用以下顺序，不为凑格式重复内容：

1. 学习目标与先修知识。
2. 基础概念与稳定定义。
3. 核心机制与数据流。
4. 定量计算和明确假设。
5. 高阶方法与选择边界。
6. 使用案例与解决的问题。
7. 失败模式、证据链和常见误区。
8. 版本边界与自测题/答案。
9. 来源线索。

命令、伪代码和架构流程仅用于解释知识，本轮不下载模型、不训练、不部署服务，也不运行 GPU/向量库实验。

## 00 学习路线

提供三条路线：

- AI 应用工程：基础 → RAG → Agent → 评测安全 → 推理服务。
- 模型训练：基础 → 核心机制 → 数据/预训练 → SFT/PEFT → 对齐 → 分布式训练。
- 推理平台：基础 → 核心机制 → 推理指标 → KV Cache/批处理/量化 → 服务容量与可观测性。

每条路线注明必学、选学、前置数学和与现有计算机基础、数据结构、网络、操作系统、MySQL/Redis/ES 的连接。

## 01 大模型基础与 Transformer

覆盖：

- AI、机器学习、深度学习、NLP、生成模型和 LLM 的边界。
- token、词表、BPE/WordPiece/Unigram/SentencePiece、embedding 与上下文窗口。
- 语言模型概率、交叉熵、困惑度和自回归生成。
- Transformer 的 embedding、位置编码、Attention、残差、LayerNorm、FFN 与输出头。
- Encoder、Decoder、Encoder-Decoder 和 decoder-only 的适用边界。
- MHA/MQA/GQA、RoPE、MoE、稠密模型与路由模型。
- greedy、beam、temperature、top-k、top-p 与重复惩罚。
- 传统 NLP 的分词、词向量、CNN/RNN/BERT 只保留理解现代 LLM 所需内容。

不把某个模型家族、参数量、上下文长度或排行榜当作长期稳定事实。

## 02 训练、微调与对齐

按数据流组织：

```text
数据采集/许可 → 清洗去重 → tokenizer → 预训练
→ 指令/SFT → PEFT/LoRA → 偏好对齐 → 评测与发布
```

覆盖数据质量、泄漏、采样、packing、预训练目标、SFT、Adapter、Prompt Tuning、LoRA/QLoRA、持续预训练、灾难性遗忘、RLHF、奖励模型、PPO、DPO 及各自边界。

分布式部分解释数据并行、张量并行、流水线并行、序列/上下文并行、专家并行、混合并行、ZeRO/FSDP、gradient accumulation、activation checkpointing、AMP 与通信/负载均衡。框架命令绑定 PyTorch、DeepSpeed、Accelerate 等具体版本，不作为稳定接口。

## 03 RAG 与知识库

按完整链路组织：

```text
文档采集 → 解析/OCR/版面恢复 → 清洗 → 分块
→ embedding/稀疏索引 → 检索 → rerank → 上下文组装
→ 生成/引用 → 检索与答案评测 → 反馈和重建
```

覆盖 chunk 策略、metadata、向量与 BM25、hybrid search、query rewrite、HyDE、multi-query/RAG-Fusion、reranker、上下文压缩、权限过滤、增量更新、GraphRAG 和多模态文档边界。

评测区分 Recall@K、MRR、nDCG 等检索指标与 faithfulness、answer relevance、citation correctness 等生成指标；解释“检索到了、模型用了、答案正确”是三个不同问题。

## 04 Agent 与 AI 应用工程

把 Agent 定义为受约束的循环，而不是“自动思考”的人格化系统：

```text
目标/状态 → 模型决策 → 工具调用 → 结果校验
→ 状态更新/记忆 → 继续或停止
```

覆盖提示结构、structured output、function/tool calling、规划、短期/长期记忆、工作流与自治 Agent 边界、多 Agent、人工审批、幂等、重试、超时、预算、审计和可恢复执行。

LangChain 等框架只作实现例子；MCP、模型 API 和工具协议按能力边界解释。重点补充工具参数验证、最小权限、提示注入、数据外泄、危险操作确认和不可信工具结果。

## 05 推理部署与性能

覆盖 prefill/decode、KV Cache、continuous batching、PagedAttention、prefix caching、量化、蒸馏、speculative decoding、张量/流水线并行和多副本调度。

核心指标：TTFT、TPOT/ITL、端到端延迟、tokens/s、并发、吞吐、队列时间、显存利用率、缓存命中和错误率。解释吞吐与单请求延迟、输入/输出长度、batch 和 SLO 的取舍。

vLLM、TensorRT-LLM、TGI、llama.cpp 等只按当前能力类别介绍；旧资料中的“快 N 倍”必须保留硬件、模型、版本、输入分布和对照基线，否则删除。

## 06 评测、安全与治理

覆盖离线数据集、任务指标、LLM-as-a-judge、人工评测、成对比较、在线 A/B、数据泄漏、污染和回归集。生成质量与检索、工具成功率、延迟、成本、安全指标分别统计。

幻觉按知识缺失、检索失败、上下文冲突、推理错误、解码和工具错误分类。治理覆盖 prompt injection、jailbreak、不安全输出、隐私/个人信息、版权许可、供应链、模型与数据版本、日志脱敏、红队和事故响应。

安全措施采用纵深防御，不宣称某个提示词可以彻底消除幻觉或注入攻击。

## 07 资料导读与版本风险

建立主题到 `raw_llm/` 和 `raw_llm_doc/` 的映射，记录：

- 可保留的稳定机制。
- 需要校正的旧模型、框架和命令。
- 只有标题/面试结论、缺少一级来源的内容。
- 推荐核对的论文、官方文档和版本说明。

不为 92 份 PDF 逐份复制正文；Markdown 为主要线索，PDF 用于补缺和交叉检查。`main.py`、IDE 文件和依赖清单只视为资料处理附属物，不进入 AI 知识结论。

## 大模型核心机制深入

集中放置跨章节的定量推导，主章节只引用结论：

- Attention 张量形状、缩放点积、mask 与 `O(L²d)` 时间/注意力矩阵空间边界。
- 参数、梯度、优化器状态、激活与通信组成的训练显存估算。
- LoRA 参数量 `r(d_in+d_out)` 与秩/目标层选择。
- KV Cache 近似：`2 × layers × tokens × kv_heads × head_dim × bytes × batch`。
- prefill 计算密集、decode 内存带宽/延迟敏感的原因。
- 数据/张量/流水线/专家并行的通信与气泡。
- RAG 向量相似度、ANN 召回—延迟权衡与 rerank 成本。
- Agent 状态机、幂等副作用和故障恢复边界。

公式都注明架构与实现假设，不把估算值当实际显存或吞吐保证。

## 来源与纠错策略

1. 先从 96 份 Markdown 建立主题清单和重复关系。
2. 用 PDF 标题、目录和文本层补充 Markdown 缺失点；图表关键结论需要回看页面。
3. 稳定原理优先核对原始论文或开放教材。
4. PyTorch、Transformers、PEFT、vLLM、DeepSpeed、LangChain 等行为以当前官方文档和 release notes 为准。
5. 不能确认的性能数字、模型排名和“最佳实践”改写为影响因素与验证方法。
6. 资料中的拼写、公式和概念错误只在新文档纠正，不回写原始资料。

## 验收

- 新目录八篇文档、一篇深入章和两个总入口均存在，学习路径可从 `knowledge-base/README.md` 到达。
- 覆盖基础/架构、训练/微调/对齐、RAG、Agent、推理部署、评测安全六条完整主线。
- 至少包含 Attention、训练显存、LoRA、KV Cache、RAG 指标和推理容量六类定量关系。
- 每个主题解释基础、核心机制、使用案例、解决的问题、失败模式和版本边界。
- 关键旧结论被标为历史/版本相关或已纠正；不复制大段原文。
- 不修改 `raw_llm/` 与 `raw_llm_doc/`，不运行训练、部署和向量库实验。
- 所有新 Markdown 的本地链接有效、代码围栏配对、无尾随空格和占位内容。
