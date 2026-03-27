# Jenkins Agent 约定

## 目标

在 Kubernetes 上运行 Maven + Kaniko 流水线时，保持 Jenkins 构建 Agent 的结构一致。

## 推荐的 Agent 模型

- 每次 pipeline 运行使用一个 Kubernetes Pod
- 使用一个 `maven` 容器执行构建步骤
- 使用一个 `kaniko` 容器执行镜像构建与推送

## 命名约定

- agent label：`kaniko`
- 容器名称：`maven`、`kaniko`

## Workspace 规则

Maven 容器和 Kaniko 容器应共享同一份构建工作目录。

## 凭据规则

- Harbor 的 Docker config 只在需要的地方挂载
- Git 凭据应保留在 Jenkins Credentials 和 pipeline 步骤中管理

## 建议

第一版 Agent 模板要尽量简单、统一。
在一个基线模式稳定之前，不要过早创建很多“长得差不多但又不完全一样”的 Agent 模板。
