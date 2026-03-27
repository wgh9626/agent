# 自定义检查清单

在某个服务真正接入这套 CI/CD 模式之前，请先确认下面这些项。

## 应用层

- [ ] Maven 构建命令可正常工作
- [ ] `pom.xml` 位于配置路径中
- [ ] 已知健康检查接口
- [ ] 已知容器端口

## 容器层

- [ ] `Dockerfile` 可成功构建
- [ ] 已选定运行时基础镜像
- [ ] JAR 拷贝路径与构建输出一致

## Kubernetes 层（部署相关）

- [ ] 命名空间为 `test`
- [ ] Deployment 名称与服务名一致，或已明确记录
- [ ] Labels 与 Selectors 保持一致
- [ ] Readiness / Liveness 探针有效
- [ ] 如有需要，后续补充资源 requests / limits

## CI 层

- [ ] `Jenkinsfile` 已提交
- [ ] `ci/release-config.yaml` 已提交
- [ ] Jenkins 中已定义 Harbor 凭据 ID
- [ ] Jenkins 中已定义 kubeconfig 凭据 ID

## 发布策略

- [ ] 已约定失败是否自动回滚
- [ ] 已约定镜像 tag 规则
- [ ] 默认只允许 `test` 命名空间
