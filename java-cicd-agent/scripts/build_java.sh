#!/usr/bin/env sh
set -eu

if [ $# -lt 2 ]; then
  echo "用法: $0 <repo_dir> <build_path> [maven_args]" >&2
  exit 2
fi

REPO_DIR="$1"
BUILD_PATH="$2"
MAVEN_ARGS="${3:-clean package -DskipTests}"
TARGET_DIR="$REPO_DIR/$BUILD_PATH"

if [ ! -d "$TARGET_DIR" ]; then
  echo "构建目录不存在: $TARGET_DIR" >&2
  exit 1
fi

if [ ! -f "$TARGET_DIR/pom.xml" ]; then
  echo "未找到 pom.xml: $TARGET_DIR/pom.xml" >&2
  exit 1
fi

cd "$TARGET_DIR"
echo "[build_java] 开始 Maven 构建: $TARGET_DIR"
# shellcheck disable=SC2086
mvn $MAVEN_ARGS
