# 推荐的源码仓库结构

```text
.
├── Jenkinsfile
├── Dockerfile
├── pom.xml
├── ci/
│   └── release-config.yaml
└── k8s/
    └── test/
        ├── deployment.yaml
        └── service.yaml
```

## 说明

- 第一版建议把部署 YAML 放在应用仓库附近，方便理解和联调。
- `release-config.yaml` 建议作为服务级发布参数的统一入口。
- 凭据应保存在 Jenkins 中，而不是提交到仓库里。
- 当 GitOps 或应用同步可见性准备好后，再引入 Argo CD。
