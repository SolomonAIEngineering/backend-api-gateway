#!/bin/bash
export GITHUB_REPO=backend-api-gateway

# Set the kubectl context to your staging cluster and bootstrap Flux:
export GITHUB_TOKEN=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
export GITHUB_USER=SolomonAIEngineering

# check kubernetes cluster
flux check --pre

# Define a function to bootstrap flux for a given environment.
bootstrap_flux() {
  local kubernetes_ctx=$1
  local environment=$2

  flux bootstrap github \
    --context=$kubernetes_ctx \
    --owner=$GITHUB_USER \
    --repository=$GITHUB_REPO \
    --branch=main \
    --path=./clusters/$environment \
    --personal
}

# Use the function to install flux onto the staging cluster.
bootstrap_flux "do-nyc3-solomon-ai-k8s-staging" "staging"
bootstrap_flux "do-nyc3-solomon-ai-k8s-prod" "production"
