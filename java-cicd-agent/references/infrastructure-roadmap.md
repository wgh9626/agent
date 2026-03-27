# 基础设施路线图

## 当前现实

目标技术栈在概念上包括：
- Maven
- Docker
- Harbor
- Jenkins
- Argo CD
- Kubernetes（`kubectl apply`）

但目前 Harbor、Jenkins 和 Argo CD 可能还没有真正部署好。

## 建议的建设顺序

### 阶段一：本地 / 测试 CI 骨架
- 定稿仓库结构
- 定稿 Jenkinsfile 模板
- 定稿 `test` 环境 Kubernetes 清单
- 在可信主机上手动执行脚本链路

### 阶段二：Jenkins
- 部署 Jenkins
- 添加 Git、Harbor、kubeconfig 等凭据
- 将手工脚本流程迁移为 Jenkins pipeline

### 阶段三：Harbor
- 部署 Harbor
- 制定项目 / 仓库命名规则
- 创建用于 CI 推送的 robot account
- 镜像保留与漏洞扫描可后续补上

### 阶段四：Argo CD
- 部署 Argo CD
- 决定初期是只用于可见性检查，还是直接切换到 GitOps 发布
- 在那之前，继续使用 `kubectl apply` 作为部署路径

## 实用建议

不要因为基础设施尚未就绪，就卡住 skill 设计。
应先把仓库模板、发布契约和脚本骨架设计好，之后再把真实 endpoint 填入配置。
