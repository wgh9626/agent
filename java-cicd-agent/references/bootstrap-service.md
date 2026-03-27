# 服务仓库初始化

当你需要把一个普通 Java 服务仓库改造成可被 CI/CD Agent 操作的仓库时，可参考本指南。

## 第一步：确认最小文件集

仓库至少应包含：

- `pom.xml`
- `Dockerfile`
- 应用源码

## 第二步：补充 CI/CD 文件

补充以下文件：

- `Jenkinsfile`
- `ci/release-config.yaml`
- `k8s/test/deployment.yaml`
- `k8s/test/service.yaml`

可从本 skill 的 `references/project-templates/` 中复制模板。

## 第三步：填写服务专属配置

更新以下内容：

- 服务名称
- Harbor 镜像仓库路径
- 健康检查路径
- 容器暴露端口
- Kubernetes labels / selectors

## 第四步：准备镜像占位符

在 `deployment.yaml` 中使用 `__IMAGE__`，这样 CI 就能安全注入镜像标签。

## 第五步：后续补 Jenkins 凭据

当基础设施就绪后，再配置：

- `harbor-robot`（用户名/密码）
- `kubeconfig-test`（文件型凭据）

## 第六步：先在本地或可信节点做 dry-run

在接入 Jenkins 之前，先手动验证：

- `mvn clean package -DskipTests`
- `docker build`
- `kubectl apply --dry-run=client -f k8s/test`

## 第七步：启用流水线

当 Jenkins 和 Harbor 已存在后：

- 创建 pipeline job
- 指向仓库中的 `Jenkinsfile`
- 添加所需凭据
- 在 `test` 命名空间执行首次部署
