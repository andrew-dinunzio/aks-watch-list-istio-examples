#!/bin/bash

source ./vars.sh

# Create AKS cluster first, so we can create ACR secret later
echo "Create an AKS cluster? (y/n)"
read aksAns
if [ "$aksAns" != "y" ]; then
    echo "Continue anyway? (check your current cluster config!) (y/n)"
    read ans
    if [ "$ans" != "y" ]; then
        exit 0
    fi
fi

# read in all prompts so the rest can be automatic...
echo "Create an ACR? (y/n)"
read acrAns
echo "Initialize tiller? (y/n)"
read tillerAns
echo "Deploy Istio? (y/n)"
read deployIstio
echo "Build and push testwatch to ACR? (y/n)"
read buildAndPushWatchAns
echo "Build and push testlist to ACR? (y/n)"
read buildAndPushListAns
echo "Deploy testwatch to ACR? (y/n)"
read deployWatchAns
echo "Deploy testlist to ACR? (y/n)"
read deployListAns

# Create AKS Cluster
if [ "$aksAns" = "y" ]; then
    echo "Creating AKS cluster..."
    ./create-aks.sh
    if [ "$?" -ne 0 ]; then
        exit 1
    fi
fi

# Create ACR
if [ "$acrAns" = "y" ]; then
    echo "Creating ACR..."
    ./create-acr.sh
    if [ "$?" -ne 0 ]; then
        exit 1
    fi
fi

if [ -f "secret.yaml" ]; then
    echo "Found secret. Applying..."
    kubectl apply -f "secret.yaml"
else
    # we need to have this secret so we can actually pull the images
    echo "ERROR: No secret found to connect to ACR."
    exit 1
fi

if [ "$tillerAns" = "y" ]; then
    # set up Tiller
    kubectl create serviceaccount --namespace kube-system tiller
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller --wait
fi

if [ "$deployIstio" = "y" ]; then
    # install Istio
    pushd ../istio
    ./install-istio.sh
    popd
fi

if [ "$buildAndPushWatchAns" = "y" ]; then
    ./aks-build-and-push-watch.sh
    if [ "$?" -ne 0 ]; then
        exit 1
    fi
fi

if [ "$buildAndPushListAns" = "y" ]; then
    ./aks-build-and-push-list.sh
    if [ "$?" -ne 0 ]; then
        exit 1
    fi
fi

if [ "$deployWatchAns" = "y" ]; then
    ./aks-deploy-watch-app.sh
    if [ "$?" -ne 0 ]; then
        exit 1
    fi
fi

if [ "$deployListAns" = "y" ]; then
    ./aks-deploy-list-app.sh
    if [ "$?" -ne 0 ]; then
        exit 1
    fi
fi
