# Harbor + Kaniko 凭据

## 目标

为 Kaniko 提供一个 Docker config JSON，使其能够把镜像推送到 Harbor。

## Jenkins 凭据类型

推荐使用：
- Secret file

推荐的凭据 ID：
- `harbor-docker-config`

## 期望的文件内容

该文件应为 Docker `config.json`，其中包含 Harbor 仓库主机的认证信息。

示例结构：

```json
{
  "auths": {
    "harbor.example.com": {
      "auth": "<base64(username:password)>"
    }
  }
}
```

## Jenkins 中的使用方式

将凭据文件挂载或复制到：
- `/kaniko/.docker/config.json`

## 说明

- 优先使用 Harbor robot account 作为 CI 推送身份。
- 尽量把权限限制在目标项目级别。
- 不要把这个文件提交到 Git。
