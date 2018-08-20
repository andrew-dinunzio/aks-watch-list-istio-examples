#!/bin/bash

curl https://raw.githubusercontent.com/kiali/kiali/master/deploy/kubernetes/kiali-configmap.yaml | \
   VERSION_LABEL=master envsubst | kubectl create -n istio-system -f -

curl https://raw.githubusercontent.com/kiali/kiali/master/deploy/kubernetes/kiali-secrets.yaml | \
   VERSION_LABEL=master envsubst | kubectl create -n istio-system -f -

curl https://raw.githubusercontent.com/kiali/kiali/master/deploy/kubernetes/kiali.yaml | \
   IMAGE_NAME=kiali/kiali \
   IMAGE_VERSION=latest \
   NAMESPACE=istio-system \
   VERSION_LABEL=master \
   VERBOSE_MODE=4 envsubst | kubectl create -n istio-system -f -

echo "Creating virtual service for Kiali..."
./create-virtual-service.sh
