# 平台命名约定

## 命名空间

推荐使用：
- `cicd`：Jenkins
- `harbor`：Harbor
- `argocd`：Argo CD
- `test`：首个部署环境

## 仓库命名

### 服务源码仓库
模式：
- `<service-name>`

示例：
- `demo-java-service`

### GitOps 仓库
模式：
- `<service-name>-gitops`

示例：
- `demo-java-service-gitops`

## Argo CD Application 名称

模式：
- `<service-name>-<environment>`

示例：
- `demo-java-service-test`

## 镜像仓库命名

模式：
- `<harbor-host>/<project>/<service-name>`

示例：
- `harbor.example.com/test/demo-java-service`

## 镜像标签命名

推荐模式：
- `git-<shortsha>-<build-number>`

示例：
- `git-a1b2c3d-18`
