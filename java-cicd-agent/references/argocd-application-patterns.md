# Argo CD Application 模式

## 单服务 / 单环境

推荐的第一版模式：
- 每个服务/环境使用一个独立 Application

示例：
- 应用名：`demo-java-service-test`
- 仓库路径：`apps/test`
- 命名空间：`test`

## 为什么先从简单开始

- 更容易排障
- 归属关系更清晰
- 在平台初期搭建阶段耦合更少

## 后续扩展选项

### 模式一：按环境拆分多个 Application
- `demo-java-service-test`
- `demo-java-service-staging`
- `demo-java-service-prod`

### 模式二：App-of-Apps
适合后期做平台级统一管理，但第一版发布并不需要。

## 建议

在单服务 `test` 路径尚未稳定之前，不要过早引入 app-of-apps 或多服务聚合模式。
