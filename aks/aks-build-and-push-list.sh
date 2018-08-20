#!/bin/bash
imageTag="latest"
imageName="testlist"
fullImage="${ACR_NAME}.azurecr.io/${imageName}:${imageTag}"

docker build -t "$fullImage" "../${imageName}/"
docker push "$fullImage"
