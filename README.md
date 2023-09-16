## Solomon-AI API Gateway

[![e2e](https://github.com/stefanprodan/podinfo/workflows/e2e/badge.svg)](https://github.com/stefanprodan/podinfo/blob/master/.github/workflows/e2e.yml)
[![test](https://github.com/stefanprodan/podinfo/workflows/test/badge.svg)](https://github.com/stefanprodan/podinfo/blob/master/.github/workflows/test.yml)
[![cve-scan](https://github.com/stefanprodan/podinfo/workflows/cve-scan/badge.svg)](https://github.com/stefanprodan/podinfo/blob/master/.github/workflows/cve-scan.yml)
[![Go Report Card](https://goreportcard.com/badge/github.com/stefanprodan/podinfo)](https://goreportcard.com/report/github.com/stefanprodan/podinfo)
[![Docker Pulls](https://img.shields.io/docker/pulls/stefanprodan/podinfo)](https://hub.docker.com/r/stefanprodan/podinfo)

Access the service's [postman collection](https://simfiny.postman.co/workspace/bedef41e-f5e6-4042-8577-06e7fd3bcb69/folder/4045899-ab4b7bed-2ff4-4e39-affa-d0ef1b594027)

Api gateway is a microservice that serves as the entrypoint into the solomon-ai backend and
runs primarily on kubernetes

Specifications:

* Health checks (readiness and liveness)
* Graceful shutdown on interrupt signals
* File watcher for secrets and configmaps
* Instrumented with Prometheus and Open Telemetry
* Structured logging with zap 
* 12-factor app with viper
* Fault injection (random errors and latency)
* Swagger docs
* CUE, Helm and Kustomize installers
* End-to-End testing with Kubernetes Kind and Helm
* Multi-arch container image with Docker buildx and Github Actions
* Container image signing with Sigstore cosign
* SBOMs and SLSA Provenance embedded in the container image
* CVE scanning with Trivy

Web API:
* `GET /metrics` return HTTP requests duration and Go runtime metrics
* `GET /healthz` used by Kubernetes liveness probe
* `GET /readyz` used by Kubernetes readiness probe
__MORE ENDPOINTS TBD__


### Guides

* [GitOps Progressive Deliver with Flagger, Helm v3 and Linkerd](https://helm.workshop.flagger.dev/intro/)
* [GitOps Progressive Deliver on EKS with Flagger and AppMesh](https://eks.handson.flagger.dev/prerequisites/)
* [Automated canary deployments with Flagger and Istio](https://medium.com/google-cloud/automated-canary-deployments-with-flagger-and-istio-ac747827f9d1)
* [Kubernetes autoscaling with Istio metrics](https://medium.com/google-cloud/kubernetes-autoscaling-with-istio-metrics-76442253a45a)
* [Autoscaling EKS on Fargate with custom metrics](https://aws.amazon.com/blogs/containers/autoscaling-eks-on-fargate-with-custom-metrics/)
* [Managing Helm releases the GitOps way](https://medium.com/google-cloud/managing-helm-releases-the-gitops-way-207a6ac6ff0e)
* [Securing EKS Ingress With Contour And Let’s Encrypt The GitOps Way](https://aws.amazon.com/blogs/containers/securing-eks-ingress-contour-lets-encrypt-gitops/)

### Install

To install the api-gateway on Kubernetes the minimum required version is **Kubernetes v1.23**.

#### Helm

Install from github.io:

```bash
helm repo add api-gateway https://solomonaiengineering.github.io/backend-api-gateway

helm upgrade --install --wait api-gateway \
--namespace test \
--set replicaCount=2 \
api-gateway/api-gateway

helm test api-gateway --namespace test
```

Install from ghcr.io:

```bash
helm upgrade --install --wait api-gateway --namespace default \
oci://ghcr.io/solomonaiengineering/charts/api-gateway
```

#### Kustomize

```bash
kubectl apply -k github.com/solomonaiengineering/backend-api-gateway//kustomize
```

#### Docker

```bash
docker run -dp 9898:9898 solomonaiengineering/backend-api-gateway
```

### Continuous Delivery

In order to install api-gateways on a Kubernetes cluster and keep it up to date with the latest
release in an automated manner, you can use [Flux](https://fluxcd.io).

Install the Flux CLI on MacOS and Linux using Homebrew:

```sh
brew install fluxcd/tap/flux
```

Install the Flux controllers needed for Helm operations:

```sh
flux install \
--namespace=flux-system \
--network-policy=false \
--components=source-controller,helm-controller
```

Add api-gateway's Helm repository to your cluster and
configure Flux to check for new chart releases every ten minutes:

```sh
flux create source helm api-gateway \
--namespace=default \
--url=https://solomonaiengineering.github.io/api-gateway \
--interval=10m
```

Create a `api-gateway-values.yaml` file locally:

```sh
cat > api-gateway-values.yaml <<EOL
replicaCount: 2
resources:
  limits:
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 64Mi
EOL
```

Create a Helm release for deploying api-gateway in the default namespace:

```sh
flux create helmrelease api-gateway \
--namespace=default \
--source=HelmRepository/api-gateway \
--release-name=api-gateway \
--chart=api-gateway \
--chart-version=">5.0.0" \
--values=api-gateway-values.yaml
```

Based on the above definition, Flux will upgrade the release automatically
when a new version of api-gateway is released. If the upgrade fails, Flux
can [rollback](https://toolkit.fluxcd.io/components/helm/helmreleases/#configuring-failure-remediation)
to the previous working version.

You can check what version is currently deployed with:

```sh
flux get helmreleases -n default
```

To delete api-gateway's Helm repository and release from your cluster run:

```sh
flux -n default delete source helm api-gateway
flux -n default delete helmrelease api-gateway
```

If you wish to manage the lifecycle of your applications in a **GitOps** manner, check out
this [workflow example](https://github.com/fluxcd/flux2-kustomize-helm-example)
for multi-env deployments with Flux, Kustomize and Helm.