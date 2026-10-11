# AKS CI/CD Pipeline

![CI](https://github.com/Kishore2488/aks-cicd-pipeline/actions/workflows/ci.yml/badge.svg)

A small, containerized Flask API wired up to a full CI/CD pipeline — the same shape of pipeline I build and run day-to-day as a DevOps Engineer, scaled down to something you can read end-to-end in five minutes.

## What this shows

- **CI/CD pipeline design** — GitHub Actions workflows for lint, test, Docker build, container smoke test, and Kubernetes manifest validation on every push.
- **Containerization** — a minimal, healthcheck-aware Dockerfile.
- **Kubernetes on AKS** — deployment and service manifests with readiness/liveness probes and resource limits, plus a manual-dispatch deploy workflow using `azure/login` and `azure/aks-set-context`.
- **Infrastructure automation with Ansible** — a playbook that bootstraps AKS nodes with monitoring and baseline tuning.

## Architecture

```
  developer push
        |
        v
  +-----------+      +----------------+      +------------------------+
  |  GitHub   | ---> |  CI workflow   | ---> | lint -> test -> docker  |
  |  (main)   |      |  (ci.yml)      |      | build -> smoke test ->  |
  +-----------+      +----------------+      | validate k8s manifests |
                                              +------------------------+
                                                         |
                                            workflow_dispatch (manual)
                                                         v
                                              +------------------------+
                                              |  CD workflow (cd.yml)  |
                                              |  azure/login           |
                                              |  aks-set-context       |
                                              |  kubectl apply/rollout |
                                              +------------------------+
                                                         |
                                                         v
                                              +------------------------+
                                              |  AKS cluster           |
                                              |  (Ansible-bootstrapped |
                                              |   nodes)               |
                                              +------------------------+
```

## Repo layout

```
app/            Flask API (/, /health, /version)
tests/          pytest suite for the API
Dockerfile      container build for the app
k8s/            Deployment + Service manifests for AKS
ansible/        playbook + inventory to bootstrap AKS nodes
.github/
  workflows/
    ci.yml      lint, test, docker build, manifest validation — runs on every push
    cd.yml      manual deploy to AKS — workflow_dispatch only
```

## Run it locally

```bash
pip install -r app/requirements.txt
python app/app.py
# curl http://localhost:5000/health
```

Or with Docker:

```bash
docker build -t aks-cicd-demo .
docker run -p 5000:5000 aks-cicd-demo
```

## Deploying for real

The CD workflow is manual-trigger by design — this repo isn't wired to a live AKS cluster, so it won't silently fail in Actions. To point it at a real cluster:

1. Add repo secrets: `AZURE_CREDENTIALS`, `AKS_RESOURCE_GROUP`, `AKS_CLUSTER_NAME`.
2. Push an image to a registry the cluster can pull from (e.g. GHCR).
3. Run the **CD - Deploy to AKS** workflow from the Actions tab with the image tag to deploy.

## Why I built it this way

The CI workflow is split from the CD workflow on purpose: build/test/validate should run on every push and stay green, while a deploy to real infrastructure should be a deliberate, auditable action — not something that fires automatically against a cluster that may not even exist yet. That's the same separation I apply to pipelines at work.
