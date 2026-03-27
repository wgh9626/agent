#!/usr/bin/env sh
set -eu

if [ $# -lt 6 ]; then
  echo "用法: $0 <gitops_repo_dir> <manifest_path> <container_name> <image_repo> <image_tag> <commit_message>" >&2
  exit 2
fi

GITOPS_REPO_DIR="$1"
MANIFEST_PATH="$2"
CONTAINER_NAME="$3"
IMAGE_REPO="$4"
IMAGE_TAG="$5"
COMMIT_MESSAGE="$6"
FULL_MANIFEST="$GITOPS_REPO_DIR/$MANIFEST_PATH"
IMAGE="$IMAGE_REPO:$IMAGE_TAG"

if [ ! -f "$FULL_MANIFEST" ]; then
  echo "GitOps 清单不存在: $FULL_MANIFEST" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "需要 python3 来安全更新 YAML" >&2
  exit 1
fi

python3 - "$FULL_MANIFEST" "$CONTAINER_NAME" "$IMAGE" <<'PY'
import sys
from pathlib import Path

manifest = Path(sys.argv[1])
container_name = sys.argv[2]
image = sys.argv[3]
text = manifest.read_text(encoding='utf-8')
lines = text.splitlines()
changed = False
in_containers = False
current_name = None
for i, line in enumerate(lines):
    stripped = line.strip()
    if stripped.startswith('containers:'):
        in_containers = True
        current_name = None
        continue
    if in_containers and stripped.startswith('- name:'):
        current_name = stripped.split(':', 1)[1].strip()
        continue
    if in_containers and stripped.startswith('image:') and current_name == container_name:
        prefix = line.split('image:', 1)[0]
        lines[i] = f"{prefix}image: {image}"
        changed = True
        break

if not changed:
    raise SystemExit(f"未找到容器 {container_name} 对应的 image 字段")

manifest.write_text('\n'.join(lines) + '\n', encoding='utf-8')
PY

cd "$GITOPS_REPO_DIR"
git add "$MANIFEST_PATH"
git commit -m "$COMMIT_MESSAGE"
git push
