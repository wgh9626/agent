# Argo CD 安装说明

## 目标

在 `argocd` 命名空间中运行 Argo CD，用于管理平台上的 GitOps 应用同步。

## 最低要求

- `argocd` 命名空间
- 管理员初始化访问能力
- 可访问 GitOps 仓库

## 建议的初始配置

- 将 Argo CD 安装到 `argocd` 命名空间
- 确保它可以访问 GitOps 仓库
- 为第一个 `test` 服务创建一个 Application
- 让初始范围保持小而可观察

## 推荐的首个应用

- 应用名：`demo-java-service-test`
- 仓库路径：`apps/test`
- 命名空间：`test`

## 首次验证

- Argo CD UI / API 可访问
- Application 创建成功
- 应用状态变为 `Synced`
- 应用状态变为 `Healthy`
