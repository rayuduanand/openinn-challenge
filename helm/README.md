# Helm & Helmfile Deployment for Azure AKS Application Stack

This directory contains Helm charts and Helmfile configurations for deploying the complete application stack on Azure Kubernetes Service (AKS).

## Directory Structure

```
helm/
├── backend-service/    # Helm chart for the backend service
├── frontend/           # Helm chart for the frontend application
├── ingress-nginx/      # Helm chart for the NGINX ingress controller
├── monitoring/         # Monitoring stack (Prometheus, Grafana, AlertManager)
├── postgresql-ha/      # PostgreSQL with high availability configuration
├── helmfile.yaml       # Helmfile to orchestrate all deployments
├── deploy_app_aks.sh   # Script to deploy applications to AKS
└── lint-helm.sh        # Script to lint Helm charts and YAML files
```

## Prerequisites

- Kubernetes cluster (AKS v1.24+ recommended)
- Helm 3.10.0+
- Helmfile 0.150.0+
- kubectl configured to access your AKS cluster
- yamllint (for YAML linting, install via `pip install yamllint`)

## Application Deployment

### Environment-Based Deployment

The application stack is designed to be deployed to different environments (dev, staging, prod) using environment-specific values:

```bash
# Deploy to a specific environment
./deploy_app_aks.sh <environment>
```

Or using Helmfile directly:

```bash
# Deploy all components to an environment
helmfile -e <environment> apply

# Deploy with detailed output
helmfile -e <environment> -l debug apply
```

### Component-Specific Deployment

Deploy specific components using selectors:

```bash
# Deploy only the backend service
helmfile -e <environment> --selector component=backend-service apply

# Deploy only the monitoring stack
helmfile -e <environment> --selector component=monitoring apply
```

## Helm Charts Configuration

### Values Organization

Each chart follows a structured approach to values:

1. **Default values**: Base configuration in each chart's `values.yaml`
2. **Environment-specific values**: Override files for each environment:
   - `values-dev.yaml`
   - `values-staging.yaml`
   - `values-prod.yaml`

### High Availability Configuration

Production environments are configured for high availability with:

- **Replica count**: Multiple replicas for each service
- **Pod Disruption Budgets**: Ensuring minimum availability during updates
- **Horizontal Pod Autoscaling**: Automatically scaling based on metrics

```yaml
# Example HPA configuration in values-prod.yaml
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

### Node Affinity and Anti-Affinity

Critical components use node affinity and pod anti-affinity for optimal placement:

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: node-type
          operator: In
          values:
          - application
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - backend-service
        topologyKey: "kubernetes.io/hostname"
```

## Monitoring Stack

The monitoring directory contains a comprehensive observability solution:

- **Prometheus**: For metrics collection and storage
- **Grafana**: For visualization and dashboards
- **AlertManager**: For alerting and notifications
- **Loki**: For log aggregation (optional)
- **Tempo**: For distributed tracing (optional)

Custom dashboards are provided for:
- Application performance monitoring
- Infrastructure metrics
- Database health and performance

## GitOps Integration

This Helm configuration is designed to work with GitOps workflows:

1. **ArgoCD/Flux compatibility**: Works with popular GitOps tools
2. **Versioned deployments**: All chart versions are explicitly defined
3. **Immutable deployments**: Changes are made through version control
4. **Automated validation**: CI pipeline validates Helm charts before deployment

## Best Practices Implemented

1. **Separation of concerns**: Each component has its own chart
2. **Environment-specific configuration**: Values tailored to each environment
3. **Resource management**: Appropriate resource requests and limits
4. **Security**: Network policies, RBAC, and secure defaults
5. **Scalability**: Horizontal scaling and load distribution
6. **Monitoring**: Comprehensive metrics and alerting

## Usage Instructions

### 1. Lint Helm Charts and YAML

```bash
./lint-helm.sh
```

### 2. Dry-Run Deployment

```bash
helmfile -e <environment> apply --dry-run
```

### 3. Deploy to AKS

```bash
./deploy_app_aks.sh <environment>
```

### 4. Validate Deployment

```bash
kubectl get pods -n <namespace>
kubectl get ingress -n <namespace>
```
