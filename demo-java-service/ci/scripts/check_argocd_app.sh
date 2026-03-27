#!/usr/bin/env sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <argocd_app_name> [timeout_seconds]" >&2
  exit 1
fi

APP_NAME="$1"
TIMEOUT="${2:-300}"

if ! command -v argocd >/dev/null 2>&1; then
  echo "argocd CLI not found; skip Argo CD app check"
  exit 0
fi

argocd app wait "$APP_NAME" --health --sync --timeout "$TIMEOUT" || {
  echo "Argo CD app wait failed for: ${APP_NAME}" >&2
  argocd app get "$APP_NAME" || true
  exit 1
}

argocd app get "$APP_NAME"
