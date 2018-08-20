#!/bin/bash

export ISTIO_VERSION="1.0.0"

ISTIO="istio-${ISTIO_VERSION}"
if [ ! -d "${ISTIO}" ]; then
  echo "Getting Istio release ${ISTIO_VERSION}..."
  # ISTIO_VERSION is already set above
  curl -L https://git.io/getLatestIstio | sh -
fi
echo "Istio release directory: $ISTIO"

pushd "istio-${ISTIO_VERSION}"
trap popd EXIT

if [ ! -f "istio.VERSION" ]; then
    echo "Error: run this from inside the Istio installation directory!"
    exit 1
fi

# -----------------------------------------------------------------------------
#  Do the Helm Install for Istio here
# -----------------------------------------------------------------------------
# kubectl create -f install/kubernetes/helm/helm-service-account.yaml
# helm init --service-account tiller --wait
if [ "$ISTIO_VERSION" != "0.8.0" ]; then
    kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml # necessary as of 1.0.0
fi
helm install install/kubernetes/helm/istio --name istio --namespace istio-system --timeout 1800

echo "Labeling default namespace for automatic Istio sidecar injection..."
kubectl label namespace default istio-injection=enabled
echo "Deleting all pods to inject them with Istio sidecars..."
kubectl delete pods --all

echo "Applying gateway..."
kubectl apply -f ../gateway.yaml
