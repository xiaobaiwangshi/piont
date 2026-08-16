# AI Agent 开发知识库设计

## 目标

面向一名具有十年全栈开发经验、正在转型 AI Agent 开发的工程师，把 `raw_llm/` 与 `raw_llm_doc/` 中零散、重复且部分过时的 AI 资料，整理成“能设计、实现、上线和治理 Agent 系统”的学习资料。新文档进入 `knowledge-base/` 唯一入口；原始目录保持不变。

这不是模型研究员培养路线，但大模型基础是必修。数学、Transformer、tokenization、embedding、训练目标和生成机制要学到能解释模型能力与限制；大规模训练框架和底层 CUDA 只讲到足以做技术选型和排障。工程主线仍是模型接口、上下文工程、RAG/记忆、工具调用、MCP、工作流、状态恢复、评测、安全、可观测性和成本。

## 资料现状

- `raw_llm/`：838 个文件，约 145MiB；其中 96 份 Markdown、710 张 PNG，并含 PDF/WebP/JPEG/GIF 等配图。
- `raw_llm_doc/`：103 个文件，约 64MiB；核心是 92 份 2023—2024 年专题 PDF，另有少量脚本、IDE 和辅助文件。
- 两套资料主题高度重叠，覆盖 NLP/LLM 基础、Transformer、数据与训练、PEFT、分布式训练、RLHF、RAG、Agent、推理框架、评测与幻觉。
- PDF 与 Markdown 中包含大量面试问答、固定模型清单、旧安装命令和特定硬件性能倍数，不能原样当作当前结论。

## 方案选择

采用“一篇转型路线 + 九篇主题 + 两篇核心机制深入章”：

```text
knowledge-base/09-AI与大模型/
├── 00-AI-Agent转型路线.md
├── 01-AI与大模型基础Transformer.md
├── 02-LLM应用基础与模型接口.md
├── 03-RAG上下文与长期记忆.md
├── 04-工具调用MCP与系统集成.md
├── 05-Agent架构编排与多Agent.md
├── 06-Agent生产工程与可靠性.md
├── 07-评测安全成本与治理.md
├── 08-模型训练与推理部署选学.md
└── 09-资料导读与版本风险.md

knowledge-base/07-核心机制深入/
├── 10-大模型核心机制.md
└── 11-Agent运行机制与可靠性.md
```

并更新：

- `knowledge-base/README.md`
- `knowledge-base/00-学习路线.md`

未采用的方案：镜像原目录会把训练和模型面试题放在主线前面，偏离转型目标；按模型算法组织会弱化全栈工程经验；合并成三篇大文档会使 Agent 的状态、工具、可靠性和安全边界难以维护；建立代码/实验项目不符合本轮“创建学习资料”的目标。

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

## 既有经验如何迁移

现有全栈知识不是从零开始，必须在学习路线中显式映射：

| 已有能力 | Agent 开发中的迁移 |
|---|---|
| Web/API | 模型网关、流式响应、工具 API、Webhook、鉴权与限流 |
| MySQL/Redis/ES | 对话状态、短期缓存、向量/混合检索、审计记录 |
| Kafka/队列 | 长任务、异步工具、事件驱动工作流、重试与死信 |
| 分布式系统 | 幂等、超时、重试、补偿、一致性和状态恢复 |
| 操作系统/网络 | SSE、连接取消、并发、资源限制与推理延迟 |
| 可观测性/安全 | Trace、SLO、成本、权限、脱敏、审计和事故响应 |

真正需要补齐的差异包括两层：第一层是大模型如何表示 token、计算 Attention、训练和逐 token 生成；第二层是模型输出具有概率性、自然语言不是稳定 API、上下文有限且会被不可信文本污染、评测不能只用传统单元测试、工具调用会把模型错误变成真实副作用。

## 00 AI Agent 转型路线

主线按交付能力组织：

```text
AI 与大模型基础、Transformer
→ LLM 应用基础与模型接口
→ RAG、上下文与记忆
→ 工具调用、MCP 与系统集成
→ Agent 状态机、工作流与多 Agent
→ 生产可靠性
→ 评测、安全、成本与治理
```

