# GitOps 多环境结构

## 建议结构

```text
<service>-gitops/
└── apps/
    ├── test/
    │   ├── namespace.yaml
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   ├── kustomization.yaml
    │   └── application.yaml
    ├── staging/
    │   ├── namespace.yaml
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   ├── kustomization.yaml
    │   └── application.yaml
    └── prod/
        ├── namespace.yaml
        ├── deployment.yaml
        ├── service.yaml
        ├── kustomization.yaml
        └── application.yaml
```

## 建议

- 第一阶段只从 `test` 开始
- `test` 稳定后再复制模式到 `staging`
- 最后再引入 `prod`，并配更严格的审批与回滚控制

## 规则

每个环境路径都应做到独立可理解、独立可部署。
