# agent

一个用于演示 **Java 服务从代码到发布结果** 的样板仓库。

它把整条交付链拆成三部分：

- `java-cicd-agent/`：负责发布编排、脚本、模板和文档
- `demo-java-service/`：负责示例 Java 服务、`Jenkinsfile` 和发布配置
- `demo-java-service-gitops/`：负责示例 GitOps 清单与镜像更新落点

这不是“堆几个目录上来看看”的仓库，而是一套用来说明：

> Java 服务如何从源码版本，走到镜像、部署、验证，再落成结构化结果。

---

## 仓库包含什么

### 1) `java-cicd-agent/`
Java CI/CD Agent 本体。

里面包含：
- 发布入口脚本
- 请求 / 结果 JSON 模板
- Direct / GitOps 两种发布模式说明
- 调用链、职责、状态与字段字典文档
- Jenkins / Harbor / Argo CD / k3s 等参考资料

适合看这些场景：
- 想定义统一发布契约
- 想把脚本、模板、文档口径收平
- 想给上游 Agent 一个明确的发布入口

### 2) `demo-java-service/`
一个最小 Java 服务示例。

里面包含：
- `pom.xml`
- `Dockerfile`
- `Jenkinsfile`
- `ci/release-config.yaml`
- `k8s/test/` Kubernetes 示例清单

适合看这些场景：
- Java 服务如何对接这套发布链
- Jenkins Pipeline 怎么接发布配置
- 应用侧需要准备哪些基础文件

### 3) `demo-java-service-gitops/`
一个最小 GitOps 示例仓库。

里面包含：
- `apps/test/deployment.yaml`
- `apps/test/service.yaml`
- `apps/test/application.yaml`
- `apps/test/kustomization.yaml`
- `apps/test/namespace.yaml`

适合看这些场景：
- GitOps 模式下镜像标签如何更新
- GitOps 仓库最小结构长什么样
- Argo CD / GitOps 的清单落点如何组织

---

## 这套仓库想解决什么问题

很多所谓 CI/CD 样板，问题不在“没有脚本”，而在：

- 文档写 A
- JSON 模板长 B
- 脚本实际吃 C

最后发布链像三拨人在不同群里同步消息。

这个仓库的目标就是把这些口径尽量收平，让下面这条链路更清楚：

```text
Java 代码变更
  ↓
给出明确 git ref
  ↓
构建 JAR
  ↓
构建并推送镜像
  ↓
Direct 或 GitOps 发布
  ↓
rollout / healthcheck 验证
  ↓
输出结构化 release-result
```

---

## 如果你第一次打开这个仓库

建议按下面顺序读：

1. `java-cicd-agent/README.md`
2. `java-cicd-agent/docs/首页摘要.md`
3. `java-cicd-agent/docs/交互流程.md`
4. `java-cicd-agent/docs/请求文件说明.md`
5. `java-cicd-agent/docs/脚本说明.md`
6. `demo-java-service/Jenkinsfile`
7. `demo-java-service/ci/release-config.yaml`
8. `demo-java-service-gitops/apps/test/deployment.yaml`

如果你只想快速抓重点，先看：

- Agent 怎么接请求
- 服务怎么提供构建与发布信息
- GitOps 仓库怎么接收镜像变更

---

## 快速理解三者关系

```text
demo-java-service/
  └─ 提供源码、Jenkinsfile、发布配置

java-cicd-agent/
  └─ 负责接请求、跑构建/发布脚本、输出结果

demo-java-service-gitops/
  └─ 负责承接镜像更新与 GitOps 发布落地
```

一句人话：

- 服务仓库负责“把菜做出来”
- CI/CD Agent 负责“把菜端出去并检查有没有翻桌”
- GitOps 仓库负责“记录这桌菜最终上的是哪一盘”

---

## 当前定位

当前仓库更适合这些用途：

- 方案样板
- Demo 仓库
- 首轮测试基线
- 发布契约设计底稿
- Agent 协作骨架

它已经适合做：
- 结构演示
- 文档对齐
- 脚本联调
- 最小发布链路验证

但它还不是完整生产级平台；如果要走向生产，还需要继续补：

- 更完整的外部依赖准备
- 更严格的环境校验
- 更细粒度的回滚与审计
- 更真实的 Jenkins / Argo CD / Harbor 集成

---

## 从哪里开始最合适

### 如果你关心整体设计
从这里开始：
- `java-cicd-agent/README.md`
- `java-cicd-agent/docs/文档导航.md`

### 如果你关心请求 / 结果契约
从这里开始：
- `java-cicd-agent/docs/请求文件说明.md`
- `java-cicd-agent/docs/release-request字段字典.md`
- `java-cicd-agent/docs/release-result字段字典.md`

### 如果你关心示例服务怎么接入
从这里开始：
- `demo-java-service/Jenkinsfile`
- `demo-java-service/ci/release-config.yaml`

### 如果你关心 GitOps 落地长什么样
从这里开始：
- `demo-java-service-gitops/apps/test/deployment.yaml`
- `demo-java-service-gitops/apps/test/application.yaml`

---

## 一句话总结

这个仓库不是为了显得复杂，而是为了把：

- Agent 怎么编排
- 服务怎么构建
- 发布怎么落地
- 结果怎么结构化返回

这几件事讲清楚、对齐、跑顺。