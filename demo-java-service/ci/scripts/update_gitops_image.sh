#!/usr/bin/env sh
set -eu

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <manifest_file> <image_repo> <image_tag>" >&2
  exit 1
fi

MANIFEST_FILE="$1"
IMAGE_REPO="$2"
IMAGE_TAG="$3"
FULL_IMAGE="${IMAGE_REPO}:${IMAGE_TAG}"
TMP_FILE="${MANIFEST_FILE}.tmp"

if [ ! -f "$MANIFEST_FILE" ]; then
  echo "Manifest file not found: ${MANIFEST_FILE}" >&2
  exit 1
fi

cp "$MANIFEST_FILE" "$TMP_FILE"

if grep -q '__IMAGE__' "$TMP_FILE"; then
  sed -i "s|__IMAGE__|${FULL_IMAGE}|g" "$TMP_FILE"
else
  sed -i "s|image: .*|image: ${FULL_IMAGE}|g" "$TMP_FILE"
fi

if cmp -s "$MANIFEST_FILE" "$TMP_FILE"; then
  rm -f "$TMP_FILE"
  echo "No manifest change detected for: ${MANIFEST_FILE}"
  exit 0
fi

mv "$TMP_FILE" "$MANIFEST_FILE"
echo "Updated manifest image: ${MANIFEST_FILE} -> ${FULL_IMAGE}"
