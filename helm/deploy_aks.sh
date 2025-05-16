#!/bin/bash
set -euo pipefail

echo "Logging into Azure..."
az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" --tenant "$AZURE_TENANT_ID"
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

echo "Fetching AKS credentials..."
az aks get-credentials --resource-group "$AZURE_RESOURCE_GROUP" --name "$AKS_CLUSTER_NAME"
echo "Verifying connection to AKS..."
kubelogin convert-kubeconfig -l azurecli

# Clone Helm repo if needed
if [ ! -d helm-charts ]; then
  git clone "$HELM_REPO_URL" helm-charts
fi
cd helm-charts

# Deploy only backend using Helmfile selector
helmfile -e "$DEPLOYMENT_ENV" -f helmfile.yaml --selector component=backend sync

az logout
rm -f ~/.kube/config