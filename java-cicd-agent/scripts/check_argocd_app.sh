#!/usr/bin/env sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "用法: $0 <argocd_app_name> [timeout_seconds]" >&2
  exit 1
fi

APP_NAME="$1"
TIMEOUT="${2:-300}"

if ! command -v argocd >/dev/null 2>&1; then
  echo "未找到 argocd CLI，跳过 Argo CD 检查"
  exit 0
fi

echo "[check_argocd_app] 等待应用同步并健康: $APP_NAME"
argocd app wait "$APP_NAME" --health --sync --timeout "$TIMEOUT" || {
  echo "Argo CD 应用等待失败: $APP_NAME" >&2
  argocd app get "$APP_NAME" || true
  exit 1
}

echo "[check_argocd_app] 当前应用状态"
argocd app get "$APP_NAME"
