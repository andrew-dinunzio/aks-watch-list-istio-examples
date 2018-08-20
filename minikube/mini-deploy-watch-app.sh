#!/bin/bash

echo "Deploying the watch app"
pushd ../helm/watch-examples-charts
helm install --name testwatch .
if [ "$?" -ne 0 ]; then
    echo "Failed to install helm charts"
    exit 1
fi

# TODO: WIP (after adding additional testlist app)
