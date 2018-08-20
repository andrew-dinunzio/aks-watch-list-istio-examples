#!/bin/bash

echo "Creating resource group ${ACR_RG}..."
az group create -n "${ACR_RG}" -l "${LOCATION}"
if [ "$?" -ne 0 ]; then
    echo "Failed to create resource group."
    exit 1
fi
echo "Creating ACR ${ACR_NAME} in resource group ${ACR_RG}..."
az acr create -n "${ACR_NAME}" -g "${ACR_RG}" --sku Basic
if [ "$?" -ne 0 ]; then
    echo "Failed to create ACR."
    exit 1
fi

az acr update -n "${ACR_NAME}" --admin-enabled true
# log in so we can push to the ACR later
az acr login --name "${ACR_NAME}"
# create secret that we can send to kubernetes later
creds=$(az acr credential show -n ${ACR_NAME} --query "passwords[0].value" | tail -c +2 | head -c -3)
kubectl create --dry-run=true secret docker-registry "${ACR_SECRET_NAME}" --docker-server "${ACR_NAME}.azurecr.io" --docker-email "test@somenonexistenturl.com" --docker-username "${ACR_NAME}" --docker-password "${creds}" -o yaml > secret.yaml
