#!/usr/bin/env bash
set -e

echo "=========================================="
echo " Starting AWS DevOps Automated Deployment "
echo "=========================================="

# 1. Initialize Terraform
echo "[1/4] Initializing Terraform..."
terraform init -input=false

# 2. Plan and Apply Infrastructure
echo "[2/4] Applying Infrastructure..."
terraform apply -auto-approve -input=false

# 3. Extract the Application URL
APP_URL=$(terraform output -raw application_url)
PUBLIC_IP=$(terraform output -raw public_ip)

echo "[3/4] Infrastructure ready! Target URL: ${APP_URL}"
echo "Waiting for Docker & container initialization (approx 30-45s)..."

# 4. Automated Health-Check Loop
MAX_RETRIES=20
COUNT=0
READY=false

while [ $COUNT -lt $MAX_RETRIES ]; do
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "${APP_URL}" || true)
  if [ "$HTTP_STATUS" == "200" ]; then
    READY=true
    break
  fi
  echo "Application warming up... retry $((COUNT+1))/$MAX_RETRIES (HTTP status: ${HTTP_STATUS})"
  sleep 5
  COUNT=$((COUNT+1))
done

echo "=========================================="
if [ "$READY" = true ]; then
  echo " DEPLOYMENT SUCCESSFUL!"
  echo " Public URL : ${APP_URL}"
  echo " Server IP  : ${PUBLIC_IP}"
  echo "=========================================="
else
  echo " WARNING: URL did not respond 200 within timeout."
  echo " Please check ${APP_URL} directly in your browser."
  echo "=========================================="
fi
