# 首次发布 Runbook

## 第一步：准备 k3s
- 安装并验证 k3s 集群。
- 确认 Harbor 和 Jenkins 所需存储可用。
- 规划命名空间：`cicd`、`harbor`、`argocd`、`test`。

## 第二步：部署 Harbor
- 使用 HTTPS 和持久化存储安装 Harbor。
- 为测试镜像创建目标项目。
- 为 CI 推送创建 robot account。
- 为 Jenkins / Kaniko 准备 Docker config JSON。

## 第三步：部署 Jenkins
- 在 `cicd` 命名空间安装 Jenkins。
- 添加源码仓库凭据。
- 添加 GitOps 仓库凭据。
- 添加 Harbor Docker config JSON 的 secret file 凭据。
- 确认 Kubernetes / Kaniko 构建 Agent 可运行。

## 第四步：准备服务仓库
- 提交 `Jenkinsfile`。
- 提交 `ci/release-config.yaml`。
- 提交 `ci/scripts/` 辅助脚本。
- 验证 `mvn clean package -DskipTests` 可工作。

## 第五步：准备 GitOps 仓库
- 提交 `deployment.yaml`、`service.yaml`、`namespace.yaml`、`kustomization.yaml`、`application.yaml`。
- 在首次发布前让 `deployment.yaml` 保留 `__IMAGE__`。
- 确认 Argo CD 可读取仓库。

## 第六步：初始化 Argo CD
- 应用或创建 Argo CD `Application`。
- 验证应用指向正确的仓库、分支与路径。
- 确认首次同步可成功。

## 第七步：执行首次发布
- 触发 Jenkins pipeline。
- 构建 JAR。
- 使用 Kaniko 构建并推送镜像。
- 更新 GitOps 清单。
- 推送 GitOps 提交。
- 等待 Argo CD 状态变为 `Synced` 与 `Healthy`（同步成功且状态健康）。

## 第八步：验证服务
- 确认 Pods 正常运行。
- 确认服务路由正确。
- 确认健康检查接口成功。
- 记录首个可工作的镜像标签。
