# 参数映射

## 最小输入集

```yaml
service_name: user-service
git_repo: git@example.com:team/user-service.git
git_ref: main
build_path: .
dockerfile_path: ./Dockerfile
image_repo: harbor.example.com/project/user-service
image_tag: git-abc1234
manifest_path: ./k8s/test
namespace: test
deployment_name: user-service
container_name: user-service
healthcheck_url: http://user-service.test.svc.cluster.local/actuator/health
rollback_on_fail: true
```

## 说明

- `manifest_path` 可以指向单个 YAML 文件，也可以指向一个目录。
- 当后续使用 `kubectl set image` 或进行容器级检查时，`container_name` 是必填的。
- 只有在完全依赖滚动发布状态和 readiness 检查做验证时，`healthcheck_url` 才可以省略。
- `image_repo` 应为完整 Harbor 仓库路径，但不包含 tag。
- `namespace` 默认值为 `test`。

## 建议派生值

- `image = <image_repo>:<image_tag>`
- `short_sha` 可由 `git rev-parse` 生成
- `build_id` 可来自 Jenkins 的 `$BUILD_NUMBER`
