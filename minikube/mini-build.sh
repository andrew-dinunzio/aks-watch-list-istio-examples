#!/bin/bash
eval $(minikube docker-env --shell=bash)
docker build -t testwatch:latest ..

# TODO: WIP (after adding additional testlist app)
