# Kaniko + Argo CD 架构

## 目标流程

1. Jenkins 检出 Java 服务仓库。
2. Maven 构建 JAR。
3. Kaniko 构建镜像并推送到 Harbor。
4. Jenkins 更新 GitOps 仓库中的镜像标签。
5. Argo CD 发现 Git 变更，并将应用同步到 `test` 命名空间。
6. Agent 或 Jenkins 检查 Argo CD 的同步 / 健康状态，并验证 Kubernetes rollout。

## 为什么采用这条链路

- 避免在 Kubernetes CI 中依赖 Docker Daemon。
- 通过 GitOps 保持部署声明式。
- 提高镜像标签变更的可审计性。
- 让 Argo CD 成为部署状态的控制者。

## 角色分工

- Jenkins：构建、Kaniko、更新 GitOps 仓库
- Harbor：镜像存储
- Argo CD：应用同步与健康状态
- Agent：流程编排、参数校验、状态汇报
