This document outlines a comprehensive infrastructure and application deployment strategy for Azure Kubernetes Service (AKS) using a hub-and-spoke network topology and Infrastructure as Code (IaC) with Terraform.

📂 Project Structure

openinn-challenge/
├── applications/           # Application source code
│   ├── backend-service/    # Backend application code
│   └── frontend/           # Frontend application code
├── helm/                   # Helm charts for application deployment
│   ├── backend-service/    # Backend service Helm chart
│   ├── frontend/           # Frontend Helm chart
│   ├── ingress-nginx/      # Ingress controller Helm chart
│   ├── monitoring/         # Monitoring stack (Prometheus, Grafana, etc.)
│   ├── postgresql-ha/      # PostgreSQL HA Helm chart
│   ├── helmfile.yaml       # Helmfile for orchestrating chart deployments
│   └── deploy_app_aks.sh   # Deployment script for applications
├── infrastruture/          # Infrastructure as Code (IaC)
│   ├── modules/            # Reusable Terraform modules
│   │   ├── aks_cluster/    # AKS cluster module
│   │   ├── hub_network/    # Hub network module
│   │   ├── spoke_network/  # Spoke network module
│   │   ├── log_analytics/  # Log Analytics module
│   │   ├── key_vault/      # Key Vault module
│   │   └── ...             # Other infrastructure modules
│   ├── environments/       # Environment-specific configurations
│   │   ├── dev/            # Development environment
│   │   ├── staging/        # Staging environment
│   │   └── prod/           # Production environment
│   ├── deployments/        # Kubernetes deployment configurations
│   └── .gitlab-ci.yaml     # GitLab CI/CD pipeline configuration
└── README.md               # Project documentation

🚀 Infrastructure Setup

Terraform Modules

Key components modularized using Terraform:

Hub Network: Central VNet with Azure Firewall, Bastion Host, and Gateway Subnets

Spoke Network: Connected AKS subnets peered to the hub

AKS Cluster: Managed Kubernetes cluster with configurable node pools

Log Analytics: Centralized logging and metrics

Key Vault: Centralized and secure secret management

Each environment (dev, staging, prod) has its own configurations with scaling and security settings tailored to its usage.

Infrastructure Deployment Workflow

Managed through GitLab CI/CD:

Validation: Run TFLint and Checkov for syntax and security validation

Sonar-check: Code quality scanning using SonarQube

SAST: Static Application Security Testing

TrivyScan: Container vulnerability scanning

Plan: Generate an execution plan to preview changes

Apply: Apply infrastructure changes with approval gates for production

Destroy: Remove infrastructure for temporary environments or cleanup

🏢 Application Setup and Deployment

Application Stack

Frontend: Web user interface

Backend: API service

PostgreSQL HA: High-availability relational database

Ingress-NGINX: Handles external traffic routing

Monitoring: Prometheus, Grafana, Alertmanager for observability

Deployment Strategy with Helmfile

Helm Charts: Each component has a chart in /helm

Helmfile: Coordinates multi-chart deployment using helmfile.yaml

Environment Values: Each environment has its own values config

Deploy Commands:

# Shell script
./deploy_app_aks.sh <environment>

# Or directly with Helmfile
helmfile -e <environment> apply

📉 Best Practices Implemented

Reliability and Resilience

Velero Backups: Periodic backups for both application state and AKS cluster resources

Horizontal Pod Autoscaler (HPA): Automatically scales pods based on CPU/memory usage

Cluster Autoscaler: Dynamically adjusts node count in AKS node pools based on workload demand

Pod Disruption Budgets (PDBs): Maintains service availability during voluntary disruptions

Node Affinity:

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: node-type
          operator: In
          values:
          - application

🔎 Future Improvements

GitOps Implementation: Adopt GitOps using ArgoCD or Flux for declarative infrastructure and application delivery

Centralized Secrets Management: Integrate with HashiCorp Vault for advanced secrets lifecycle and access policies

Cost Optimization: Schedule automated AKS cluster start/stop operations during non-peak hours to reduce costs

This document serves as a complete high-level and technical overview of the Azure AKS Hub-and-Spoke project. It is designed to be accessible for developers, DevOps engineers, and architects alike.

