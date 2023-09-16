# Kustomize Implementation with Flux

This repository provides an outline and instructions for managing Kubernetes resources using Kustomize and Flux CD.

## Table of Contents

- [Kustomize Implementation with Flux](#kustomize-implementation-with-flux)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Bootstrap Flux onto a Cluster](#bootstrap-flux-onto-a-cluster)
  - [Feedback and Issues](#feedback-and-issues)

## Overview

Kustomize offers a solution for customizing Kubernetes manifests without forking or templating. By working seamlessly with Flux, we have a powerful GitOps-driven deployment toolchain that can be used across multiple environments.

## Prerequisites

1. A running Kubernetes cluster.
2. `kubectl` configured to connect to the desired cluster.
3. `flux` CLI installed.
4. A GitHub account and repository to store your Kubernetes manifests and Kustomize configurations.

## Bootstrap Flux onto a Cluster

Before setting up your environments, ensure Flux is bootstrapped onto your desired cluster. Use the following simplified command for either staging or production:

```bash
bootstrap_flux() {
  local environment=$1

  flux bootstrap github \
    --owner=$GITHUB_USER \
    --repository=$GITHUB_REPO \
    --branch=main \
    --path=./clusters/$environment \
    --personal
}

bootstrap_flux "staging"

bootstrap_flux "production"

Replace $GITHUB_USER and $GITHUB_REPO with your GitHub username and repository name, respectively.

## Environment Setup
Your repository structure should look something like:
```
.
├── clusters
│   ├── production
│   └── staging
└── README.md
```

Each environment (staging, production) should have its Kustomize base and overlays, making it simple to maintain common configurations while allowing for environment-specific changes.

To apply changes:

1. Update the desired manifests and Kustomize configurations.
2. Commit and push to the main branch.
3. Flux will automatically detect and apply the changes to the respective environment based on the path provided during the bootstrap process.

## Feedback and Issues
If you have feedback or encounter any issues, please file an issue in this repository's Issue Tracker.