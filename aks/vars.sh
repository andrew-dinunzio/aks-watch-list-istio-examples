#!/bin/bash

# general
export LOCATION="centralus"

# acr
export ACR_NAME="testwatchacrsta"
export ACR_RG="testwatchacrstarg"
export ACR_SECRET_NAME="acrpullsecret"

# cluster
export CLUSTER_NAME="testwatch-cluster"
export CLUSTER_RG="testwatchaksrg"
export CLUSTER_K8S_VERSION="1.11.1"
export CLUSTER_NODE_COUNT=2
