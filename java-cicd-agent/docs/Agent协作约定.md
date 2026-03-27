# Agent 协作约定

本文件用于说明：当上游“Java 代码 Agent”与下游“Java CI/CD Agent”协作时，双方各自负责什么、如何交接、哪些事情不要互相乱碰。

## 一句话分工

- Java 代码 Agent：负责把代码写好，并交付一个可发布的源码版本。
- Java CI/CD Agent：负责把这个源码版本构建、打镜像、部署、验证并返回结果。

---

## 上游 Java 代码 Agent 负责什么

上游 Agent 负责：
- 编写和修改 Java 业务代码
- 更新 `pom.xml`、配置文件、必要的 `Dockerfile`
- 保证代码至少达到“可构建”状态
- 提供明确的 git ref（分支 / tag / commit）

上游 Agent 不负责：
- 推镜像到 Harbor
- 修改 GitOps 仓库中的镜像标签
- 直接部署 Kubernetes
- 宣称发布成功

---

## Java CI/CD Agent 负责什么

Java CI/CD Agent 负责：
- 接收发布请求
- 拉取源码
- 执行 Maven 构建
- 构建并推送镜像
- 更新 GitOps 仓库或直接部署
- 检查滚动发布状态与健康检查
- 输出结构化发布结果

Java CI/CD Agent 不负责：
- 编写业务逻辑
- 在没有明确要求时擅自修改业务代码
- 在验证未通过时假装发布成功

---

## 标准交接方式

上游 Agent 在交接时，至少应提供：

- `service_name`
- `git_repo`
- `git_ref`
- `build_path`
- `dockerfile_path`
- `image_repo`
- `image_tag`
- `deploy_mode`
- `deployment_name`
- `namespace`
- `healthcheck_url`

如果是 GitOps 模式，还应提供：

- `gitops_repo`
- `gitops_branch`
- `gitops_manifest_path`
- `container_name`
- `argocd_app_name`（推荐）

---

## 推荐交接文件

推荐使用：
- `templates/release-request.json`

由上游 Agent 填好参数后，交给 Java CI/CD Agent 执行。

---

## 调用链

```text
上游 Java 代码 Agent
  ↓
准备源码并给出 git ref
  ↓
release-request.json
  ↓
Java CI/CD Agent
  ↓
构建 / 推镜像 / 部署 / 验证
  ↓
release-result.json
```

---

## 协作红线

### 上游 Agent 不要做的事

- 不要直接改 GitOps 仓库中的镜像标签
- 不要在没构建验证的情况下声称“已经发了”
- 不要把部署结果和代码提交结果混为一谈

### Java CI/CD Agent 不要做的事

- 不要替上游 Agent 胡乱补业务逻辑
- 不要在缺参数时自己脑补
- 不要把 `kubectl apply` 成功误判为“发布成功”

---

## 成功的判断标准

一次真正成功的发布，至少应满足：

1. 源码版本明确
2. Maven 构建成功
3. 镜像构建成功
4. 镜像推送成功
5. 部署执行成功
6. 滚动发布状态检查成功
7. 健康检查成功

只要其中任意一步失败，就不能称为“发布成功”。

---

## 为什么要这样拆分

这样拆分的好处是：

- 职责更清楚
- 权限边界更清楚
- 问题定位更清楚
- 更容易替换上游模型而不影响下游发布逻辑

简单说：
- 写代码的，专心做菜
- 做 CI/CD 的，专心上菜
- 不要两个厨子一边炒菜一边抢着端盘子
