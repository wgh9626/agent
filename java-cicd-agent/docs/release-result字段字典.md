# release-result 字段字典

本文档用于解释 `scripts/release.sh` 实际输出的结果字段含义，并与 `templates/release-result.json`、`templates/release-result-failed.json` 保持一致。

## 使用原则

- 以 `release.sh` 的真实输出为准。
- 成功与失败结果尽量共用同一批核心字段，便于上游 Agent、Jenkins 或其他自动化稳定消费。
- 当前结果结构里**没有**布尔型 `success` 字段；状态由 `status` 与各阶段结果字段表达。

---

## 核心结果字段

### `service_name`
- 含义：服务名称。
- 类型：字符串
- 示例：`demo-java-service`
- 说明：对应请求中的 `service_name`。

### `git_ref`
- 含义：本次发布使用的源码版本。
- 类型：字符串
- 示例：`main`、`release/1.0.0`、`a1b2c3d`

### `image`
- 含义：完整镜像引用。
- 类型：字符串
- 示例：`harbor.example.com/test/demo-java-service:20260326-1045-abcd123`
- 说明：由 `image_repo:image_tag` 拼接生成。

### `deploy_mode`
- 含义：本次发布采用的模式。
- 类型：字符串
- 示例：`direct`、`gitops`

### `namespace`
- 含义：目标命名空间。
- 类型：字符串
- 示例：`test`

### `stage_reached`
- 含义：当前执行到的最后阶段，或失败时停下来的阶段。
- 类型：字符串
- 示例：`build`、`image`、`push`、`deploy`、`verify`
- 说明：这是当前脚本用于定位失败阶段的正式字段名，不是 `stage`。

### `status`
- 含义：本次发布最终状态。
- 类型：字符串
- 示例：`success`、`failed`、`rolled_back`
- 说明：当前脚本输出为**小写枚举值**。

### `next_action`
- 含义：下一步建议动作。
- 类型：字符串
- 示例：`none`、`检查 Harbor 凭据、仓库与网络后重试`
- 说明：用于给上游 Agent 或人工排障提供直接建议。

---

## 阶段结果字段

### `build_result`
- 含义：Maven 构建阶段结果。
- 类型：字符串
- 示例：`success`、`failed`、`not_started`

### `image_push_result`
- 含义：镜像推送相关阶段结果。
- 类型：字符串
- 示例：`success`、`failed`、`not_started`
- 说明：当前脚本没有单独输出镜像构建字段，镜像构建失败会直接体现在 `status=failed` 且 `stage_reached=image`。

### `deploy_result`
- 含义：部署阶段结果。
- 类型：字符串
- 示例：`success`、`failed`、`not_started`
- 说明：在 GitOps 模式下，也包含更新 GitOps 清单及可选的 Argo CD 检查结果。

### `rollout_result`
- 含义：部署后 rollout 验证结果。
- 类型：字符串
- 示例：`success`、`failed`、`not_started`

### `health_check_result`
- 含义：健康检查结果。
- 类型：字符串
- 示例：`UP`、`DOWN`、`NOT_CHECKED`
- 说明：当前脚本使用大写状态值表达健康状态。

---

## GitOps / Argo CD 相关字段

### `argocd_app`
- 含义：Argo CD Application 名称。
- 类型：字符串
- 示例：`demo-java-service-test`
- 说明：仅在请求里提供了 `argocd_app_name`，且 `release.sh` 收到该值时才会输出。

---

## 回滚相关字段

### `rollback_performed`
- 含义：失败后是否已执行回滚。
- 类型：布尔值
- 示例：`true`、`false`
- 说明：这是当前脚本实际输出字段名，不是 `rollback_triggered`。

---

## 失败补充字段

### `error_summary`
- 含义：失败摘要。
- 类型：字符串
- 示例：`Maven 构建失败`
- 说明：仅在失败路径输出。

### `error_excerpt`
- 含义：错误日志摘录。
- 类型：字符串
- 示例：`[ERROR] cannot find symbol ...`
- 说明：通常为最近若干行日志摘录，便于快速排障。

---

## 当前结果中未输出的字段

以下字段如果出现在旧文档或讨论中，应以“当前脚本未输出”理解：

- `success`
- `image_repo`
- `image_tag`
- `deployment_name`
- `stage`
- `stages`
- `message`
- `error_message`
- `gitops_repo`
- `gitops_commit`
- `argocd_app_name`
- `argocd_sync_status`
- `argocd_health_status`
- `rollback_triggered`
- `rollback_result`
- `rollback_message`
- `started_at`
- `finished_at`
- `duration_seconds`
- `request_id`
- `git_repo`

---

## 成功判定建议

当前结构下，可按以下规则判断发布成功：

1. `status = success`
2. `build_result = success`
3. `image_push_result = success`
4. `deploy_result = success`
5. `rollout_result = success`
6. `health_check_result = UP`

如果任一步骤失败，则整体不应视为成功。

---

## 一句话理解

`release-result` 是 `release.sh` 的结构化回执；看它时请认准真实字段名，别把文档里长过的“理想字段”当成当前实现。