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
rke2-ansible/
├── inventory/
│   └── hosts.ini                # Inventory file with node definitions
├── group_vars/
│   └── all.yml                  # Global variables for all hosts
├── playbooks/
│   └── site.yml                 # Main playbook for deployment
├── roles/
│   ├── common/                  # Common setup for all nodes
│   ├── harbor/                  # Harbor registry deployment
│   ├── rke2/                    # RKE2 cluster deployment
│   ├── metallb/                 # MetalLB load balancer
│   ├── ingress/                 # Nginx ingress controller
│   ├── longhorn/                # Longhorn storage
│   ├── velero/                  # Velero backup solution
│   └── monitoring/              # Prometheus, Grafana, and Loki
└── files/                       # Airgap installation files
    ├── charts/                  # Helm charts for airgap installation
    ├── docker/                  # Docker installation packages
    ├── harbor/                  # Harbor installation files
    ├── images/                  # Container images in tar format
    └── rke2/                    # RKE2 installation files
    └── README.md                # RKE2 installation process documentation
└ README.md                  # Project documentation
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
## Use GitLab CI/CD

Follow these simple steps to leverage GitLab CI/CD for your air-gap preparation:

Clone or Push: Begin by cloning this repository to your GitLab instance, or push its contents to a new project.
Configure Variables: Set up any required CI/CD variables in your GitLab project settings (e.g., HARBOR_URL, RKE2_VERSION, etc. - if applicable).
Run Pipeline: Execute the CI/CD pipeline directly from your GitLab project.
Download Artifacts: Once the pipeline successfully completes, download the generated artifacts (typically a .tar.gz archive or a structured files/ folder) from the pipeline's "Jobs" or "Pipelines" section.
⚙️ CI/CD Workflow: Internet-Connected Environment Preparation
The core of this solution lies within the CI/CD pipeline, specifically executing the prepare-airgap.sh script in an internet-connected environment. This script automates the collection and packaging of all required resources.

Automated Preparation Steps:
The prepare-airgap.sh script performs the following critical actions:

RKE2 Binaries & Images: Downloads the necessary RKE2 Kubernetes binaries and container images for your target version.
Harbor Offline Installer: Fetches the complete Harbor offline installer package.
Docker Image Collection: Pulls and saves all specified Docker images required by your core services into a format suitable for air-gapped transfer.
Helm Chart Acquisition: Downloads Helm charts for all essential core services, ensuring consistent deployment.
Helmfile Configuration: Generates a Helmfile configuration, facilitating streamlined orchestration and deployment of charts in the air-gapped environment.
Component Packaging: Organizes and packages all collected components into a structured directory (files/).