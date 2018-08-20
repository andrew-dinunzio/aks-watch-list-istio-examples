#!/bin/bash

az group create -n "${CLUSTER_RG}" -l "${LOCATION}"
if [ "$?" -ne 0 ]; then
    echo "Failed to create resource group ${CLUSTER_RG}."
    exit 1
fi
az aks create -n "${CLUSTER_NAME}" -g "${CLUSTER_RG}" --node-count "${CLUSTER_NODE_COUNT}" --enable-rbac --kubernetes-version "${CLUSTER_K8S_VERSION}"
if [ "$?" -ne 0 ]; then
    echo "Failed to create AKS cluster ${CLUSTER_NAME}."
    exit 1
fi
az aks get-credentials -n "${CLUSTER_NAME}" -g "${CLUSTER_RG}"
if [ "$?" -ne 0 ]; then
    echo "Failed to get AKS credentials."
    exit 1
fi

# give the kubernetes dashboard the right permissions
# kubectl create clusterrolebinding dashboard-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
# access the dashboard by doing:
# kubectl proxy &
# (go to http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/overview?namespace=default)
