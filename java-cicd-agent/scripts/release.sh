#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

print_json_result() {
  status="$1"
  stage_reached="$2"
  build_result="$3"
  image_push_result="$4"
  deploy_result="$5"
  rollout_result="$6"
  health_check_result="$7"
  rollback_performed="$8"
  next_action="$9"
  error_summary="${10:-}"
  error_excerpt="${11:-}"

  printf '{\n'
  printf '  "service_name": "%s",\n' "$(json_escape "$SERVICE_NAME")"
  printf '  "git_ref": "%s",\n' "$(json_escape "$GIT_REF")"
  printf '  "image": "%s",\n' "$(json_escape "$IMAGE_REPO:$IMAGE_TAG")"
  printf '  "deploy_mode": "%s",\n' "$(json_escape "$DEPLOY_MODE")"
  printf '  "namespace": "%s",\n' "$(json_escape "$NAMESPACE")"
  printf '  "stage_reached": "%s",\n' "$(json_escape "$stage_reached")"
  printf '  "status": "%s",\n' "$(json_escape "$status")"
  printf '  "build_result": "%s",\n' "$(json_escape "$build_result")"
  printf '  "image_push_result": "%s",\n' "$(json_escape "$image_push_result")"
  printf '  "deploy_result": "%s",\n' "$(json_escape "$deploy_result")"
  printf '  "rollout_result": "%s",\n' "$(json_escape "$rollout_result")"
  printf '  "health_check_result": "%s",\n' "$(json_escape "$health_check_result")"
  printf '  "rollback_performed": %s,\n' "$rollback_performed"
  if [ -n "$ARGOCD_APP_NAME" ]; then
    printf '  "argocd_app": "%s",\n' "$(json_escape "$ARGOCD_APP_NAME")"
  fi
  printf '  "next_action": "%s"' "$(json_escape "$next_action")"
  if [ -n "$error_summary" ]; then
    printf ',\n  "error_summary": "%s"' "$(json_escape "$error_summary")"
  fi
  if [ -n "$error_excerpt" ]; then
    printf ',\n  "error_excerpt": "%s"' "$(json_escape "$error_excerpt")"
  fi
  printf '\n}\n'
}

run_step() {
  step_name="$1"
  shift
  stage_reached="$step_name"
  log_file=$(mktemp)
  if "$@" >"$log_file" 2>&1; then
    cat "$log_file"
    LAST_LOG="$(tail -n 20 "$log_file" || true)"
    rm -f "$log_file"
    return 0
  else
    cat "$log_file" >&2 || true
    LAST_LOG="$(tail -n 20 "$log_file" || true)"
    rm -f "$log_file"
    return 1
  fi
}

