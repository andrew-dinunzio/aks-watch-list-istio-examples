#!/bin/bash
imageTag="latest"
imageName="testwatch"
fullImage="${ACR_NAME}.azurecr.io/${imageName}:${imageTag}"

docker build -t "$fullImage" "../${imageName}/"
docker push "$fullImage"
