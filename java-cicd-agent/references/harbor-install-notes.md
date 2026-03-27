# Harbor 安装说明

## 目标

在 `harbor` 命名空间中运行 Harbor，作为 CI 产物的镜像仓库。

## 最低要求

- 持久化存储
- HTTPS 访问
- 初始配置所需的管理员权限

## 建议的初始配置

- 命名空间：`harbor`
- 创建一个项目，例如 `test`
- 为 CI 推送创建 robot account
- 为 Jenkins / Kaniko 准备 Docker config JSON

## 重要说明

- 强烈建议从第一天起就使用 HTTPS。
- 尽量把 CI 权限限制在项目级 robot account。
- 不要在流水线中使用个人管理员凭据。

## 首次验证

- Harbor UI / API 可访问
- 项目已创建
- robot account 可用
- Kaniko 可以成功推送测试镜像
