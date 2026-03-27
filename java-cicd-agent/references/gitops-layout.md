# GitOps 仓库结构

```text
demo-java-service-gitops/
└── apps/
    └── test/
        ├── deployment.yaml
        ├── service.yaml
        └── application.yaml
```

## 说明

- 应用部署清单应保存在 GitOps 仓库，而不是应用源码仓库。
- Jenkins 只应更新 `deployment.yaml` 中的镜像标签或占位符。
- Argo CD 应监听 GitOps 仓库中对应 `test` 环境的路径。
