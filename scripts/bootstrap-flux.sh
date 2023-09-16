#!/bin/bash
export GITHUB_REPO=backend-api-gateway

# Set the kubectl context to your staging cluster and bootstrap Flux:
export GITHUB_TOKEN=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
export GITHUB_USER=SolomonAIEngineering

# check kubernetes cluster
flux check --pre


refine_repo_and_kustomize() {
   local kubernetes_ctx=$1
   local environment=$2

    flux create source git api-gateway \  
        --context=$kubernetes_ctx \                    
        --url=https://git@github.com/SolomonAIEngineering/backend-api-gateway \
        --branch=main \
        --interval=1m \
        --export > ./clusters/$environment/service-source.yaml
    
    flux create kustomization api-gateway \
        --context="$kubernetes_ctx" \                    
        --target-namespace=platform \
        --source=api-gateway \
        --path="./kustomize/overlays/$environment" \
        --prune=true \
        --wait=true \
        --interval=30m \
        --retry-interval=2m \
        --health-check-timeout=3m \
        --export > ./clusters/$environment/service-kustomization.yaml
}

# Define a function to bootstrap flux for a given environment.
bootstrap_flux() {
  local kubernetes_ctx=$1
  local environment=$2

  flux bootstrap github \
    --token-auth \
    --context=$kubernetes_ctx \
    --owner=$GITHUB_USER \
    --repository=$GITHUB_REPO \
    --branch=main \
    --path=./clusters/$environment \
    --personal

 refine_repo_and_kustomize "${kubernetes_ctx}" "${environment}"
}


# Use the function to install flux onto the staging cluster.
bootstrap_flux "do-nyc3-solomon-ai-k8s-staging" "staging"
bootstrap_flux "do-nyc3-solomon-ai-k8s-prod" "production"