# agent

一个演示 **Java 服务从代码到发布结果** 的样板仓库。

仓库分成三部分：

- `java-cicd-agent/`：发布脚本、模板、文档和执行入口
- `demo-java-service/`：示例 Java 服务、`Jenkinsfile` 和发布配置
- `demo-java-service-gitops/`：示例 GitOps 清单与镜像更新落点

> 服务仓库产出代码版本，CI/CD Agent 负责发布编排，GitOps 仓库负责部署落地。

---

## 这套仓库解决什么问题

很多 CI/CD 样板的问题不是“没有脚本”，而是：

- 文档一套
- 模板一套
- 脚本实际又是一套

这个仓库的目标，是把下面这条链路讲清楚并收平：

```text
代码变更
  ↓
明确 git ref
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

## 仓库内容

### `java-cicd-agent/`
Java CI/CD Agent 本体，包含发布脚本、请求 / 结果模板，以及 Jenkins、Harbor、Argo CD、k3s 等参考文档。

### `demo-java-service/`
最小 Java 服务示例，包含 `pom.xml`、`Dockerfile`、`Jenkinsfile`、`ci/release-config.yaml` 和示例清单。

### `demo-java-service-gitops/`
最小 GitOps 示例仓库，包含 test 环境下的 Deployment、Service、Application、Kustomization 和 Namespace 清单。

---

## 快速开始

建议按这个顺序阅读：

1. `java-cicd-agent/README.md`
2. `java-cicd-agent/docs/请求文件说明.md`
3. `java-cicd-agent/docs/脚本说明.md`
4. `java-cicd-agent/docs/Jenkins对接说明.md`
5. `java-cicd-agent/docs/一次完整演示文档.md`
6. `demo-java-service/Jenkinsfile`
7. `demo-java-service/ci/release-config.yaml`
8. `demo-java-service-gitops/apps/test/deployment.yaml`

如果只想快速抓重点，就记住三件事：

- `java-cicd-agent/` 定义怎么发
- `demo-java-service/` 提供要发什么
- `demo-java-service-gitops/` 决定最终部署到哪里

---

## 三者关系

```text
demo-java-service/
  └─ 提供源码、Jenkinsfile、发布配置

java-cicd-agent/
  └─ 接请求、执行构建/发布、输出结果

demo-java-service-gitops/
  └─ 承接镜像更新与 GitOps 发布落地
```

