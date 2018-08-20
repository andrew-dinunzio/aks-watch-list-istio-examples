#!/bin/bash
echo "Deleting ACR resource group..."
az group delete -y -n ${ACR_RG}
echo "Deleting AKS resource group..."
az group delete -y -n ${CLUSTER_RG}
