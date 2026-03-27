# Pipeline 参考

## 目标技术栈

- 构建：Maven
- 镜像构建：Docker
- 镜像仓库：Harbor
- CI 编排器：Jenkins
- 部署命令：`kubectl apply`
- 集群平台：Kubernetes
- 默认命名空间：`test`
- 可观测性 / 发布可见性：按需使用 Argo CD 状态检查

## 推荐流程

1. Jenkins 检出指定的 git ref。
2. Jenkins 执行 Maven package/build。
3. Docker 构建带有可追踪版本号的镜像。
4. Docker 将镜像推送到 Harbor。
5. 更新或渲染部署 YAML，使其引用目标镜像标签。
6. 使用 `kubectl apply -f` 将清单应用到 `test` 命名空间。
7. 使用 `kubectl rollout status` 检查 Deployment 的滚动发布状态。
8. 检查 Pod Ready 和应用健康检查接口。
9. 将结果返回给调用方。

## 镜像标签建议

推荐使用唯一且可追踪的标签：

- `git-<short_sha>`
- `build-<jenkins_build_number>`
- `release-<version>`

不要只依赖 `latest`。

## 建议的 Jenkins 阶段

- Checkout
- Build Jar
- Build Image
- Push Image
- Deploy to Test
- Verify Rollout
- Verify Health
- Notify Result

## 建议的 kubectl 检查

```bash
kubectl -n test apply -f <manifest_path>
kubectl -n test rollout status deployment/<deployment_name> --timeout=180s
kubectl -n test get pods -l app=<service_name>
```

## 建议的健康检查

常见 Java 服务健康检查接口：

- `/actuator/health`
- `/health`
- `/healthz`

如果服务只能在集群内部访问，可使用：

```bash
kubectl -n test port-forward deploy/<deployment_name> 18080:<container_port>
curl -f http://127.0.0.1:18080/actuator/health
```

或者在可用时，直接使用集群内部 Service DNS 地址。
