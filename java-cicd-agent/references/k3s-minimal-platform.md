# 面向 Java CI/CD Agent 的最小 k3s 平台

## 推荐命名空间

- `cicd`：Jenkins
- `harbor`：Harbor
- `argocd`：Argo CD
- `test`：测试环境工作负载

## 部署顺序

1. 安装 k3s
2. 安装 Harbor，并配置持久化存储与 HTTPS
3. 在 `cicd` 命名空间安装 Jenkins
4. 在 `argocd` 命名空间安装 Argo CD
5. 将第一个 demo 应用部署到 `test` 命名空间

## 最低凭据集

### Jenkins
- 源码仓库 Git 凭据
- GitOps 仓库 Git 凭据
- 供 Kaniko 使用的 Harbor Docker config JSON
- 如果需要 CLI/API 检查，可选 Argo CD token

### Harbor
- 用于测试镜像的项目
- 用于 CI 推送的 robot account

### Argo CD
- 访问 GitOps 仓库的权限
- 面向 `test` 的应用定义

## 推荐的首个里程碑

- Jenkins 中 Maven 构建成功
- Kaniko 构建并推送镜像成功
- 成功提交镜像变更到 GitOps 仓库
- 由 Argo CD 自动同步
- 在 `test` 环境验证应用健康状态