if [ $# -lt 12 ]; then
  cat >&2 <<'EOF'
用法:
  $0 <service_name> <git_ref> <repo_dir> <build_path> <dockerfile_path> <image_repo> <image_tag> <deploy_mode> <deployment_name> <namespace> <healthcheck_url> <timeout_seconds> [manifest_path] [gitops_repo_dir] [gitops_manifest_path] [container_name] [argocd_app_name] [rollback_on_fail]
EOF
  exit 2
fi

SERVICE_NAME="$1"
GIT_REF="$2"
REPO_DIR="$3"
BUILD_PATH="$4"
DOCKERFILE_PATH="$5"
IMAGE_REPO="$6"
IMAGE_TAG="$7"
DEPLOY_MODE="$8"
DEPLOYMENT_NAME="$9"
NAMESPACE="${10}"
HEALTHCHECK_URL="${11}"
TIMEOUT_SECONDS="${12}"
MANIFEST_PATH="${13:-}"
GITOPS_REPO_DIR="${14:-}"
GITOPS_MANIFEST_PATH="${15:-}"
CONTAINER_NAME="${16:-}"
ARGOCD_APP_NAME="${17:-}"
ROLLBACK_ON_FAIL="${18:-false}"

stage_reached="init"
LAST_LOG=""
BUILD_RESULT="not_started"
IMAGE_PUSH_RESULT="not_started"
DEPLOY_RESULT="not_started"
ROLLOUT_RESULT="not_started"
HEALTH_RESULT="NOT_CHECKED"
ROLLBACK_PERFORMED="false"

if [ "$NAMESPACE" != "test" ]; then
  echo "当前脚本默认只建议用于 test 环境，收到 namespace=$NAMESPACE" >&2
fi

if ! run_step build "$SCRIPT_DIR/build_java.sh" "$REPO_DIR" "$BUILD_PATH"; then
  BUILD_RESULT="failed"
  print_json_result failed "$stage_reached" "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" "$DEPLOY_RESULT" "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "修复 Maven 构建问题后重新发布" "Maven 构建失败" "$LAST_LOG"
  exit 1
fi
BUILD_RESULT="success"

if ! run_step image "$SCRIPT_DIR/build_image.sh" "$REPO_DIR" "$DOCKERFILE_PATH" "$IMAGE_REPO" "$IMAGE_TAG"; then
  print_json_result failed "$stage_reached" "$BUILD_RESULT" failed "$DEPLOY_RESULT" "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "检查 Dockerfile 与构建上下文" "镜像构建失败" "$LAST_LOG"
  exit 1
fi

if ! run_step push "$SCRIPT_DIR/push_image.sh" "$IMAGE_REPO" "$IMAGE_TAG"; then
  IMAGE_PUSH_RESULT="failed"
  print_json_result failed "$stage_reached" "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" "$DEPLOY_RESULT" "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "检查 Harbor 凭据、仓库与网络后重试" "镜像推送失败" "$LAST_LOG"
  exit 1
fi
IMAGE_PUSH_RESULT="success"

case "$DEPLOY_MODE" in
  direct)
    if [ -z "$MANIFEST_PATH" ]; then
      print_json_result failed deploy "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" failed "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "补充 manifest_path 参数" "缺少部署清单路径" "direct 模式必须提供 manifest_path"
      exit 1
    fi
    if ! run_step deploy "$SCRIPT_DIR/deploy_k8s.sh" "$REPO_DIR" "$MANIFEST_PATH" "$NAMESPACE"; then
      DEPLOY_RESULT="failed"
      if [ "$ROLLBACK_ON_FAIL" = "true" ]; then
        if "$SCRIPT_DIR/rollback.sh" "$NAMESPACE" "$DEPLOYMENT_NAME"; then
          ROLLBACK_PERFORMED="true"
          print_json_result rolled_back "$stage_reached" "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" "$DEPLOY_RESULT" "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "检查部署清单和变更内容" "部署失败，已回滚" "$LAST_LOG"
          exit 1
        fi
      fi
      print_json_result failed "$stage_reached" "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" "$DEPLOY_RESULT" "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "检查部署清单和集群状态" "部署失败" "$LAST_LOG"
      exit 1
    fi
    DEPLOY_RESULT="success"
    ;;
  gitops)
    if [ -z "$GITOPS_REPO_DIR" ] || [ -z "$GITOPS_MANIFEST_PATH" ] || [ -z "$CONTAINER_NAME" ]; then
      print_json_result failed deploy "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" failed "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "补充 gitops_repo_dir、gitops_manifest_path、container_name" "GitOps 参数不完整" "gitops 模式缺少必要参数"
      exit 1
    fi
    if ! run_step deploy "$SCRIPT_DIR/update_gitops_image.sh" "$GITOPS_REPO_DIR" "$GITOPS_MANIFEST_PATH" "$CONTAINER_NAME" "$IMAGE_REPO" "$IMAGE_TAG" "chore: 发布 $DEPLOYMENT_NAME 镜像 $IMAGE_REPO:$IMAGE_TAG"; then
      DEPLOY_RESULT="failed"
      print_json_result failed "$stage_reached" "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" "$DEPLOY_RESULT" "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "检查 GitOps 仓库权限、清单路径与提交权限" "更新 GitOps 清单失败" "$LAST_LOG"
      exit 1
    fi
    DEPLOY_RESULT="success"
    if [ -n "$ARGOCD_APP_NAME" ]; then
      if ! run_step deploy "$SCRIPT_DIR/check_argocd_app.sh" "$ARGOCD_APP_NAME" "$TIMEOUT_SECONDS"; then
        DEPLOY_RESULT="failed"
        print_json_result failed "$stage_reached" "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" "$DEPLOY_RESULT" "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "检查 Argo CD 应用状态与同步错误" "Argo CD 应用同步失败" "$LAST_LOG"
        exit 1
      fi
    fi
    ;;
  *)
    print_json_result failed deploy "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" failed "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "将 deploy_mode 设置为 direct 或 gitops" "不支持的部署模式" "$DEPLOY_MODE"
    exit 1
    ;;
esac

if ! run_step verify "$SCRIPT_DIR/verify_deploy.sh" "$DEPLOYMENT_NAME" "$NAMESPACE" "$HEALTHCHECK_URL" "$TIMEOUT_SECONDS"; then
  ROLLOUT_RESULT="failed"
  HEALTH_RESULT="DOWN"
  if [ "$ROLLBACK_ON_FAIL" = "true" ]; then
    if "$SCRIPT_DIR/rollback.sh" "$NAMESPACE" "$DEPLOYMENT_NAME"; then
      ROLLBACK_PERFORMED="true"
      print_json_result rolled_back "$stage_reached" "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" "$DEPLOY_RESULT" "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "检查应用启动日志与健康检查依赖" "验证失败，已回滚" "$LAST_LOG"
      exit 1
    fi
  fi
  print_json_result failed "$stage_reached" "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" "$DEPLOY_RESULT" "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "检查 rollout、Pod 日志和 healthcheck" "部署验证失败" "$LAST_LOG"
  exit 1
fi

ROLLOUT_RESULT="success"
HEALTH_RESULT="UP"
print_json_result success "$stage_reached" "$BUILD_RESULT" "$IMAGE_PUSH_RESULT" "$DEPLOY_RESULT" "$ROLLOUT_RESULT" "$HEALTH_RESULT" "$ROLLBACK_PERFORMED" "none"
