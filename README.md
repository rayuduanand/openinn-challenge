# Azure AKS Hub-and-Spoke Project

This repository provides a comprehensive infrastructure and application deployment strategy for **Azure Kubernetes Service (AKS)** using a **hub-and-spoke network topology** and **Infrastructure as Code (IaC)** with **Terraform**.

---

## 📂 Project Structure

```
openinn-challenge/
├── applications/              # Application source code
│   ├── backend-service/       # Backend application code
│   └── frontend/              # Frontend application code
├── helm/                      # Helm charts for application deployment
│   ├── backend-service/       # Backend service Helm chart
│   ├── frontend/              # Frontend Helm chart
│   ├── ingress-nginx/         # Ingress controller Helm chart
│   ├── monitoring/            # Monitoring stack (Prometheus, Grafana, etc.)
│   ├── postgresql-ha/         # PostgreSQL HA Helm chart
│   ├── helmfile.yaml          # Helmfile for orchestrating chart deployments
│   └── deploy_app_aks.sh      # Deployment script for applications
├── infrastruture/             # Infrastructure as Code (IaC)
│   ├── modules/               # Reusable Terraform modules
│   │   ├── aks_cluster/       # AKS cluster module
│   │   ├── hub_network/       # Hub network module
│   │   ├── spoke_network/     # Spoke network module
│   │   ├── log_analytics/     # Log Analytics module
│   │   ├── key_vault/         # Key Vault module
│   │   └── ...                # Other infrastructure modules
│   ├── environments/          # Environment-specific configurations
│   │   ├── dev/               # Development environment
│   │   ├── staging/           # Staging environment
│   │   └── prod/              # Production environment
│   ├── deployments/           # Kubernetes deployment configurations
│   └── .gitlab-ci.yaml        # GitLab CI/CD pipeline configuration
└── README.md                  # Project documentation
```

---

## 🚀 Infrastructure Setup

### Terraform Modules

**Key infrastructure components, modularized with Terraform:**

- **Hub Network**: Central VNet with Azure Firewall, Bastion Host, Gateway Subnets
- **Spoke Network**: AKS subnets, peered to the Hub
- **AKS Cluster**: Managed Kubernetes with configurable node pools
- **Log Analytics**: Centralized logging and metrics
- **Key Vault**: Secure secret management

Each environment (`dev`, `staging`, `prod`) has tailored configuration for scaling and security.

---

### 🛠️ Infrastructure Deployment Workflow

Managed with **GitLab CI/CD**:

1. **Validation**
    - TFLint, Checkov for syntax and security validation
2. **Sonar-check**
    - Code quality scan via SonarQube
3. **SAST**
    - Static Application Security Testing
4. **TrivyScan**
    - Container vulnerability scanning
5. **Plan**
    - Generate Terraform execution plan
6. **Apply**
    - Apply infrastructure changes with approval gates for production
7. **Destroy**
    - Remove infrastructure for ephemeral environments or cleanup

---

## 🏢 Application Setup & Deployment

### Application Stack

- **Frontend**: Web UI
- **Backend**: API service
- **PostgreSQL HA**: Highly available database
- **Ingress-NGINX**: External traffic routing
- **Monitoring**: Prometheus, Grafana, Alertmanager

### Deployment Strategy

- **Helm Charts**: Each component has its own chart under `/helm`
- **Helmfile**: Orchestrates multi-chart deployment (`helmfile.yaml`)
- **Environment Values**: Values files per environment

#### Deploy Commands

```sh
# Using the deployment script
./deploy_app_aks.sh

# Or directly with Helmfile
helmfile -e <env> apply
```

---

## 📉 Best Practices Implemented

- **Reliability & Resilience**
    - Velero Backups: Periodic backups for application state & cluster resources
    - Horizontal Pod Autoscaler (HPA): Scales pods based on resource usage
    - Cluster Autoscaler: Adjusts AKS node pool size dynamically
    - Pod Disruption Budgets (PDBs): Maintains service availability

---

## 🔎 Future Improvements

- **GitOps**: Adopt ArgoCD or Flux for declarative delivery
- **Centralized Secrets**: Integrate HashiCorp Vault for advanced secrets management
- **Cost Optimization**: Schedule automated AKS cluster start/stop for non-peak hours

---
