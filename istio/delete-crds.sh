#!/bin/bash

# delete Istio CRDs
echo "Deleting Istio CRDs..."
kg crd -o jsonpath='{.items[*].metadata.name}' | xargs -n 1 | grep "istio" | xargs kubectl delete crd
