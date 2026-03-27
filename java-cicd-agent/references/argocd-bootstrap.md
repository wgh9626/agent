# Argo CD 初始化接管

## 目标

让 Argo CD 开始接管 `test` 环境对应的 GitOps 仓库。

## 推荐步骤

1. 将 Argo CD 部署到 `argocd` 命名空间。
2. 确保 Argo CD 能读取 GitOps 仓库。
3. 应用 GitOps 仓库中的 `application.yaml`，或者通过 Argo CD 创建等价应用。
4. 确认应用指向：
   - 正确的仓库 URL
   - 正确的分支
   - 正确的路径，例如 `apps/test`
5. 如有需要，在首次验证完成后再开启自动同步。

## 首次验证

确认应用状态变为：
- `Synced`
- `Healthy`

## 说明

- 如果目标命名空间可能尚不存在，可使用 `CreateNamespace=true`。
- 第一版范围应限制在 `test` 命名空间。
- 初期建议每个服务/环境路径对应一个 Application。
