# 基于 Kubernetes + Kaniko 的 Jenkins

## 目标

让 Jenkins pipeline 在 Kubernetes 内运行，并使用 Kaniko 构建镜像，从而避免依赖 Docker Daemon。

## 建议模型

- Jenkins Controller 运行在 `cicd` 命名空间
- Jenkins Agent 以 Kubernetes Pod 形式启动
- 一个容器负责 Maven 构建
- 一个容器负责 Kaniko 构建与推送

## 关键要求

- 将 Harbor Docker config JSON 挂载到 `/kaniko/.docker/config.json`
- 让 Maven 和 Kaniko 容器共享同一个 workspace
- 确保 Dockerfile 路径相对于 workspace 根目录可解析

## 典型流程

1. 检出源码
2. 在 Maven 容器中构建 JAR
3. 使用 Kaniko 构建并推送镜像
4. 更新 GitOps 仓库
5. 等待 Argo CD 同步 / 健康状态

## 说明

- GitOps 更新与 Harbor 推送应使用独立凭据。
- 第一版建议只面向 `test` 命名空间。
- 等“通路跑通”后，再考虑缓存优化。
