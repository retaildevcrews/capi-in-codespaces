#!/bin/bash

AZURE_TENANT_ID=$(az account show --query "tenantId" -o tsv)
export AZURE_TENANT_ID

AZURE_SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
export AZURE_SUBSCRIPTION_ID

export AZURE_CAPI_SP_NAME="capz-${GITHUB_USER}-sp"

# Create a Service Principal
AZURE_CLIENT_ID=$(
az ad sp create-for-rbac \
  --name "${AZURE_CAPI_SP_NAME}" \
  --role Contributor \
  --scopes="/subscriptions/${AZURE_SUBSCRIPTION_ID}" \
  --query "appId" -o tsv
)
export AZURE_CLIENT_ID

# Create a new secret in case this is an existing Service Principal
CLIENT_SECRET=$(
az ad sp credential reset \
  --id "$AZURE_CLIENT_ID" \
  --query "password" -o tsv
)

# Create the kubernetes secret for the Azure provider to use
kubectl create secret generic "${AZURE_CLUSTER_IDENTITY_SECRET_NAME}" \
  --from-literal=clientSecret="${CLIENT_SECRET}"

# Initialize Cluster API Provider Azure
clusterctl init --infrastructure azure:v1.7.0
