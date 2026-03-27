# Jenkins 插件基线

## 核心插件

- Pipeline
- Git
- Credentials
- Credentials Binding
- Plain Credentials
- Pipeline Utility Steps

## Kubernetes / Agent 相关

- Kubernetes

## 早期建议装上的增强插件

- Timestamper
- AnsiColor

## 为什么这些插件重要

- `Pipeline`：用于执行 Jenkinsfile
- `Git`：用于操作源码仓库和 GitOps 仓库
- `Credentials` 及其绑定插件：用于安全访问仓库和镜像仓库密钥
- `Pipeline Utility Steps`：提供 `readYaml` 等能力
- `Kubernetes`：用于动态创建 Maven + Kaniko 构建 Agent

## 规则

第一版插件集应保持小而够用。
只有在出现真实需求后，再继续加额外插件。
