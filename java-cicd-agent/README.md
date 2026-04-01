# Java CI/CD Agent

给 Java 服务用的一套发布骨架。

这里放的是发布入口、脚本、模板和配套文档。
上游代码 Agent 负责交付版本；这里负责构建、发布、检查结果。

---

## 目录

```text
java-cicd-agent/
├── README.md
├── SKILL.md
├── docs/
├── templates/
├── scripts/
└── references/
```

- `docs/`：中文说明文档
- `templates/`：请求和结果模板
- `scripts/`：执行入口和发布脚本
- `references/`：Jenkins、Harbor、Argo CD、GitOps 相关参考资料

---

## 先看什么

### 想先看整体结构
- `docs/首页摘要.md`
- `docs/架构图.md`
- `docs/调用链图.md`
- `docs/文档导航.md`

### 想直接接发布流程
- `docs/请求文件说明.md`
- `docs/脚本说明.md`
- `docs/Jenkins对接说明.md`
- `docs/一次完整演示文档.md`

### 想看字段和模板
- `docs/release-request字段字典.md`
- `docs/release-result字段字典.md`
- `templates/release-request.json`
- `templates/release-result.json`

### 想看平台侧配置
- `references/pipeline.md`
- `references/release-config-reference.md`
- `references/jenkins-install-notes.md`
- `references/argocd-install-notes.md`
- `references/gitops-layout.md`

---

## 执行入口

常用的是这三个脚本：

- `scripts/run_release_from_request.sh`
- `scripts/release.sh`
- `scripts/save_release_result.sh`

`run_release_from_request.sh` 负责读请求、校验字段、准备源码和 GitOps 仓库。

`release.sh` 负责构建、推镜像、部署、检查和输出结果。

`save_release_result.sh` 负责把结果文件存下来，方便 Jenkins、上游 Agent 或人工回看。

---

## 两种发布方式

### Direct
直接发到 Kubernetes：

- 拉源码
- Maven 构建
- 构镜像
- 推镜像
- `kubectl apply`
- rollout / health check

### GitOps
通过 GitOps 仓库和 Argo CD 发布：

- 拉源码
- Maven 构建
- 构镜像
- 推镜像
- 更新 GitOps 仓库镜像标签
- 等待 Argo CD 同步
- rollout / health check

---

## 现在有的东西

- 请求入口：`scripts/run_release_from_request.sh`
- 发布脚本：`scripts/release.sh`
- GitOps 更新：`scripts/update_gitops_image.sh`
- Argo CD 检查：`scripts/check_argocd_app.sh`
- 结果落盘：`scripts/save_release_result.sh`
- Jenkins 对接说明
- 完整演示文档
- 通知闭环说明：`references/notifications-closure.md`

---

## 适合怎么用

这套东西适合拿来：

- 给 Java 服务接一条发布链
- 给 Jenkins 一个统一入口
- 给上游 Agent 一个固定交付方式
- 跑 demo
- 联调 GitOps 发布流程
