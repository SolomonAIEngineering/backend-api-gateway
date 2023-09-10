#!/bin/bash

deploymentEnvType=prod
while getopts n: flag
do
    case "${flag}" in
        n) deploymentEnvType=${OPTARG};;
    esac
done

namespaceStatus=$(kubectl get ns prod -o json | jq .status.phase -r)
if [[ $namespaceStatus != "Active" ]]; then
    echo "creating namespace ($namespace) in which all services will be deployed"
    kubectl create namespace prod
fi

if [[ $deploymentEnvType == "prod" ]]; then
    echo "installing service in production namespace"
    helm upgrade --install api-gateway ./charts/api-gateway --values ./charts/api-gateway/values.production.yaml -n prod
else
    echo "installing service in staging namespace"
    helm upgrade --install api-gateway ./charts/api-gateway --values ./charts/api-gateway/values.staging.yaml -n prod
fi