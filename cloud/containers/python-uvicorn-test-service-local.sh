#!/usr/bin/env bash
# -------------------------------------------------------------------
# Run a service locally with Uvicorn + auto reload.
# Ensures PYTHONPATH includes service dir so `common.*` under ./common works.
#
# Usage:
#   PROJECT_ID=<gcp-project> SERVICE_NAME=<service> PORT=8080 \
#     ./cloud/gcp/scripts/python-uvicorn-test-service-local.sh
# -------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="${SERVICE_NAME:-car-service}"
SERVICE_DIR="${SCRIPT_DIR}/../containers/${SERVICE_NAME}"
PORT="${PORT:-8080}"

# PROJECT_ID="${PROJECT_ID:-}"
# if [[ -n "$PROJECT_ID" ]]; then
#   export GOOGLE_CLOUD_PROJECT="$PROJECT_ID"
# fi

# Ensure local ./common exists (mirror Dockerfile expectation)
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SHARED_COMMON="$REPO_ROOT/cloud/gcp/common"
if [[ -d "$SHARED_COMMON" ]]; then
  echo "[INFO] Syncing shared common → $SERVICE_DIR/common"
  rsync -a --delete "$SHARED_COMMON/" "$SERVICE_DIR/common/"
fi

cd "$SERVICE_DIR"

# Python venv
if [[ ! -d .venv ]]; then
  python3 -m venv .venv
fi
source .venv/bin/activate
pip3 install --upgrade pip >/dev/null
pip3 install -r requirements.txt >/dev/null

# PYTHONPATH so app and ./common import cleanly
export PYTHONPATH="${PYTHONPATH:-}:$SERVICE_DIR"

echo "[INFO] Service: $SERVICE_NAME | Port: $PORT | GCP Project: ${GOOGLE_CLOUD_PROJECT:-<default>}"
uvicorn app.main:app --reload --port "$PORT"
