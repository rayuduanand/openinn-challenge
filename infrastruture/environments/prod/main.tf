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
  
  backend "azurerm" {}
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
  environment = "prod"
  location    = "eastus2"
  tags = {
    Environment = "Production"
    Project     = "AKS Hub-Spoke"
    ManagedBy   = "Terraform"
  }
}

module "hub_network" {
  source              = "../../modules/hub_network"
  resource_group_name = "rg-hub-${local.environment}"
  location            = local.location
  vnet_name           = "vnet-hub-${local.environment}"
  address_space       = ["10.20.0.0/16"]
  
  firewall_subnet_address_prefix = ["10.20.0.0/24"]
  gateway_subnet_address_prefix  = ["10.20.1.0/24"]
  bastion_subnet_address_prefix  = ["10.20.2.0/24"]
  
  tags = local.tags
}

module "aks_spoke_network" {
  source              = "../../modules/spoke_network"
  resource_group_name = "rg-spoke-aks-${local.environment}"
  location            = local.location
  vnet_name           = "vnet-spoke-aks-${local.environment}"
  address_space       = ["10.21.0.0/16"]
  
  aks_subnet_name           = "snet-aks"
  aks_subnet_address_prefix = ["10.21.0.0/22"]
  
  additional_subnets = {
    "snet-private-endpoints" = {
      address_prefixes  = ["10.21.4.0/24"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    },
    "snet-app-gateway" = {
      address_prefixes  = ["10.21.5.0/24"]
      service_endpoints = ["Microsoft.Web"]
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
  retention_in_days   = 90
  
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
  
  purge_protection_enabled    = true
  soft_delete_retention_days  = 90
  
  access_policies = {
    "terraform" = {
      object_id               = data.azurerm_client_config.current.object_id
      key_permissions         = ["Get", "List", "Create", "Delete", "Update"]
      secret_permissions      = ["Get", "List", "Set", "Delete"]
      certificate_permissions = ["Get", "List", "Create", "Delete", "Update"]
      storage_permissions     = []
    }
  }
  
  enable_private_endpoint     = true
  private_endpoint_subnet_id  = module.aks_spoke_network.additional_subnet_ids["snet-private-endpoints"]
  
  tags = local.tags
}

resource "azurerm_public_ip" "app_gateway" {
  name                = "pip-appgw-${local.environment}"
  resource_group_name = "rg-appgw-${local.environment}"
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_application_gateway" "main" {
  name                = "appgw-aks-${local.environment}"
  resource_group_name = "rg-appgw-${local.environment}"
  location            = local.location
  tags                = local.tags

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = module.aks_spoke_network.additional_subnet_ids["snet-app-gateway"]
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }

  backend_address_pool {
    name = "default-backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "default-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "default-backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 100
  }

  waf_configuration {
    enabled                  = true
    firewall_mode            = "Prevention"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.2"
    file_upload_limit_mb     = 100
    max_request_body_size_kb = 128
  }
}

module "aks_cluster" {
  source              = "../../modules/aks_cluster"
  cluster_name        = "aks-${local.environment}"
  location            = local.location
  resource_group_name = "rg-aks-${local.environment}"
  dns_prefix          = "aks-${local.environment}"
  kubernetes_version  = "1.25.5"
  
  subnet_id               = module.aks_spoke_network.aks_subnet_id
  network_dns_service_ip  = "10.21.0.10"
  network_service_cidr    = "10.21.0.0/16"
  
  default_node_pool_name                = "system"
  default_node_pool_vm_size             = "Standard_D4s_v3"
  default_node_pool_enable_auto_scaling = true
  default_node_pool_min_count           = 3
  default_node_pool_max_count           = 5
  default_node_pool_node_count          = 3
  default_node_pool_max_pods            = 30
  default_node_pool_os_disk_size_gb     = 128
  default_node_pool_node_labels         = { "nodepool-type" = "system", "environment" = "prod" }
  
  additional_node_pools = {
    "user" = {
      vm_size             = "Standard_D8s_v3"
      enable_auto_scaling = true
      min_count           = 3
      max_count           = 10
      node_count          = 3
      max_pods            = 30
      os_disk_size_gb     = 256
      os_disk_type        = "Managed"
      os_type             = "Linux"
      priority            = "Regular"
      node_labels         = { "nodepool-type" = "user", "environment" = "prod" }
      node_taints         = []
    }
  }
  
  log_analytics_workspace_id = module.log_analytics.workspace_id
  enable_key_vault_secrets_provider = true
  
  admin_group_object_ids = []
  azure_rbac_enabled     = true
  enable_azure_policy    = true
  enable_defender        = true
  
  enable_app_gateway = true
  app_gateway_id     = azurerm_application_gateway.main.id
  
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
  
  # Configure ingress settings - use Application Gateway in production
  enable_ingress      = true
  ingress_domain      = "${local.environment}.example.com"
  
  # Configure storage with higher capacity for production
  storage_class_name  = "managed-premium"
  
  # Use specific chart versions for stability in production
  prometheus_chart_version = "45.7.1"
  loki_chart_version       = "2.9.10"
  grafana_chart_version    = "6.52.1"
  
  # Additional values for production environment
  prometheus_additional_values = <<-EOT
    prometheus:
      resources:
        limits:
          cpu: 2000m
          memory: 4Gi
        requests:
          cpu: 1000m
          memory: 2Gi
      storageSpec:
        volumeClaimTemplate:
          spec:
            resources:
              requests:
                storage: 100Gi
  EOT
}

data "azurerm_client_config" "current" {}
