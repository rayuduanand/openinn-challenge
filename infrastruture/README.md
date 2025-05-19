# Infrastructure Organization

This directory contains the Infrastructure as Code (IaC) components for the Azure AKS deployment with a hub-and-spoke architecture.

## Directory Structure

```
infrastruture/
├── modules/                # Reusable Terraform modules
│   ├── aks_cluster/        # AKS cluster module
│   ├── backup_recovery/    # Backup and recovery module
│   ├── dependecies/        # Dependencies module
│   ├── hub_network/        # Hub network module
│   ├── key_vault/          # Key Vault module
│   ├── key_vault_secrets/  # Key Vault secrets module
│   ├── log_analytics/      # Log Analytics module
│   └── spoke_network/      # Spoke network module
├── environments/           # Environment-specific configurations
│   ├── dev/                # Development environment
│   ├── staging/            # Staging environment
│   └── prod/               # Production environment
├── deployments/            # Kubernetes deployment configurations
└── .gitlab-ci.yaml         # GitLab CI/CD pipeline configuration
```

## Terraform Modules

Each module is designed to be reusable and configurable:

- **aks_cluster**: Provisions an AKS cluster with configurable node pools, networking, and security features
- **hub_network**: Creates the central hub network with Azure Firewall, Bastion, and Gateway subnets
- **spoke_network**: Establishes networks that contain AKS clusters and connect to the hub network
- **log_analytics**: Sets up monitoring and logging for the infrastructure
- **key_vault**: Manages secure secret storage
- **backup_recovery**: Handles backup and recovery operations for the infrastructure

## Environment-Specific Configurations

The `environments` directory contains configurations for different deployment environments:

- **dev**: Development environment with minimal resources for testing
- **staging**: Pre-production environment that mirrors production at a smaller scale
- **prod**: Production environment with full HA and security features

## Deployments Directory

The `deployments` directory is used for Kubernetes deployment configurations that are tightly coupled with the infrastructure:

- Kubernetes manifests for infrastructure-related components
- Configuration for cluster add-ons
- Integration points between infrastructure and application deployments

## Best Practices for Helm and Monitoring

### Helm Charts Organization

1. **Keep Helm charts separate from infrastructure code**: 
   - Helm charts are maintained in the `/helm` directory at the root level
   - This separation allows for independent versioning and development

2. **Infrastructure-specific Kubernetes manifests**:
   - Store in the `infrastruture/deployments` directory
   - These include manifests for components that are tightly coupled with the infrastructure

### Monitoring Components

1. **Monitoring stack deployment**:
   - Prometheus, Grafana, and other monitoring tools are deployed via Helm charts in the `/helm/monitoring` directory
   - Infrastructure-specific monitoring configurations are stored in `infrastruture/deployments`

2. **Log Analytics integration**:
   - Azure Log Analytics is provisioned via the Terraform `log_analytics` module
   - Integration between AKS and Log Analytics is configured in the `aks_cluster` module

## GitLab CI/CD Pipeline

The `.gitlab-ci.yaml` file defines the CI/CD pipeline for infrastructure deployment:

- **Validation stage**: Runs `terraform validate`, TFLint, and Checkov
- **Plan stage**: Generates and displays Terraform plans
- **Apply stage**: Applies Terraform changes with appropriate approvals
- **Destroy stage**: Safely tears down infrastructure when needed

## Best Practices Implemented

1. **Modular design**: Each component is isolated and reusable
2. **Environment separation**: Clear separation between dev, staging, and production
3. **Security-first approach**: Network segmentation, private clusters, and secure secret management
4. **GitOps workflow**: Changes tracked in version control with automated pipelines
5. **Infrastructure as Code**: Everything defined as code for consistency and repeatability
