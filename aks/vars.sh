#!/bin/bash

# general
export LOCATION="centralus"

# acr
export ACR_NAME="testwatchacrsta2"
export ACR_RG="testwatchacrstarg2"
export ACR_SECRET_NAME="acrpullsecret2"

# cluster
export CLUSTER_NAME="testwatch-cluster2"
export CLUSTER_RG="testwatchaksrg2"
export CLUSTER_K8S_VERSION="1.11.2"
export CLUSTER_NODE_COUNT=2
