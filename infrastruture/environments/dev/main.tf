terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }
  
  backend "azurerm" {
    # Backend configuration will be provided via a backend.tfvars file
    # or environment variables
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "kubernetes" {
  host                   = module.aks_cluster.host
  client_certificate     = base64decode(module.aks_cluster.client_certificate)
  client_key             = base64decode(module.aks_cluster.client_key)
  cluster_ca_certificate = base64decode(module.aks_cluster.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks_cluster.host
    client_certificate     = base64decode(module.aks_cluster.client_certificate)
    client_key             = base64decode(module.aks_cluster.client_key)
    cluster_ca_certificate = base64decode(module.aks_cluster.cluster_ca_certificate)
  }
}

locals {
  environment = "dev"
  location    = "eastus"
  tags = {
    Environment = "Development"
    Project     = "AKS Hub-Spoke"
    ManagedBy   = "Terraform"
  }
}

module "hub_network" {
  source              = "../../modules/hub_network"
  resource_group_name = "rg-hub-${local.environment}"
  location            = local.location
  vnet_name           = "vnet-hub-${local.environment}"
  address_space       = ["10.0.0.0/16"]
  
  firewall_subnet_address_prefix = ["10.0.0.0/24"]
  gateway_subnet_address_prefix  = ["10.0.1.0/24"]
  bastion_subnet_address_prefix  = ["10.0.2.0/24"]
  
  tags = local.tags
}

# Create the spoke network for AKS
module "aks_spoke_network" {
  source              = "../../modules/spoke_network"
  resource_group_name = "rg-spoke-aks-${local.environment}"
  location            = local.location
  vnet_name           = "vnet-spoke-aks-${local.environment}"
  address_space       = ["10.1.0.0/16"]
  
  aks_subnet_name           = "snet-aks"
  aks_subnet_address_prefix = ["10.1.0.0/22"]
  

  additional_subnets = {
    "snet-private-endpoints" = {
      address_prefixes  = ["10.1.4.0/24"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
  }
  
  hub_virtual_network_id    = module.hub_network.vnet_id
  hub_virtual_network_name  = module.hub_network.vnet_name
  hub_resource_group_name   = module.hub_network.resource_group_name
  hub_firewall_private_ip   = module.hub_network.firewall_private_ip
  
  tags = local.tags
}

module "log_analytics" {
  source              = "../../modules/log_analytics"
  resource_group_name = "rg-logs-${local.environment}"
  location            = local.location
  workspace_name      = "log-aks-${local.environment}"
  retention_in_days   = 30
  
  tags = local.tags
}

module "key_vault" {
  source              = "../../modules/key_vault"
  resource_group_name = "rg-kv-${local.environment}"
  location            = local.location
  key_vault_name      = "kv-aks-${local.environment}"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  network_acls_default_action = "Deny"
  network_acls_bypass         = "AzureServices"
  network_acls_subnet_ids     = [module.aks_spoke_network.additional_subnet_ids["snet-private-endpoints"]]
  
  access_policies = {
    "terraform" = {
      object_id               = data.azurerm_client_config.current.object_id
      key_permissions         = ["Get", "List", "Create", "Delete", "Update"]
      secret_permissions      = ["Get", "List", "Set", "Delete"]
      certificate_permissions = ["Get", "List", "Create", "Delete", "Update"]
      storage_permissions     = []
    }
  }
  
  tags = local.tags
}

module "aks_cluster" {
  source              = "../../modules/aks_cluster"
  cluster_name        = "aks-${local.environment}"
  location            = local.location
  resource_group_name = "rg-aks-${local.environment}"
  dns_prefix          = "aks-${local.environment}"
  kubernetes_version  = "1.25.5"
  
  subnet_id               = module.aks_spoke_network.aks_subnet_id
  network_dns_service_ip  = "10.1.0.10"
  network_service_cidr    = "10.1.0.0/16"
  network_docker_bridge_cidr = "172.17.0.1/16"
  
  default_node_pool_name                = "system"
  default_node_pool_vm_size             = "Standard_D2s_v3"
  default_node_pool_enable_auto_scaling = true
  default_node_pool_min_count           = 1
  default_node_pool_max_count           = 3
  default_node_pool_node_count          = 1
  default_node_pool_max_pods            = 30
  default_node_pool_node_labels         = { "nodepool-type" = "system", "environment" = "dev" }
  default_node_pool_node_taints         = []
  
  additional_node_pools = {
    "user" = {
      vm_size             = "Standard_D4s_v3"
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 5
      node_count          = 1
      max_pods            = 30
      os_disk_size_gb     = 128
      os_disk_type        = "Managed"
      os_type             = "Linux"
      priority            = "Regular"
      node_labels         = { "nodepool-type" = "user", "environment" = "dev" }
      node_taints         = []
    }
  }
  
  log_analytics_workspace_id = module.log_analytics.workspace_id
  enable_key_vault_secrets_provider = true
  
  admin_group_object_ids = []
  azure_rbac_enabled     = true
  enable_azure_policy    = true
  
  tags = local.tags
}

# Deploy monitoring stack with Helm charts
module "monitoring" {
  source = "../../modules/monitoring"
  
  # Only deploy monitoring after AKS cluster is available
  depends_on = [module.aks_cluster]
  
  cluster_name        = module.aks_cluster.name
  resource_group_name = module.aks_cluster.resource_group_name
  namespace           = "monitoring"
  
  # Configure ingress settings
  enable_ingress      = true
  ingress_domain      = "${local.environment}.example.com"
  
  # Configure storage
  storage_class_name  = "managed-premium"
}

data "azurerm_client_config" "current" {}
