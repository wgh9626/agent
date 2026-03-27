#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <manifest_path> <image_repo> <image_tag>" >&2
  exit 1
fi

MANIFEST_PATH="$1"
IMAGE_REPO="$2"
IMAGE_TAG="$3"
IMAGE="${IMAGE_REPO}:${IMAGE_TAG}"

if [[ -f "$MANIFEST_PATH" ]]; then
  sed -i "s|image: .*|image: ${IMAGE}|g" "$MANIFEST_PATH"
  echo "[render_manifest] updated image in file ${MANIFEST_PATH} -> ${IMAGE}"
elif [[ -d "$MANIFEST_PATH" ]]; then
  find "$MANIFEST_PATH" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 | while IFS= read -r -d '' file; do
    sed -i "s|image: .*|image: ${IMAGE}|g" "$file"
    echo "[render_manifest] updated image in ${file} -> ${IMAGE}"
  done
else
  echo "Manifest path not found: ${MANIFEST_PATH}" >&2
  exit 1
fi