基础数学、tokenization、embedding、Transformer、生成与训练阶段是必修；训练框架实操、微调工程、自托管推理和 GPU 优化作为选学，只在 API 模型、RAG 或提示无法满足需求，以及数据合规/成本/延迟确实要求自建时进入。

路线以“能交付什么”验收：能实现带引用的知识问答、受控工具执行、长任务恢复、人工审批、回归评测、成本监控和安全边界，而不是背模型名称。

## 01 AI、大模型基础与 Transformer

目标不是推导全部深度学习理论，而是能从输入文本解释到输出 token：

- AI、机器学习、深度学习、NLP、生成模型、基础模型和 LLM 的关系。
- 向量、矩阵乘法、点积、概率分布、softmax、对数、交叉熵、梯度下降和反向传播的直觉与必要公式。
- 参数、超参数、训练/验证/测试集、过拟合、正则化、泛化和数据泄漏。
- 文本规范化、token、词表、BPE、WordPiece、Unigram、SentencePiece 和中文切分边界。
- one-hot、Word2Vec、embedding、语义相似度和向量空间的能力边界。
- n-gram、RNN/LSTM、CNN、Encoder、Decoder、Encoder-Decoder 到 Transformer 的演进动机。
- Transformer 中 embedding、位置编码、self-attention、causal mask、残差、LayerNorm、FFN 和输出头的数据流。
- MHA、MQA、GQA、RoPE、MoE、稠密/稀疏激活和 decoder-only 的工程意义。
- 预训练、持续预训练、SFT、偏好对齐和推理的生命周期关系。
- 自回归生成、logits、temperature、top-k、top-p、greedy、beam、停止条件与随机性。

章节必须解释模型为什么会产生幻觉、为什么上下文长度不等于有效记忆、为什么 embedding 相似不等于事实正确，以及参数量、数据、算力和评测之间没有单一线性关系。

## 02 LLM 应用基础与模型接口

只保留 Agent 工程必须掌握的模型知识：

- token、上下文窗口、embedding、自回归生成、temperature/top-p、停止条件。
- Transformer、Attention、位置编码、MHA/MQA/GQA、decoder-only 的工程意义。
- system/developer/user/tool 消息、structured output、JSON Schema、function/tool calling。
- streaming、取消、超时、重试、速率限制、幂等键、模型回退和供应商抽象边界。
- prompt 模板、few-shot、上下文排序、指令冲突、输出校验和修复。
- API 成本、输入/输出 token、缓存和延迟的估算。

重点说明模型输出不是可信反序列化结果：结构化输出仍需 Schema、业务规则、权限和副作用前校验。LangChain 等 SDK 只作可替换实现，不围绕框架 API 组织知识。

## 03 RAG、上下文与长期记忆

把 RAG 和 Agent 记忆放在同一条数据链中：

```text
数据源 → 解析/OCR → 清洗/分块/metadata → 索引
→ 查询理解 → 检索/权限过滤 → rerank
→ 上下文组装/引用 → 生成 → 评测 → 更新/重建
```

区分四种状态：当前轮消息、会话摘要/工作记忆、用户/业务长期记忆、外部权威知识库。记忆不是简单把所有历史放进 prompt；必须定义写入条件、事实来源、冲突合并、过期、删除、权限和可追溯性。

覆盖 BM25、embedding、hybrid search、ANN、query rewrite、HyDE、multi-query/RAG-Fusion、reranker、上下文压缩、GraphRAG 和多模态文档边界。重点处理 PDF 表格、标题层级、跨页内容、版本化和增量索引。

评测区分 Recall@K、MRR、nDCG、上下文相关性、faithfulness、答案正确性和引用正确性；“检索到了、模型使用了、回答正确”分别验收。

## 04 工具调用、MCP 与系统集成

围绕全栈工程师最关键的“模型如何安全操作真实系统”组织：

- 工具定义、名称/描述、JSON Schema、参数校验、返回值和错误分类。
- read-only 与 write 工具、最小权限、租户隔离、密钥管理和审计。
- 同步/异步工具、轮询/Webhook、超时、取消、重试、幂等和补偿。
- MCP 的 client/server、capability、tool/resource/prompt、transport、授权和信任边界。
- 数据库、搜索、浏览器、文件、消息队列、内部 API 和代码执行工具的风险差异。
- 人工审批、dry-run、预算/额度和危险操作二次确认。

