#!/usr/bin/env sh
set -eu

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
  echo "用法: $0 <namespace> <deployment_name> [to_revision]" >&2
  exit 1
fi

NAMESPACE="$1"
DEPLOYMENT_NAME="$2"
TO_REVISION="${3:-}"

if [ -n "$TO_REVISION" ]; then
  echo "[rollback] 回滚 deployment/${DEPLOYMENT_NAME} 到 revision ${TO_REVISION}"
  kubectl -n "$NAMESPACE" rollout undo "deployment/${DEPLOYMENT_NAME}" --to-revision="$TO_REVISION"
else
  echo "[rollback] 回滚 deployment/${DEPLOYMENT_NAME} 到上一个版本"
  kubectl -n "$NAMESPACE" rollout undo "deployment/${DEPLOYMENT_NAME}"
fi

echo "[rollback] 等待回滚完成"
kubectl -n "$NAMESPACE" rollout status "deployment/${DEPLOYMENT_NAME}" --timeout=180s

echo "[rollback] 回滚完成"
