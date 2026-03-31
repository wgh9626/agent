#!/usr/bin/env sh
set -eu

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
  echo "Usage: $0 <namespace> <deployment_name> <expected_image> [label_selector]" >&2
  exit 1
fi

NAMESPACE="$1"
DEPLOYMENT_NAME="$2"
EXPECTED_IMAGE="$3"
LABEL_SELECTOR="${4:-app=${DEPLOYMENT_NAME}}"
TIMEOUT="${TIMEOUT_SECONDS:-300}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found; cannot verify Kubernetes deployment" >&2
  exit 1
fi

echo "[verify] rollout status: deployment/${DEPLOYMENT_NAME} namespace=${NAMESPACE} timeout=${TIMEOUT}s"
kubectl -n "$NAMESPACE" rollout status "deployment/${DEPLOYMENT_NAME}" --timeout="${TIMEOUT}s"

echo "[verify] pods by selector: ${LABEL_SELECTOR}"
kubectl -n "$NAMESPACE" get pods -l "$LABEL_SELECTOR" -o wide

LIVE_IMAGE="$(kubectl -n "$NAMESPACE" get deploy "$DEPLOYMENT_NAME" -o jsonpath='{.spec.template.spec.containers[0].image}')"
echo "[verify] live image: ${LIVE_IMAGE}"
echo "[verify] expected image: ${EXPECTED_IMAGE}"

if [ "$LIVE_IMAGE" != "$EXPECTED_IMAGE" ]; then
  echo "Live deployment image mismatch" >&2
  exit 1
fi

echo "[verify] deployment image matches expected image"
