# release-config.yaml 参考

## 必填字段

### `service_name`
逻辑服务名称，用于提交信息和发布上下文。

### `image_repo`
完整 Harbor 仓库路径，不包含镜像 tag。
示例：`harbor.example.com/test/demo-java-service`

### `gitops_repo`
部署状态所用的 Git 仓库地址。
示例：`https://git.example.com/team/demo-java-service-gitops.git`

### `gitops_manifest`
GitOps 仓库中目标 Deployment 清单路径。
示例：`apps/test/deployment.yaml`

## 常见可选字段

### `build_path`
包含 `pom.xml` 的目录。默认值：`.`

### `dockerfile_path`
Dockerfile 路径。默认值：`./Dockerfile`

### `gitops_branch`
GitOps 目标分支。默认值：`main`

### `argocd_app`
用于同步 / 健康检查的 Argo CD 应用名。

### `image_tag_strategy`
支持的值：
- `git-sha`
- `git-build-number`
- 回退策略：`build-<number>`

### `harbor_config_json_credentials_id`
Jenkins 中供 Kaniko 使用的 Harbor Docker config JSON 文件型凭据 ID。

### `gitops_git_credentials_id`
Jenkins 中用于克隆和推送 GitOps 仓库的凭据 ID。
