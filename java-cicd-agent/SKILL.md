---
name: java-cicd-agent
description: 通过受控的 CI/CD 流程为 Java 服务执行构建与部署，覆盖 Maven、Docker、Harbor、Jenkins、kubectl apply、Argo CD 状态检查以及 Kubernetes 验证。适用于创建或运行面向 Java 服务的运维/发布 Agent、打包 JAR、构建镜像、推送 Harbor、部署到 Kubernetes test 命名空间、检查滚动发布状态与健康检查，或设计安全的发布与回滚流程。
---

# Java CI/CD Agent

使用这个 skill 来设计或执行一套受控、可审计的 Java 服务发布流程。

## 核心操作规则

- 把 Agent 当成编排器，而不是随手敲命令的自由 shell 操作员。
- 优先使用固定脚本和 Jenkins Job，而不是临时拼接终端命令。
- 默认部署命名空间为 `test`。
- 对 `test` 以外环境的任何操作，都需要明确的人类确认。
- 每次发布都要记录服务名、git ref、镜像标签、命名空间和最终结果。
- 只有在构建、推镜像、滚动发布状态检查和健康检查全部通过后，才算发布成功。

## 工作流程

1. 收集发布输入参数。
2. 校验必填参数是否完整。
3. 使用 Maven 构建 Java 制品。
4. 使用 Docker 构建容器镜像。
5. 将镜像推送到 Harbor。
6. 更新部署清单或渲染后的 YAML 中的镜像标签。
7. 使用 `kubectl apply` 部署到 `test` 命名空间。
8. 验证 rollout、Pod Ready 状态和健康检查接口。
9. 返回成功或失败结果，并给出下一步建议。
10. 只有在调用方要求或策略允许自动回滚时，才执行回滚。

## 必填输入

在执行前应收集以下参数：

- `service_name`
- `git_repo`
- `git_ref`（分支、标签或提交哈希）
- `build_path`（仓库根目录或模块路径）
- `dockerfile_path`
- `image_repo`（Harbor 仓库路径）
- `image_tag`
- `manifest_path` 或部署 YAML 路径
- `deployment_name`
- `namespace`（默认 `test`）
- `healthcheck_url` 或健康检查路径
- `container_name`（当 Deployment 中容器名与服务名不一致时）
- `rollback_on_fail`（`true` 或 `false`）

如果关键参数缺失，应停止并向调用方确认，而不是自行猜测。

## 脚本入口

优先使用以下内置脚本作为执行入口：

- `scripts/build_java.sh`
- `scripts/build_image.sh`
- `scripts/push_image.sh`
- `scripts/deploy_k8s.sh`
- `scripts/verify_deploy.sh`
- `scripts/rollback.sh`
- `scripts/render_manifest.sh`
- `scripts/check_argocd.sh`
- `scripts/update_gitops_image.sh`
- `scripts/check_argocd_app.sh`
- `scripts/release.sh`

在调整流程前，优先阅读：

- `references/pipeline.md`
- `references/parameters.md`
- `references/deploy-yaml-pattern.md`
- `references/safety.md`
- `references/jenkinsfile-template.groovy`
- `references/jenkins-kaniko-template.groovy`
- `references/kaniko-argocd-architecture.md`
- `references/gitops-layout.md`
- `references/argocd-application-template.yaml`
- `references/repo-layout.md`
- `references/infrastructure-roadmap.md`
- `references/k3s-minimal-platform.md`
- `references/jenkins-k8s-kaniko-agent.md`

真实服务仓库可从 `references/project-templates/` 作为起点。

## 成功标准

只有以下检查全部通过，才可认定一次发布成功：

- Maven 构建成功退出
- Docker 镜像构建成功退出
- Harbor 推送成功退出
- `kubectl apply` 成功退出
- `kubectl rollout status` 在超时前成功
- 目标 Pod 进入 Ready
- 健康检查返回成功

## 失败处理

当发布失败时：

1. 明确指出失败阶段。
2. 捕获关键 stderr/stdout 片段。
3. 给出下一步修复建议。
4. 如果已部分发布且 `rollback_on_fail=true`，则使用 `scripts/rollback.sh`。
5. 如果健康检查失败，绝不能宣称发布成功。

## 输出格式

发布结果应按以下结构返回：

```text
发布结果
- 服务：...
- Git 版本：...
- 镜像：harbor/...:tag
- 命名空间：test
- 执行阶段：build | push | deploy | verify
- 状态：success | failed | rolled back
- Rollout：...
- 健康检查：...
- 下一步：...
```

## 说明

- 在用户没有明确加入之前，不要默认把生产和 staging 逻辑放进主路径。
- Argo CD 属于环境上下文的一部分；默认主要用于同步状态和可视化检查，除非用户明确要求走 GitOps 控制发布。
- 当前初始版本的部署动作是 `kubectl apply`，不是 Helm。
