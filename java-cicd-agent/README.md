# Java CI/CD Agent

这是一个用于 Java 服务构建、镜像发布、部署验证与结构化结果输出的 Agent 骨架。

它的目标不是“把所有平台能力都堆上来”，而是先把职责边界和交付链路收清楚：

- 上游 Java 代码 Agent 负责源码与可发布版本
- Java CI/CD Agent 负责构建、发布、验证与结果返回

---

## 这个 Agent 解决什么问题

很多发布方案的问题不是没有脚本，而是契约漂移：

- 文档说一种口径
- JSON 模板长另一种口径
- 脚本实际又吃第三种口径

最后谁都觉得自己没错，但链路一跑就开始互相甩锅。

这个 Agent 的核心目标就是把下面几件事统一起来：

- 请求文件怎么写
- 脚本入口怎么接
- 发布结果怎么返回
- 上下游 Agent 的职责怎么划分

---

---

## 快速开始

如果你想最快理解这套 Agent，建议按下面顺序走：

### 第一步：先看契约，不要先看脚本细节
- `docs/请求文件说明.md`
- `docs/release-request字段字典.md`
- `docs/release-result字段字典.md`

原因很简单：先知道“输入是什么、输出是什么”，再去看脚本，脑子不容易打结。

### 第二步：再看执行链
- `docs/脚本说明.md`
- `scripts/run_release_from_request.sh`
- `scripts/release.sh`

重点看：
- 请求 JSON 怎么被解析
- 参数怎么一路传进执行脚本
- 结果 JSON 最终怎么吐出来

### 第三步：再看协作边界
- `docs/职责说明.md`
- `docs/交互流程.md`
- `docs/上游Agent快速接入.md`

这一段是防止上下游 Agent 互相越位。

### 第四步：最后看参考资料
- `references/first-release-checklist.md`
- `references/first-release-runbook.md`
- `references/release-config-reference.md`

如果你准备第一次试发布，这三份最值得先看。

## 建议先看什么

### 1. 先看全貌
- `docs/首页摘要.md`
- `docs/架构图.md`
- `docs/调用链图.md`
- `docs/术语表.md`
- `docs/文档导航.md`

适合先建立整体认知。

### 2. 再看职责边界
- `docs/职责说明.md`
- `docs/交互流程.md`
- `docs/状态枚举.md`
- `docs/AGENT_PROMPT.md`
- `docs/Agent协作约定.md`
- `docs/上游Agent快速接入.md`

适合理解：
- 上下游如何分工
- 谁该交什么
- 谁不该越界去做什么

### 3. 真正接发布契约
- `docs/请求文件说明.md`
- `docs/脚本说明.md`
- `docs/release-request字段字典.md`
- `docs/release-result字段字典.md`
- `references/parameters.md`
- `references/pipeline.md`
- `references/release-config-reference.md`
- `references/deploy-yaml-pattern.md`

适合理解：
- 请求参数怎么传
- 结果字段怎么读
- 脚本链怎么串
- YAML 与发布配置怎么组织

### 4. 如果你在搭平台
- `references/k3s-minimal-platform.md`
- `references/platform-bootstrap-order.md`
- `references/platform-layout-overview.md`
- `references/platform-endpoints-convention.md`
- `references/platform-naming-convention.md`
- `references/harbor-install-notes.md`
- `references/jenkins-install-notes.md`
- `references/argocd-install-notes.md`

适合理解平台依赖怎么落。

### 5. 如果你准备第一次试发布
- `references/first-release-checklist.md`
- `references/first-release-runbook.md`
- `references/customization-checklist.md`
- `references/safety.md`

适合拿来做第一次发布前的检查单。

---

## 目录结构

```text
java-cicd-agent/
├── README.md
├── SKILL.md
├── docs/
├── templates/
├── scripts/
└── references/
```

### `docs/`
中文文档区，主要放：
- 架构图
- 调用链图
- 职责说明
- 请求文件说明
- 脚本说明
- 状态枚举
- Agent Prompt
- 术语表
- 文档导航

### `templates/`
契约模板区，主要放：
- `release-request.json`
- `release-request.sample.local.json`
- `release-result.json`
- `release-result-failed.json`

### `scripts/`
执行脚本区，主要放：
- `prepare_source.sh`
- `run_release_from_request.sh`
- `release.sh`
- `build_java.sh`
- `build_image.sh`
- `push_image.sh`
- `deploy_k8s.sh`
- `update_gitops_image.sh`
- `check_argocd_app.sh`
- `verify_deploy.sh`
- `rollback.sh`

### `references/`
参考资料区，主要放：
- 平台设计说明
- 接入清单
- Jenkins / Harbor / Argo CD 参考
- 发布 Runbook
- 模板与实现笔记

---

## 两种发布模式

### 模式一：Direct（直发）
直接部署到 Kubernetes：

- 拉源码
- Maven 构建
- Docker 构建
- Push Harbor
- `kubectl apply`
- rollout / 健康检查验证

### 模式二：GitOps
通过 GitOps 仓库 + Argo CD 发布：

- 拉源码
- Maven 构建
- Docker 构建
- Push Harbor
- 更新 GitOps 仓库中的镜像引用
- 等待 Argo CD 同步
- rollout / 健康检查验证

---

## 当前这套实现的特点

目前这套实现更强调：

- 契约清楚
- 入口统一
- 结果结构化
- 文档 / 模板 / 脚本口径一致

它适合：
- 单服务最小闭环
- `test` 环境优先验证
- 作为后续增强的基础骨架

还不等于：
- 开箱即用的生产级交付平台

如果继续往生产方向走，后续建议补：
- 更严格的外部依赖校验
- 更稳健的 YAML 修改方式
- 更完整的结果落盘与审计
- 更细粒度的回滚策略
- 更真实的 Jenkins / Argo CD / Harbor 集成

---

## 你最该记住的一句话

上游 Agent 负责给出明确源码版本，
Java CI/CD Agent 负责把这个版本构建、发布、验证，并返回结构化结果。

别把“代码提交成功”误当成“发布已经成功”。