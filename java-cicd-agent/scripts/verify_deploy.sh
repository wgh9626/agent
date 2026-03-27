#!/usr/bin/env sh
set -eu

if [ $# -lt 4 ]; then
  echo "用法: $0 <deployment_name> <namespace> <healthcheck_url> <timeout_seconds>" >&2
  exit 2
fi

DEPLOYMENT_NAME="$1"
NAMESPACE="$2"
HEALTHCHECK_URL="$3"
TIMEOUT_SECONDS="$4"

echo "[verify_deploy] 检查 rollout 状态"
kubectl -n "$NAMESPACE" rollout status deployment/"$DEPLOYMENT_NAME" --timeout="${TIMEOUT_SECONDS}s"

echo "[verify_deploy] 检查健康接口: $HEALTHCHECK_URL"
if command -v curl >/dev/null 2>&1; then
  curl --fail --silent --show-error "$HEALTHCHECK_URL" >/dev/null
else
  echo "未找到 curl，无法执行 healthcheck" >&2
  exit 1
fi

echo "[verify_deploy] 验证通过"
