# 平台访问地址约定

## 目标

让平台各组件的访问地址对运维人员和自动化逻辑都足够可预测。

## 推荐的地址模式

### Harbor
- `harbor.<base-domain>`

### Jenkins
- `jenkins.<base-domain>`

### Argo CD
- `argocd.<base-domain>`

## 示例

如果基础域名为 `ops.example.com`：
- `harbor.ops.example.com`
- `jenkins.ops.example.com`
- `argocd.ops.example.com`

## 说明

- 所有面向用户的访问地址尽量统一使用 HTTPS。
- 即使内部实现变化，外部地址命名也应尽量保持稳定。
- 在平台上线前，应明确 DNS 与 TLS 的归属和维护责任。
