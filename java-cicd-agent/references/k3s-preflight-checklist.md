# k3s 预检清单

## 主机基础

- [ ] 已评估 CPU、内存和磁盘容量
- [ ] 系统时间正确且已同步
- [ ] Harbor、Jenkins 和镜像存储所需磁盘空间充足
- [ ] 网络访问稳定

## 平台规划

- [ ] 已确定 ingress 方案
- [ ] 已确定 storage class 或持久卷策略
- [ ] 如有需要，已为 Harbor、Jenkins、Argo CD 准备 DNS / 域名规划
- [ ] 已为 Harbor 和 Web 访问端点准备 TLS 方案

## Kubernetes 就绪状态

- [ ] k3s 已安装，或具备安装条件
- [ ] 管理员操作所需 kubeconfig 可用
- [ ] 命名空间规划已明确：`cicd`、`harbor`、`argocd`、`test`

## 运维就绪状态

- [ ] 已考虑 Jenkins 和 Harbor 数据备份方案
- [ ] 管理访问方式已记录
- [ ] 初始化凭据的处理方式已规划

## 规则

在存储、ingress 和凭据处理至少做了最小规划之前，不要盲目开始安装全部组件。
