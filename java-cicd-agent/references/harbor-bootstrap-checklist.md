# Harbor 初始化检查清单

## 基础准备

- [ ] `harbor` 命名空间已创建或已纳入规划
- [ ] 持久化存储已准备好
- [ ] HTTPS 访问入口已规划且可达
- [ ] 具备管理员初始化访问能力

## 初始对象

- [ ] 已创建 `test` 项目
- [ ] 已为 CI 推送创建 robot account
- [ ] 如有需要，后续再检查镜像保留策略

## CI 集成

- [ ] 已为 robot account 生成 Docker config JSON
- [ ] 已在 Jenkins 中创建 secret file 凭据 `harbor-docker-config`
- [ ] Kaniko 可以认证并成功推送测试镜像

## 验证项

- [ ] Harbor UI 可访问
- [ ] Harbor API / 登录可用
- [ ] 测试镜像推送成功
- [ ] 推送后的镜像可在目标项目中看到
