#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "用法: $0 <request_json_path> [source_workspace_dir]" >&2
  exit 1
fi

REQUEST_JSON="$1"
SOURCE_WORKSPACE_DIR="${2:-/tmp/java-cicd-agent-sources}"

if [ ! -f "$REQUEST_JSON" ]; then
  echo "请求文件不存在: $REQUEST_JSON" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "未找到 python3，无法解析请求 JSON" >&2
  exit 1
fi

PARSED=$(python3 - "$REQUEST_JSON" <<'PY'
import json, sys
from pathlib import Path

p = Path(sys.argv[1])
data = json.loads(p.read_text(encoding='utf-8'))
fields = [
    'service_name','git_repo','git_ref','build_path','dockerfile_path',
    'image_repo','image_tag','deploy_mode','deployment_name','namespace',
    'healthcheck_url','rollback_on_fail','manifest_path','gitops_repo',
    'gitops_branch','gitops_manifest_path','container_name','argocd_app_name',
    'build_notes'
]
for key in fields:
    value = data.get(key, '')
    if isinstance(value, bool):
        value = 'true' if value else 'false'
    elif value is None:
        value = ''
    elif isinstance(value, list):
        value = ' | '.join(str(x) for x in value)
    else:
        value = str(value)
    print(value)
PY
)

# 固定按行读取，避免 shell 猜测
SERVICE_NAME=$(printf '%s\n' "$PARSED" | sed -n '1p')
GIT_REPO=$(printf '%s\n' "$PARSED" | sed -n '2p')
GIT_REF=$(printf '%s\n' "$PARSED" | sed -n '3p')
BUILD_PATH=$(printf '%s\n' "$PARSED" | sed -n '4p')
DOCKERFILE_PATH=$(printf '%s\n' "$PARSED" | sed -n '5p')
IMAGE_REPO=$(printf '%s\n' "$PARSED" | sed -n '6p')
IMAGE_TAG=$(printf '%s\n' "$PARSED" | sed -n '7p')
DEPLOY_MODE=$(printf '%s\n' "$PARSED" | sed -n '8p')
DEPLOYMENT_NAME=$(printf '%s\n' "$PARSED" | sed -n '9p')
NAMESPACE=$(printf '%s\n' "$PARSED" | sed -n '10p')
HEALTHCHECK_URL=$(printf '%s\n' "$PARSED" | sed -n '11p')
ROLLBACK_ON_FAIL=$(printf '%s\n' "$PARSED" | sed -n '12p')
MANIFEST_PATH=$(printf '%s\n' "$PARSED" | sed -n '13p')
GITOPS_REPO=$(printf '%s\n' "$PARSED" | sed -n '14p')
GITOPS_BRANCH=$(printf '%s\n' "$PARSED" | sed -n '15p')
GITOPS_MANIFEST_PATH=$(printf '%s\n' "$PARSED" | sed -n '16p')
CONTAINER_NAME=$(printf '%s\n' "$PARSED" | sed -n '17p')
ARGOCD_APP_NAME=$(printf '%s\n' "$PARSED" | sed -n '18p')
BUILD_NOTES=$(printf '%s\n' "$PARSED" | sed -n '19p')

require_field() {
  name="$1"
  value="$2"
  if [ -z "$value" ]; then
    echo "缺少必填字段: $name" >&2
    exit 1
  fi
}

require_field service_name "$SERVICE_NAME"
require_field git_repo "$GIT_REPO"
require_field git_ref "$GIT_REF"
require_field build_path "$BUILD_PATH"
require_field dockerfile_path "$DOCKERFILE_PATH"
require_field image_repo "$IMAGE_REPO"
require_field image_tag "$IMAGE_TAG"
require_field deploy_mode "$DEPLOY_MODE"
require_field deployment_name "$DEPLOYMENT_NAME"
require_field namespace "$NAMESPACE"
require_field healthcheck_url "$HEALTHCHECK_URL"

REPO_DIR=$("$SCRIPT_DIR/prepare_source.sh" "$GIT_REPO" "$GIT_REF" "$SOURCE_WORKSPACE_DIR" "$SERVICE_NAME")

GITOPS_REPO_DIR=""
if [ "$DEPLOY_MODE" = "gitops" ]; then
  require_field gitops_repo "$GITOPS_REPO"
  require_field gitops_manifest_path "$GITOPS_MANIFEST_PATH"
  require_field container_name "$CONTAINER_NAME"

  GITOPS_TARGET_DIR_NAME="${SERVICE_NAME}-gitops"
  GITOPS_REF="${GITOPS_BRANCH:-main}"
  GITOPS_REPO_DIR=$("$SCRIPT_DIR/prepare_source.sh" "$GITOPS_REPO" "$GITOPS_REF" "$SOURCE_WORKSPACE_DIR" "$GITOPS_TARGET_DIR_NAME")
fi

exec "$SCRIPT_DIR/release.sh" \
  "$SERVICE_NAME" \
  "$GIT_REF" \
  "$REPO_DIR" \
  "$BUILD_PATH" \
  "$DOCKERFILE_PATH" \
  "$IMAGE_REPO" \
  "$IMAGE_TAG" \
  "$DEPLOY_MODE" \
  "$DEPLOYMENT_NAME" \
  "$NAMESPACE" \
  "$HEALTHCHECK_URL" \
  300 \
  "$MANIFEST_PATH" \
  "$GITOPS_REPO_DIR" \
  "$GITOPS_MANIFEST_PATH" \
  "$CONTAINER_NAME" \
  "$ARGOCD_APP_NAME" \
  "$ROLLBACK_ON_FAIL"
