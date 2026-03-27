# 平台初始化顺序

## 阶段一：基础集群

1. 安装 k3s
2. 确认存储与 ingress 方案
3. 创建或规划命名空间：`cicd`、`harbor`、`argocd`、`test`

## 阶段二：镜像仓库

1. 在 `harbor` 命名空间安装 Harbor
2. 配置 HTTPS
3. 创建初始项目，例如 `test`
4. 为 CI 推送创建 robot account

## 阶段三：CI

1. 在 `cicd` 命名空间安装 Jenkins
2. 配置必要插件
3. 配置源码仓库、GitOps 仓库和 Harbor 凭据
4. 确认 Maven + Kaniko Agent 可以运行

## 阶段四：GitOps 控制平面

1. 在 `argocd` 命名空间安装 Argo CD
2. 注册 GitOps 仓库访问权限
3. 为 `test` 创建第一个 Application
4. 确认状态为 `Synced` 与 `Healthy`（同步成功且状态健康）

## 阶段五：首个服务

1. 准备服务源码仓库
2. 准备 GitOps 仓库
3. 触发第一次 Jenkins 发布
4. 在 `test` 命名空间验证服务

## 规则

在完整 `test` 发布链路可重复、可观测之前，不要扩展到 staging 或 production。
