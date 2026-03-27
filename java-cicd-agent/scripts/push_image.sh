#!/usr/bin/env sh
set -eu

if [ $# -lt 2 ]; then
  echo "用法: $0 <image_repo> <image_tag>" >&2
  exit 2
fi

IMAGE_REPO="$1"
IMAGE_TAG="$2"
IMAGE="$IMAGE_REPO:$IMAGE_TAG"

echo "[push_image] 推送镜像: $IMAGE"
docker push "$IMAGE"
