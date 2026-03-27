# 部署 YAML 模式

## 建议

在 Kubernetes 清单中显式保留镜像引用，例如：

```yaml
containers:
  - name: demo-service
    image: harbor.example.com/test/demo-service:git-placeholder
```

然后在 CI 中于 `kubectl apply` 前更新镜像标签。

## 更安全的替代方案

不要粗暴地对整个目录做 `sed` 全局替换，而是在清单中使用占位符：

```yaml
image: __IMAGE__
```

然后在 CI 中只替换这个占位符：

```bash
sed -i "s|__IMAGE__|${IMAGE_REPO}:${IMAGE_TAG}|g" deployment.yaml
```

相比于在一个目录里替换所有 `image:` 行，这样更安全，尤其适合存在多个 workload 的情况。

## 推荐目录结构

```text
k8s/
  test/
    deployment.yaml
    service.yaml
    ingress.yaml
```

对于多服务仓库，建议将不同服务的清单明确分开，避免交叉修改。
