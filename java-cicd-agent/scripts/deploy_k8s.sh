#!/usr/bin/env sh
set -eu

if [ $# -lt 3 ]; then
  echo "用法: $0 <repo_dir> <manifest_path> <namespace>" >&2
  exit 2
fi

REPO_DIR="$1"
MANIFEST_PATH="$2"
NAMESPACE="$3"
FULL_MANIFEST="$REPO_DIR/$MANIFEST_PATH"

if [ ! -e "$FULL_MANIFEST" ]; then
  echo "部署清单不存在: $FULL_MANIFEST" >&2
  exit 1
fi

echo "[deploy_k8s] 应用清单到命名空间: $NAMESPACE"
kubectl -n "$NAMESPACE" apply -f "$FULL_MANIFEST"