工具输出视为不可信输入，可能包含提示注入、过大数据、错误状态和敏感信息。模型负责提出调用意图，应用负责授权、校验和执行；不能让模型本身成为安全边界。

## 05 Agent 架构、编排与多 Agent

把 Agent 建模为显式状态机：

```text
目标 + 当前状态
→ 选择下一动作
→ 调用模型/工具/人工节点
→ 校验结果
→ 持久化状态与事件
→ 继续、等待、补偿或终止
```

覆盖 ReAct、plan-and-execute、router、supervisor/worker、reflection 的适用边界；区分确定性 workflow 与自治 Agent。能用固定 DAG/状态机解决的业务，不为了“智能”改成开放循环。

规划内容包括任务分解、终止条件、最大步数、预算、失败重规划和人工接管。多 Agent 只在角色需要不同权限、上下文、模型或并行任务时使用；否则会增加通信、重复 token、死循环和责任模糊。

框架可映射到 graph/state/workflow/runtime/checkpoint 等通用概念，不把 LangGraph、AutoGen、CrewAI 或其他框架的当前 API 当成架构定义。

## 06 Agent 生产工程与可靠性

这是全栈经验迁移的核心章节，覆盖：

- 会话、任务、step、tool call、artifact 和事件的持久化模型。
- checkpoint、暂停/恢复、重放、去重、幂等副作用和 Saga/补偿。
- 同步短请求、异步长任务、队列 worker、定时任务和事件驱动选择。
- 并发修改、租约/锁、乐观版本、任务取消和孤儿任务回收。
- 模型/工具超时、速率限制、熔断、退避、降级、fallback 和 dead-letter。
- SSE 流式输出、断线续传、背压、部分结果和前端状态同步。
- prompt/model/tool/data/evaluation 版本及全链路 trace。
- token、模型、检索、工具、人工和基础设施的成本归因与预算控制。

给出知识型案例：企业知识助手、工单处理 Agent、代码/运维助手和多步骤业务办理。每个案例都说明为什么需要 Agent、哪些步骤保持确定性、失败怎样恢复，以及人工在哪里介入。

## 07 评测、安全、成本与治理

Agent 评测分层：

- 单节点：结构化输出、分类/抽取、工具选择和参数正确性。
- RAG：检索、引用、faithfulness 和答案正确性。
- 轨迹：步骤数、无效循环、计划完成度、工具成功率和恢复行为。
- 端到端：任务成功、用户体验、延迟、成本、安全和人工接管率。

覆盖 golden set、回归集、模拟工具、确定性断言、语义评分、LLM-as-a-judge、人工盲评、在线 A/B 和生产反馈。评测数据与 prompt、模型、工具版本绑定，防止数据污染和“为 benchmark 优化”。

威胁模型覆盖 prompt injection、间接注入、越权工具、数据外泄、跨租户记忆污染、危险代码/SQL、供应链和日志泄密。防线包括输入分区、最小权限、allowlist、Schema/业务校验、输出编码、沙箱、审批、审计、速率/成本上限和事故响应。

## 08 模型训练与推理部署选学

只讲 Agent 工程师做 build-vs-buy 决策所需内容：

- 何时提示/RAG 足够，何时考虑 SFT、LoRA/QLoRA、持续预训练或偏好优化。
- 数据质量、许可、隐私、灾难性遗忘和评测闭环。
- prefill/decode、KV Cache、continuous batching、PagedAttention、量化和 speculative decoding。
- TTFT、TPOT/ITL、tokens/s、并发、吞吐、队列和显存指标。
- API 模型、开源自托管、专用小模型和混合路由的成本/合规/运维权衡。

数据并行、张量并行、流水线并行、ZeRO/FSDP、RLHF/PPO/DPO 只保留概念与选型边界，不把训练框架实操作为转型主线。

## 09 资料导读与版本风险

建立主题到 `raw_llm/` 和 `raw_llm_doc/` 的映射，并把资料分为：Agent 主线必读、模型基础选读、训练研究参考、历史框架/版本风险。

