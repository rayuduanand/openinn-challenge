# Helm & Helmfile Deployment for Tic-Tac-Toe Microservices

This project contains Helm charts and a Helmfile to deploy the Tic-Tac-Toe application stack, including frontend, backend-service, and PostgreSQL database, on Kubernetes.

## Directory Structure

```
helm/
  frontend/           # Helm chart for the frontend (TypeScript app)
  backend-service/    # Helm chart for the backend (Java Spring Boot app)
  postgresql-ha/      # Helm chart for PostgreSQL (e.g., Bitnami)
  helmfile.yaml       # Helmfile to manage all releases
  lint-helm.sh        # Script to lint Helm charts and YAML files
```

## Prerequisites
- Kubernetes cluster (v1.23+ recommended)
- Helm 3.8.0+
- Helmfile
- yamllint (for YAML linting, install via `pip install yamllint`)

## Usage

### 1. Lint Helm Charts and YAML
Run this script to lint all charts and YAML files before deploying:

```sh
./lint-helm.sh
```

### 2. Dry-Run Helmfile Deployment
Check if all charts and values are valid for deployment:

```sh
helmfile -f helm/helmfile.yaml apply --dry-run
```

### 3. Deploy to Kubernetes
Deploy all services:

```sh
helmfile -f helm/helmfile.yaml apply
```

Deploy a specific component using labels (as defined in `helmfile.yaml`):

```sh
helmfile -f helm/helmfile.yaml --selector component=frontend apply
```

### 4. Chart Customization
Edit the `values.yaml` in each chart directory to customize configuration, such as image, resources, environment variables, etc.

---

## Project Status
- [x] Helm charts for frontend, backend, and PostgreSQL placed in `helm/`
- [x] Helmfile for multi-service orchestration
- [x] Linting script for YAML and Helm best practices
