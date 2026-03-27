#!/usr/bin/env sh
set -eu

if [ $# -lt 3 ] || [ $# -gt 4 ]; then
  echo "用法: $0 <git_repo> <git_ref> <workspace_dir> [target_dir_name]" >&2
  exit 1
fi

GIT_REPO="$1"
GIT_REF="$2"
WORKSPACE_DIR="$3"
TARGET_DIR_NAME="${4:-}"

if ! command -v git >/dev/null 2>&1; then
  echo "未找到 git 命令" >&2
  exit 1
fi

mkdir -p "$WORKSPACE_DIR"

if [ -z "$TARGET_DIR_NAME" ]; then
  TARGET_DIR_NAME=$(basename "$GIT_REPO")
  TARGET_DIR_NAME=${TARGET_DIR_NAME%.git}
fi

TARGET_DIR="$WORKSPACE_DIR/$TARGET_DIR_NAME"

if [ ! -d "$TARGET_DIR/.git" ]; then
  echo "[prepare_source] 克隆仓库到: $TARGET_DIR" >&2
  git clone "$GIT_REPO" "$TARGET_DIR" >&2
else
  echo "[prepare_source] 复用已有仓库: $TARGET_DIR" >&2
fi

cd "$TARGET_DIR"
echo "[prepare_source] 拉取远端更新" >&2
git fetch --all --tags >&2

echo "[prepare_source] 检出版本: $GIT_REF" >&2
git checkout "$GIT_REF" >&2

# 若是分支，尽量同步远端
if git rev-parse --verify "origin/$GIT_REF" >/dev/null 2>&1; then
  git reset --hard "origin/$GIT_REF" >&2
fi

printf '%s\n' "$TARGET_DIR"
