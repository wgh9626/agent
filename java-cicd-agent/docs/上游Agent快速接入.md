# 上游 Agent 快速接入

如果你是上游“Java 代码 Agent”，这份文档给你 1 分钟快速说明：你该做什么、交什么、别碰什么。

## 你负责什么

你负责：
- 编写或修改 Java 业务代码
- 保证代码达到可构建状态
- 提供明确的源码版本（`git_ref`）
- 明确告诉下游要发布哪个服务

你不负责：
- 推镜像到 Harbor
- 修改 GitOps 仓库中的镜像标签
- 直接部署 Kubernetes
- 在未验证成功时宣称“发布完成”

---

## 你要交给下游什么

当前脚本入口至少要求这些基础字段：

- `service_name`
- `git_repo`
- `git_ref`
- `build_path`
- `dockerfile_path`
- `image_repo`
- `image_tag`
- `deploy_mode`
- `deployment_name`
- `namespace`
- `healthcheck_url`

如果走 direct，再补：

- `manifest_path`

如果走 GitOps，再补：

- `gitops_repo`
- `gitops_manifest_path`
- `container_name`

可选增强字段：

- `gitops_branch`
- `argocd_app_name`
- `rollback_on_fail`
- `build_notes`

说明：
- 当前请求文件**不支持** `timeout_seconds`
- 入口脚本会固定传 `300` 秒超时给 `release.sh`

---

## 推荐交付方式

直接填写：
- `templates/release-request.json`

或者按同样结构生成请求，再交给 Java CI/CD Agent。

---

## 最小调用链

```text
你写代码
  ↓
给出明确 git_ref
  ↓
填写 release-request
  ↓
Java CI/CD Agent 执行发布
  ↓
返回结构化结果
```

---

## 你不要碰的东西

- 不要直接改 GitOps 仓库镜像标签
- 不要自己偷偷 `kubectl apply`
- 不要把“代码提交成功”当成“发布成功”
- 不要在参数缺失时靠脑补乱填

---

## 成功的标准

只有当下游 Java CI/CD Agent 确认以下都通过时，才叫成功：

- `status = success`
- `build_result = success`
- `image_push_result = success`
- `deploy_result = success`
- `rollout_result = success`
- `health_check_result = UP`

---

## 你最该记住的一句话

你负责把菜做熟，
Java CI/CD Agent 负责把菜端上桌并确认客人没被放倒。

别抢盘子，也别提前喊“上菜成功”。