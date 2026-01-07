#!/usr/bin/env bash
set -euo pipefail

LOCATION="${LOCATION:-australiasoutheast}"

TF_BACKEND_RG_NAME="${TF_BACKEND_RG_NAME:-rg-iac-tfstate-dev}"
TF_BACKEND_STORAGE_ACCOUNT_NAME="${TF_BACKEND_STORAGE_ACCOUNT_NAME:-stiacdevtfstate001}"
TF_BACKEND_CONTAINER_NAME="${TF_BACKEND_CONTAINER_NAME:-tfstate}"
TF_BACKEND_STATE_KEY_EXAMPLE="${TF_BACKEND_STATE_KEY_EXAMPLE:-web-sql-dev.terraform.tfstate}"

ENABLE_VERSIONING="${ENABLE_VERSIONING:-true}"
SOFT_DELETE_RETENTION_DAYS="${SOFT_DELETE_RETENTION_DAYS:-14}"

az account show 1>/dev/null

az group create --name "$TF_BACKEND_RG_NAME" --location "$LOCATION" 1>/dev/null

if ! az storage account show \
  --resource-group "$TF_BACKEND_RG_NAME" \
  --name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" 1>/dev/null 2>&1; then
  az storage account create \
    --resource-group "$TF_BACKEND_RG_NAME" \
    --name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access false \
    1>/dev/null
fi

if [[ "$ENABLE_VERSIONING" == "true" ]]; then
  az storage account blob-service-properties update \
    --account-name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" \
    --enable-versioning true 1>/dev/null || true
fi

if [[ -n "$SOFT_DELETE_RETENTION_DAYS" ]]; then
  az storage account blob-service-properties update \
    --account-name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" \
    --enable-delete-retention true \
    --delete-retention-days "$SOFT_DELETE_RETENTION_DAYS" 1>/dev/null || true
fi

az storage container create \
  --name "$TF_BACKEND_CONTAINER_NAME" \
  --account-name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" \
  --auth-mode login 1>/dev/null

cat <<EOF
Backend ready. Use these values:

resource_group_name  = "$TF_BACKEND_RG_NAME"
storage_account_name = "$TF_BACKEND_STORAGE_ACCOUNT_NAME"
container_name       = "$TF_BACKEND_CONTAINER_NAME"
key (example)        = "$TF_BACKEND_STATE_KEY_EXAMPLE"

Terraform init example:
terraform init \\
  -backend-config="resource_group_name=$TF_BACKEND_RG_NAME" \\
  -backend-config="storage_account_name=$TF_BACKEND_STORAGE_ACCOUNT_NAME" \\
  -backend-config="container_name=$TF_BACKEND_CONTAINER_NAME" \\
  -backend-config="key=$TF_BACKEND_STATE_KEY_EXAMPLE"
EOF
