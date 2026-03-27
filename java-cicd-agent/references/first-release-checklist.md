# 首次发布检查清单

## 平台层

- [ ] k3s 集群可访问
- [ ] `cicd`、`harbor`、`argocd`、`test` 命名空间已规划或已创建
- [ ] Harbor 和 Jenkins 所需持久化存储已就绪

## Harbor

- [ ] Harbor 已通过 HTTPS 可访问
- [ ] 目标项目已创建
- [ ] 已为 CI 推送创建 robot account
- [ ] Docker config JSON secret / credential 已准备好

## Jenkins

- [ ] Jenkins pipeline 可访问源码仓库
- [ ] Jenkins pipeline 可访问 GitOps 仓库
- [ ] Harbor 凭据已配置
- [ ] 必要插件已安装
- [ ] 构建 Agent 中可用 Kaniko executor

## GitOps / Argo CD

- [ ] GitOps 仓库已初始化
- [ ] `deployment.yaml` 中包含 `__IMAGE__`
- [ ] Argo CD Application 指向正确的仓库 / 路径
- [ ] Argo CD 应用可同步到 `test` 命名空间

## 应用层

- [ ] Maven 构建成功
- [ ] Dockerfile 与 JAR 输出一致
- [ ] 健康检查接口有效
- [ ] Service 与 Deployment 的 labels 匹配

## 发布演练

- [ ] 第一个镜像已由 Kaniko 构建并推送
- [ ] GitOps 清单已由 pipeline 更新
- [ ] Argo CD 同步后状态为 Healthy 和 Synced（同步成功且状态健康）
- [ ] 应用接口返回符合预期
