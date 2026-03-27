# release-request 字段字典

本文档用于解释 `templates/release-request.json` 与 `scripts/run_release_from_request.sh` 实际支持的字段含义、是否必填、常见示例和注意事项。

## 使用原则

- 字段名保持英文，作为脚本与 Agent 的稳定接口。
- 字段说明使用中文，便于人快速阅读。
- 以当前脚本实现为准：文档描述必须与 `run_release_from_request.sh` 的解析逻辑一致。
- 当前请求文件**不支持** `timeout_seconds`；执行入口会固定传 `300` 秒给 `release.sh`。

---

## 当前脚本会解析的字段

### `service_name`
- 含义：逻辑服务名称。
- 是否必填：是
- 示例：`demo-java-service`
- 说明：用于日志、结果输出、源码缓存目录命名等场景。

### `git_repo`
- 含义：服务源码仓库地址。
- 是否必填：是
- 示例：`https://git.example.com/team/demo-java-service.git`
- 说明：`prepare_source.sh` 会基于这个地址拉取源码。

### `git_ref`
- 含义：要发布的代码版本。
- 是否必填：是
- 示例：`main`、`release/1.0.0`、`a1b2c3d`
- 说明：可以是分支、tag 或 commit SHA。

### `build_path`
- 含义：Maven 构建目录。
- 是否必填：是
- 示例：`.`、`services/order-service`
- 说明：脚本当前会校验该字段非空。

### `dockerfile_path`
- 含义：Dockerfile 路径。
- 是否必填：是
- 示例：`./Dockerfile`
- 说明：脚本当前会校验该字段非空。

### `image_repo`
- 含义：目标镜像仓库，不包含 tag。
- 是否必填：是
- 示例：`harbor.example.com/test/demo-java-service`
- 说明：最终镜像引用会被拼成 `image_repo:image_tag`。

### `image_tag`
- 含义：本次发布使用的镜像标签。
- 是否必填：是
- 示例：`20260326-1045-abcd123`
- 说明：建议具备可追溯性，避免正式发布使用 `latest`。

### `deploy_mode`
- 含义：发布模式。
- 是否必填：是
- 示例：`direct`、`gitops`
- 说明：`release.sh` 目前只支持这两种模式。

### `deployment_name`
- 含义：Kubernetes Deployment 名称。
- 是否必填：是
- 示例：`demo-java-service`
- 说明：用于滚动发布检查与失败回滚。

### `namespace`
- 含义：目标 Kubernetes 命名空间。
- 是否必填：是
- 示例：`test`
- 说明：当前脚本会对非 `test` 命名空间打印提醒，但不会阻止执行。

### `healthcheck_url`
- 含义：健康检查地址。
- 是否必填：是
- 示例：`http://demo-java-service.test.svc.cluster.local/actuator/health`
- 说明：`run_release_from_request.sh` 当前会校验该字段非空，并传给 `verify_deploy.sh`。

### `rollback_on_fail`
- 含义：失败时是否允许按策略自动回滚。
- 是否必填：否
- 示例：`true`
- 说明：布尔值会被请求入口转成字符串 `true` / `false` 传给 `release.sh`。

### `manifest_path`
- 含义：源码仓库中的部署清单路径。
- 是否必填：`deploy_mode=direct` 时必填
- 示例：`k8s/deployment.yaml`
- 说明：仅在直发模式下使用；若 direct 模式缺少此字段，`release.sh` 会直接失败。

### `gitops_repo`
- 含义：GitOps 仓库地址。
- 是否必填：`deploy_mode=gitops` 时必填
- 示例：`https://git.example.com/team/demo-java-service-gitops.git`
- 说明：GitOps 模式下会额外拉取该仓库。

### `gitops_branch`
- 含义：GitOps 目标分支。
- 是否必填：否
- 示例：`main`
- 说明：如果未填写，`run_release_from_request.sh` 会默认使用 `main`。

### `gitops_manifest_path`
- 含义：GitOps 仓库中待更新的 Deployment 清单路径。
- 是否必填：`deploy_mode=gitops` 时必填
- 示例：`apps/test/deployment.yaml`
- 说明：`update_gitops_image.sh` 会基于该路径更新镜像引用。

### `container_name`
- 含义：Deployment 中要更新镜像的容器名称。
- 是否必填：`deploy_mode=gitops` 时必填
- 示例：`demo-java-service`
- 说明：当前脚本仅在 GitOps 模式下使用该字段。

### `argocd_app_name`
- 含义：Argo CD Application 名称。
- 是否必填：否
- 示例：`demo-java-service-test`
- 说明：若提供，`release.sh` 会在 GitOps 模式下额外执行 Argo CD 状态检查，并在结果里输出 `argocd_app` 字段。

### `build_notes`
- 含义：供人阅读的构建补充说明。
- 是否必填：否
- 示例：`["需要 JDK 17", "使用 Maven profile: test"]`
- 说明：当前脚本会解析该字段，但不会把它传给 `release.sh`，因此它只起到请求备注作用，不参与执行逻辑。

---

## direct / gitops 模式差异

### direct 模式至少要保证
- `service_name`
- `git_repo`
- `git_ref`
- `build_path`
- `dockerfile_path`
- `image_repo`
- `image_tag`
- `deploy_mode=direct`
- `deployment_name`
- `namespace`
- `healthcheck_url`
- `manifest_path`

### gitops 模式至少要保证
- `service_name`
- `git_repo`
- `git_ref`
- `build_path`
- `dockerfile_path`
- `image_repo`
- `image_tag`
- `deploy_mode=gitops`
- `deployment_name`
- `namespace`
- `healthcheck_url`
- `gitops_repo`
- `gitops_manifest_path`
- `container_name`

可选增强字段：
- `gitops_branch`
- `argocd_app_name`
- `rollback_on_fail`

---

## 当前未支持字段

### `timeout_seconds`
- 当前状态：**请求文件未支持**
- 说明：虽然 `release.sh` 有 `timeout_seconds` 参数，但 `run_release_from_request.sh` 目前固定传 `300`，不会从 JSON 中读取这个字段。

---

## 一句话理解

`release-request.json` 是给 `run_release_from_request.sh` 喂参数的结构化请求；哪些字段能写、哪些字段会生效，以脚本当前实际解析结果为准。