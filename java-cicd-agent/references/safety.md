# 安全规则

## 部署边界

- 初始版本只允许自动部署到 `test` 命名空间。
- 对任何非 `test` 命名空间的部署，都必须要求用户明确确认。
- 不要给 Agent 分配 cluster-admin 权限。
- kubeconfig 和 service account 权限应限制在目标命名空间内。

## 镜像仓库边界

- Harbor 只授予所需项目/仓库的推送权限。
- 尽量使用 robot account 或独立的 CI 凭据。

## Jenkins 边界

- 优先触发预定义的 Jenkins pipeline/job，并通过参数驱动。
- 避免让 Agent 动态拼接任意 Jenkins Groovy 或 freestyle shell 步骤。

## 验证边界

- 在滚动发布状态检查和健康检查完成之前，绝不能报告成功。
- 必须清楚暴露失败阶段。
- 保留调试需要的日志，但不要泄露敏感信息。

## 回滚边界

- 回滚应作为显式动作，或受策略控制的失败兜底动作。
- 需要记录是否尝试回滚，以及回滚是否成功。
