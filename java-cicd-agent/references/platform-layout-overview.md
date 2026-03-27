# 平台结构总览

## 第一层：k3s 上的平台组件

- `harbor` 命名空间：Harbor
- `cicd` 命名空间：Jenkins
- `argocd` 命名空间：Argo CD
- `test` 命名空间：已部署服务

## 第二层：仓库

### 服务源码仓库
包含：
- Java 源代码
- `pom.xml`
- `Dockerfile`
- `Jenkinsfile`
- `ci/release-config.yaml`
- `ci/scripts/`

### GitOps 仓库
包含：
- `apps/test/deployment.yaml`
- `apps/test/service.yaml`
- `apps/test/namespace.yaml`
- `apps/test/kustomization.yaml`
- `apps/test/application.yaml`

## 第三层：发布流

1. Jenkins 检出服务仓库。
2. Maven 构建产物。
3. Kaniko 构建并推送镜像到 Harbor。
4. Jenkins 更新 GitOps 仓库中的镜像引用。
5. Argo CD 将期望状态收敛到 `test` 命名空间。
6. Agent 或自动化逻辑检查同步、健康和服务就绪状态。
