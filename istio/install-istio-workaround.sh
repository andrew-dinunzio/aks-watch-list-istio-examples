#!/bin/bash

export ISTIO_VERSION="0.8.0"

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
#  WORKAROUND FOR HELM INSTALL ISSUE ON AKS
# -----------------------------------------------------------------------------
IMAGE=$(helm template install/kubernetes/helm/istio --name istio --namespace istio-system | grep "image:.*coreos/hyperkube" | uniq | xargs)
DELETEKIND="tempworkaround"

declare -a arr=("${IMAGE}"
                )

index=0
for i in "${arr[@]}"
do
    echo "$i"
    ds=$(cat <<-EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: workaround-${index}-sleep
  labels:
    kind: ${DELETEKIND}
spec:
  selector:
    matchLabels:
      name: workaround-${index}-sleep
  template:
    metadata:
      labels:
        name: workaround-${index}-sleep
    spec:
      containers:
      - name: workaround-${index}-sleep
        ${i}
        command:
        - /bin/sh
        - -c
        - >
            while :; do sleep 10; done
EOF
)
    echo "$ds" | kubectl apply -f -
    # echo "$ds"
    index=$((index + 1))
done

COUNTER=0
while [[ "$COUNTER" != ${index} ]]
do
    echo "status (workaround-$COUNTER-sleep)"
    desired=$(kubectl get nodes --no-headers | wc -l)
    available=0
    while [[ "${available}" != "${desired}" ]]
    do
        available=$(kubectl get ds workaround-${COUNTER}-sleep -o jsonpath="{.status.numberAvailable}")
        if [ -z "${available}" ]; then
            available=0
        fi
        desired=$(kubectl get ds workaround-${COUNTER}-sleep -o jsonpath="{.status.desiredNumberScheduled}")
        echo "status: ${available}/$desired nodes ready"
        sleep 2
    done
    COUNTER=$((COUNTER + 1))
done

# -----------------------------------------------------------------------------
#  Do the Helm Install for Istio here
# -----------------------------------------------------------------------------
# kubectl create -f install/kubernetes/helm/helm-service-account.yaml
# helm init --service-account tiller --wait
if [ "$ISTIO_VERSION" != "0.8.0" ]; then
    kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml # necessary as of 1.0.0
fi
helm install install/kubernetes/helm/istio --name istio --namespace istio-system --timeout 1800

# -----------------------------------------------------------------------------
#  UNDO WORKAROUND FOR HELM INSTALL ISSUE ON AKS
# -----------------------------------------------------------------------------
echo "Done... deleting daemonsets..."
kubectl delete ds -l kind="$DELETEKIND"

echo "Labeling default namespace for automatic Istio sidecar injection..."
kubectl label namespace default istio-injection=enabled
echo "Deleting all pods to inject them with Istio sidecars..."
kubectl delete pods --all

echo "Applying gateway..."
kubectl apply -f ../gateway.yaml