不为 92 份 PDF 逐份复制正文；Markdown 为主要线索，PDF 用于补缺和交叉检查。`main.py`、IDE 文件和依赖清单只视为资料处理附属物，不进入 AI 知识结论。

## 大模型核心机制深入

集中放置应用工程师需要真正算清楚的模型机制：

- tokenizer 训练目标、词表大小、token/字符比和多语言效率。
- embedding 矩阵、余弦相似度、归一化与语义空间限制。
- `Q=XW_Q`、`K=XW_K`、`V=XW_V`、scaled dot-product attention、mask 和张量形状。
- 标准 Attention 随序列长度的 `O(L²)` score 矩阵边界，以及 FlashAttention 改善内存访问但不改变所有理论计算的边界。
- 残差、LayerNorm/RMSNorm、FFN、激活函数与梯度传播的职责。
- RoPE/相对位置、上下文扩展和“支持长度”与“有效利用长度”的区别。
- 交叉熵、perplexity、next-token prediction 与 teacher forcing。
- 参数显存、训练梯度/优化器/激活，以及推理权重/KV Cache 的估算。
- LoRA 参数量 `r(d_in+d_out)` 与秩、目标层、数据质量的关系。
- prefill 与 decode 的计算/访存差异，量化和 batching 的精度—延迟—吞吐取舍。

这一章负责公式和张量推导，主章节负责学习顺序与工程解释，避免两处重复展开。

## Agent 运行机制与可靠性深入

集中放置跨章节的内部模型和定量推导：

- Agent loop、状态机、事件日志、checkpoint 与确定性重放边界。
- tool call 的 at-least-once 风险、幂等键、去重表和补偿。
- 上下文预算：固定指令、历史、检索、工具结果和输出 token 的分配。
- 摘要压缩的信息丢失、长期记忆写入/召回与冲突解决。
- RAG 向量相似度、ANN 召回—延迟、rerank 和 context packing 成本。
- 推理的 TTFT/TPOT、排队、并发与 Little's Law 关系。
- KV Cache 近似：`2 × layers × tokens × kv_heads × head_dim × bytes × batch`，只用于部署选型。
- 多 Agent 的消息拓扑、共享状态、死锁/活锁、循环和预算放大。
- Trace 如何串联 prompt、检索、模型、工具、状态变更和用户输出。

Agent 深入章不重复 Transformer 与训练公式，只引用大模型核心机制章的上下文、KV Cache 和推理结论。

## 来源与纠错策略

1. 先从 96 份 Markdown 建立主题清单和重复关系。
2. 用 PDF 标题、目录和文本层补充 Markdown 缺失点；图表关键结论需要回看页面。
3. 稳定原理优先核对原始论文或开放教材。
4. PyTorch、Transformers、PEFT、vLLM、DeepSpeed、LangChain 等行为以当前官方文档和 release notes 为准。
5. 不能确认的性能数字、模型排名和“最佳实践”改写为影响因素与验证方法。
6. 资料中的拼写、公式和概念错误只在新文档纠正，不回写原始资料。

## 验收

- 新目录十篇文档、两篇深入章和两个总入口均存在，学习路径可从 `knowledge-base/README.md` 到达。
- 转型路线明确映射 Web、数据库、队列、分布式系统、网络和可观测性经验，训练研究不占主线。
- 大模型基础是必修，覆盖必要数学、tokenization、embedding、Transformer、训练阶段、生成和能力边界。
- Agent 工程覆盖 LLM 接口、RAG/记忆、工具/MCP、编排、多 Agent、生产可靠性、评测安全与部署选型。
- 至少包含 Attention 张量/复杂度、训练/推理显存、token/上下文预算、模型 API 成本、RAG 指标、Agent 步数/预算、Little's Law 和 KV Cache 八类定量关系。
- 每个主题解释基础、核心机制、使用案例、解决的问题、失败模式和版本边界。
- 关键旧结论被标为历史/版本相关或已纠正；不复制大段原文。
- 不修改 `raw_llm/` 与 `raw_llm_doc/`，不运行训练、部署和向量库实验。
- 所有新 Markdown 的本地链接有效、代码围栏配对、无尾随空格和占位内容。
