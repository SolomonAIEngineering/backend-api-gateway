#!/bin/bash
export GITHUB_REPO=backend-api-gateway

# Set the kubectl context to your staging cluster and bootstrap Flux:
export GITHUB_TOKEN=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
export GITHUB_USER=SolomonAIEngineering
GITHUB_URL=https://git@github.com/SolomonAIEngineering/backend-api-gateway
GITHUB_SECRET_NAME=backend-api-gateway-secret
NAMESPACE=platform
# check kubernetes cluster
flux check --pre

echo "INFO - Creating Flux service secret"
flux create secret git $GITHUB_SECRET_NAME --password=$GITHUB_TOKEN --username=$GITHUB_USER --url=$GITHUB_URL

refine_repo_and_kustomize() {
   local kubernetes_ctx=$1
   local environment=$2

    # This command will create the GitRepository resource in Kubernetes to represent our source. 
    flux create source git api-gateway --url=$GITHUB_URL \
        --branch=main \
        --interval=1m \
        --secret-ref=$GITHUB_SECRET_NAME \
        –-username=$GITHUB_USER \
        --password=$GITHUB_TOKEN \
        --export > ./clusters/$environment/service-source.yaml
    
    # This will create a Kustomization resource that will immediately try to pull and create our resource.
    flux create kustomization api-gateway \
        --source=GitRepository/api-gateway \
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
    --path=./clusters/$environment 
}


# Use the function to install flux onto the staging cluster.
bootstrap_flux "do-nyc3-solomon-ai-k8s-staging" "staging"
bootstrap_flux "do-nyc3-solomon-ai-k8s-prod" "production"

echo "defining source for staging"
refine_repo_and_kustomize "do-nyc3-solomon-ai-k8s-staging" "staging"
refine_repo_and_kustomize "do-nyc3-solomon-ai-k8s-prod" "production"
