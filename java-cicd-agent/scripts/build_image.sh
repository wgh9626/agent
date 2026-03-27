#!/usr/bin/env sh
set -eu

if [ $# -lt 4 ]; then
  echo "用法: $0 <repo_dir> <dockerfile_path> <image_repo> <image_tag>" >&2
  exit 2
fi

REPO_DIR="$1"
DOCKERFILE_PATH="$2"
IMAGE_REPO="$3"
IMAGE_TAG="$4"
DOCKERFILE="$REPO_DIR/$DOCKERFILE_PATH"

if [ ! -f "$DOCKERFILE" ]; then
  echo "Dockerfile 不存在: $DOCKERFILE" >&2
  exit 1
fi

cd "$REPO_DIR"
IMAGE="$IMAGE_REPO:$IMAGE_TAG"
echo "[build_image] 构建镜像: $IMAGE"
docker build -f "$DOCKERFILE" -t "$IMAGE" .
