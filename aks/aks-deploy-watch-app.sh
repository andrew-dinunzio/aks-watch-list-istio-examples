#!/bin/bash

releaseName="testwatch"
echo "Deploying the ${releaseName} app"
pushd ../${releaseName}/helm/${releaseName}-chart
helm install --name "${releaseName}" \
    --set image.registry="${ACR_NAME}.azurecr.io" \
    --set image.tag="latest" \
    --set image.imagePullSecret="${ACR_SECRET_NAME}" \
    --set image.imagePullPolicy="Always" \
    .
if [ "$?" -ne 0 ]; then
    echo "Failed to install helm charts"
    exit 1
fi
