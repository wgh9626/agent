# GitOps 仓库初始化

## 目标

创建一个专用 GitOps 仓库，并让 Argo CD 监听其中的部署状态。

## 推荐的初始结构

```text
<service>-gitops/
└── apps/
    └── test/
        ├── deployment.yaml
        ├── service.yaml
        ├── kustomization.yaml
        └── application.yaml
```

## 初始步骤

1. 创建 GitOps 仓库。
2. 提交初始清单，并在 `deployment.yaml` 中保留 `__IMAGE__`。
3. 创建指向 `apps/test` 的 Argo CD `Application`。
4. 让 Jenkins 在发布时只更新 `apps/test/deployment.yaml`。
5. 让 Argo CD 自动同步，或按需手动同步。

## 首次发布流程

1. 使用 Kaniko 构建并推送镜像。
2. 更新 `deployment.yaml` 中的镜像。
3. 提交并推送到 GitOps 仓库。
4. 由 Argo CD 收敛到新状态。
5. 检查 Argo CD 同步与健康状态。

## 重要规则

不要把服务源码放进 GitOps 仓库。它应只关注部署状态本身。
