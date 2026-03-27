# Jenkins 凭据检查清单

## 必需凭据

### 源码仓库凭据
- [ ] 已在 Jenkins 中创建
- [ ] 可以克隆服务源码仓库
- [ ] 权限范围符合预期的仓库访问模型

### GitOps 仓库凭据
- [ ] 已在 Jenkins 中创建
- [ ] 可以克隆并推送 GitOps 仓库
- [ ] 被 `release-config.yaml` 中配置的 pipeline credential ID 正确引用

### Harbor Docker Config 凭据
- [ ] 已在 Jenkins 中以 secret file 形式创建
- [ ] credential ID 与 `harbor_config_json_credentials_id` 一致
- [ ] 文件内容是合法的 Docker `config.json`
- [ ] 可用于 Kaniko 推送镜像

### 可选的 Argo CD Token
- [ ] 仅在 CLI/API 检查确实需要时才创建
- [ ] 权限范围最小化

## 规则

当真实 Jenkins 凭据创建完成后，不要在项目配置里继续保留占位用的 credential ID。
