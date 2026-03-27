# 凭据矩阵

## 源码仓库

- 所有者：平台管理员或仓库管理员
- 存储位置：Jenkins Credentials
- 使用方：Jenkins Pipeline
- 用途：克隆服务源码仓库

## GitOps 仓库

- 所有者：平台管理员或仓库管理员
- 存储位置：Jenkins Credentials
- 使用方：Jenkins Pipeline
- 用途：克隆并推送 GitOps 更新

## Harbor 推送凭据

- 所有者：Harbor 管理员
- 存储位置：Jenkins secret file 凭据或 Kubernetes Secret
- 使用方：Jenkins Agent 中的 Kaniko
- 用途：推送构建好的镜像到 Harbor

## Argo CD 仓库访问凭据

- 所有者：平台管理员
- 存储位置：Argo CD 的仓库凭据/配置
- 使用方：Argo CD
- 用途：读取 GitOps 仓库

## 可选的 Argo CD CLI/API Token

- 所有者：平台管理员
- 存储位置：若需要，可放在 Jenkins Credentials
- 使用方：Jenkins 或自动化检查逻辑
- 用途：通过 CLI/API 查询应用同步与健康状态

## 规则

除非没有更安全的初始化替代方案，否则不要在 CI 流水线中复用个人管理员凭据。
