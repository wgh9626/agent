# Jenkins 安装说明

## 目标

在 k3s 的 `cicd` 命名空间中运行 Jenkins，作为 CI 控制平面。

## 最低要求

- 为 Jenkins Home 提供持久化存储
- 拥有管理员初始化访问能力
- 安装 Pipeline、Git、Credentials、YAML、Kubernetes Agent 等必要插件

## 建议的初始配置

- 命名空间：`cicd`
- 为 `/var/jenkins_home` 配置持久卷
- 配置源码仓库凭据
- 配置 GitOps 仓库凭据
- 配置 Harbor Docker config JSON 凭据

## Kubernetes Agent 方向

优先使用 Jenkins Kubernetes Agent 来执行 Maven + Kaniko 构建。
相较于 Docker-in-Docker，这种方式更符合目标 k3s 平台模型。

## 首次验证

- Jenkins 可访问
- 一个简单 pipeline 能运行
- Kubernetes Agent Pod 能正常启动
- Agent 中的 Maven 构建成功
- Agent Pod 中的 Kaniko 容器能正常启动
