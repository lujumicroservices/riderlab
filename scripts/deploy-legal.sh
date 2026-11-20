#!/bin/sh
# Deploy the legal static pages to Azure $web (macOS/Linux twin of deploy-legal.ps1).
# Requires: az login
# URL: https://riderlab.rawthrottle.com.mx/legal/...
set -eu
cd "$(dirname "$0")/.."

KEY=$(az storage account keys list --account-name riderlabdeck --resource-group rg-nkmoto --query "[0].value" -o tsv)
[ -n "$KEY" ] || { echo "Could not read storage account key" >&2; exit 1; }

for f in delete-account privacy terms; do
  az storage blob upload \
    --account-name riderlabdeck \
    --account-key "$KEY" \
    --container-name '$web' \
    --name "legal/$f.html" \
    --file "docs/legal/$f.html" \
    --content-type 'text/html; charset=utf-8' \
    --overwrite true -o none
  echo "Uploaded legal/$f.html"
done
