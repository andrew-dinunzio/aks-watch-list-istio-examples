#!/bin/bash

trap popd EXIT

# start minikube
pushd ~
minikube start --memory 4096 --kubernetes-version=v1.11.1 --vm-driver="hyperv" --hyperv-virtual-switch="Wi-Fi"
if [ "$?" -ne 0 ]; then
    echo "Failed to start minikube"
    exit 1
fi
popd

# set up tiller
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller --wait

# build image onto minikube
./mini-build.sh

# install Istio
pushd ../istio
./install-istio-workaround.sh
popd

# TODO: WIP (after adding additional testlist app)
