# Java CI/CD Agent

这是一个用于 Java 服务构建、打包、镜像发布、部署与验证的 Agent 骨架。

它的设计目标不是“什么都做”，而是把职责边界划清：

- 上游 Java 代码 Agent 负责写业务代码
- Java CI/CD Agent 负责交付与发布

---

## 建议阅读顺序

### 1. 快速理解全貌
- `docs/首页摘要.md`
- `docs/架构图.md`
- `docs/调用链图.md`
- `docs/术语表.md`
- `docs/文档导航.md`

适合第一次进入项目的人，先建立全局认识。

### 2. 理解职责与协作边界
- `docs/职责说明.md`
- `docs/交互流程.md`
- `docs/状态枚举.md`
- `docs/AGENT_PROMPT.md`
- `docs/Agent协作约定.md`
- `docs/上游Agent快速接入.md`

适合理解：
- 上下游 Agent 分工
- 发布流程怎么交接
- 状态如何表达
- Agent 应该怎么行动

### 3. 真正接入发布流程
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
- 脚本怎么串起来
- YAML 怎么安全改
- release-config 怎么写

### 4. 如果你在搭平台
- `references/k3s-minimal-platform.md`
- `references/platform-bootstrap-order.md`
- `references/platform-layout-overview.md`
- `references/platform-endpoints-convention.md`
- `references/platform-naming-convention.md`
- `references/harbor-install-notes.md`
- `references/jenkins-install-notes.md`
- `references/argocd-install-notes.md`

适合理解：
- k3s 平台组件怎么摆
- Harbor / Jenkins / Argo CD 怎么初始化
- 访问地址和命名怎么统一

### 5. 如果你准备第一次发布
- `references/first-release-checklist.md`
- `references/first-release-runbook.md`
- `references/customization-checklist.md`
- `references/safety.md`

适合理解：
- 首次发布前要查什么
- 失败回滚怎么约束
- 哪些边界不能乱碰

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

### docs/
放中文说明文档，包括：
- 架构图
- 调用链图
- 职责说明
- 请求文件说明
- 脚本说明
- 状态枚举
- Agent Prompt
- 术语表
- 文档导航

### templates/
放请求和结果模板，包括：
- `release-request.json`
- `release-request.sample.local.json`
- `release-result.json`
- `release-result-failed.json`

### scripts/
放执行脚本，包括：
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

### references/
放参考资料、平台设计说明、接入清单、发布 Runbook 与实现笔记。

---

## 核心模式

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
- Argo CD 同步
- 滚动发布状态 / 健康检查验证

---

## 当前定位

当前版本适合：
- 单服务
- `test` 环境优先
- 先跑通最小闭环
- 作为后续增强的基础骨架

当前版本还不是完整生产级系统，后续建议继续补：
- 更稳健的 YAML 修改方式
- 更完整的结果落盘机制
- 更细粒度的回滚策略
- 更真实的 Jenkins / Argo CD 集成

---

## 一句话总结

上游 Agent 负责产出源码版本，Java CI/CD Agent 负责把这个版本安全地构建、发布并验证落地。
