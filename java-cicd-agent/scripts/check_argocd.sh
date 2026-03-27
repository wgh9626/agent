#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <argocd_app_name> [namespace]" >&2
  exit 1
fi

APP_NAME="$1"
NAMESPACE="${2:-argocd}"

if ! command -v argocd >/dev/null 2>&1; then
  echo "argocd CLI not found; skip Argo CD status check" >&2
  exit 0
fi

echo "[check_argocd] checking app ${APP_NAME}"
argocd app get "$APP_NAME" --core >/dev/null 2>&1 || argocd app get "$APP_NAME"
