# agent

这是一个用于演示和验证 Java 服务 CI/CD 交付链路的仓库，当前包含三部分：

- `java-cicd-agent/`：Java CI/CD Agent 骨架、脚本、模板与文档
- `demo-java-service/`：示例 Java 服务，包含 `Jenkinsfile`、Kubernetes 清单与发布配置
- `demo-java-service-gitops/`：示例 GitOps 仓库，演示镜像更新与 Argo CD / GitOps 发布路径

## 目录说明

### `java-cicd-agent/`
用于承载 CI/CD Agent 本体：
- 发布入口脚本
- 请求/结果 JSON 模板
- Direct / GitOps 两种模式说明
- 交付链路文档与参考资料

建议先读：
- `java-cicd-agent/README.md`
- `java-cicd-agent/docs/首页摘要.md`
- `java-cicd-agent/docs/请求文件说明.md`
- `java-cicd-agent/docs/脚本说明.md`

### `demo-java-service/`
一个最小 Java 服务示例，包含：
- `pom.xml`
- `Dockerfile`
- `Jenkinsfile`
- `k8s/test/` Kubernetes 示例清单
- `ci/release-config.yaml` 发布配置

适合用来演示：
- Java 构建
- 镜像打包
- Jenkins Pipeline
- 发布参数收敛

### `demo-java-service-gitops/`
一个最小 GitOps 示例仓库，包含：
- `apps/test/deployment.yaml`
- `apps/test/service.yaml`
- `apps/test/application.yaml`
- `apps/test/kustomization.yaml`

适合用来演示：
- 镜像标签更新
- GitOps 提交与推送
- Argo CD 同步入口

---

## 当前仓库能做什么

这套内容的目标不是一上来就做成生产级平台，而是先把下面这条链路讲清楚并跑通：

```text
Java 代码变更
  ↓
构建 JAR
  ↓
构建并推送镜像
  ↓
Direct 或 GitOps 发布
  ↓
rollout / healthcheck 验证
  ↓
输出结构化发布结果
```

---

## 推荐阅读顺序

如果你是第一次看这个仓库，建议按顺序读：

1. `java-cicd-agent/README.md`
2. `java-cicd-agent/docs/首页摘要.md`
3. `java-cicd-agent/docs/交互流程.md`
4. `java-cicd-agent/docs/请求文件说明.md`
5. `java-cicd-agent/docs/脚本说明.md`
6. `demo-java-service/Jenkinsfile`
7. `demo-java-service/ci/release-config.yaml`
8. `demo-java-service-gitops/apps/test/deployment.yaml`

---

## 当前定位

当前仓库更偏向：
- 方案样板
- Agent 协作骨架
- Java 服务最小交付闭环示例
- CI/CD / GitOps 接入演示

还不是完整生产级平台，但已经适合作为：
- 设计讨论底稿
- Demo 仓库
- 首轮测试样板
- 后续增强的基线

---

## 一句话总结

这个仓库把“Java 服务怎么从代码走到发布结果”拆成了三块：

- Agent 怎么编排
- 服务怎么构建
- GitOps 怎么落地

目标不是花哨，而是把链路说清楚、对齐、跑通。