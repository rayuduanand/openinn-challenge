variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the AKS cluster will be deployed"
  type        = string
}

variable "default_node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "system"
}

variable "default_node_pool_vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "default_node_pool_enable_auto_scaling" {
  description = "Enable auto scaling for the default node pool"
  type        = bool
  default     = true
}

variable "default_node_pool_min_count" {
  description = "Minimum number of nodes for the default node pool"
  type        = number
  default     = 1
}

variable "default_node_pool_max_count" {
  description = "Maximum number of nodes for the default node pool"
  type        = number
  default     = 3
}

variable "default_node_pool_node_count" {
  description = "Initial number of nodes for the default node pool"
  type        = number
  default     = 1
}

variable "default_node_pool_max_pods" {
  description = "Maximum number of pods per node for the default node pool"
  type        = number
  default     = 30
}

variable "default_node_pool_os_disk_size_gb" {
  description = "OS disk size for the default node pool"
  type        = number
  default     = 128
}

variable "default_node_pool_os_disk_type" {
  description = "OS disk type for the default node pool"
  type        = string
  default     = "Managed"
}

variable "default_node_pool_node_labels" {
  description = "Node labels for the default node pool"
  type        = map(string)
  default     = {}
}

variable "default_node_pool_node_taints" {
  description = "Node taints for the default node pool"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "Availability zones for the AKS cluster"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "network_dns_service_ip" {
  description = "IP address for the Kubernetes DNS service"
  type        = string
  default     = "10.0.0.10"
}

variable "network_docker_bridge_cidr" {
  description = "CIDR for the Docker bridge network"
  type        = string
  default     = "172.17.0.1/16"
}

variable "network_service_cidr" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "10.0.0.0/16"
}

variable "admin_group_object_ids" {
  description = "Object IDs of Azure AD groups with admin access to the cluster"
  type        = list(string)
  default     = []
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC for Kubernetes authorization"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for monitoring"
  type        = string
}

variable "enable_key_vault_secrets_provider" {
  description = "Enable Key Vault secrets provider for the AKS cluster"
  type        = bool
  default     = true
}

variable "enable_app_gateway" {
  description = "Enable Application Gateway Ingress Controller for the AKS cluster"
  type        = bool
  default     = false
}

variable "app_gateway_id" {
  description = "ID of the Application Gateway to use with the AKS cluster"
  type        = string
  default     = null
}

variable "enable_defender" {
  description = "Enable Microsoft Defender for the AKS cluster"
  type        = bool
  default     = true
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy for the AKS cluster"
  type        = bool
  default     = true
}

variable "additional_node_pools" {
  description = "Additional node pools to create"
  type = map(object({
    vm_size             = string
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    node_count          = number
    max_pods            = number
    os_disk_size_gb     = number
    os_disk_type        = string
    os_type             = string
    priority            = string
    node_labels         = map(string)
    node_taints         = list(string)
  }))
  default = {}
}

variable "acr_ids" {
  description = "List of Azure Container Registry IDs that the AKS cluster can pull from"
  type        = list(string)
  default     = []
}

variable "auto_scaler_profile_balance_similar_node_groups" {
  description = "Balance similar node groups for the cluster autoscaler"
  type        = bool
  default     = false
}

variable "auto_scaler_profile_expander" {
  description = "Expander for the cluster autoscaler"
  type        = string
  default     = "random"
}

variable "auto_scaler_profile_max_graceful_termination_sec" {
  description = "Maximum graceful termination time for the cluster autoscaler"
  type        = number
  default     = 600
}

variable "auto_scaler_profile_max_node_provisioning_time" {
  description = "Maximum node provisioning time for the cluster autoscaler"
  type        = string
  default     = "15m"
}

variable "auto_scaler_profile_max_unready_nodes" {
  description = "Maximum number of unready nodes for the cluster autoscaler"
  type        = number
  default     = 3
}

variable "auto_scaler_profile_max_unready_percentage" {
  description = "Maximum percentage of unready nodes for the cluster autoscaler"
  type        = number
  default     = 45
}

variable "auto_scaler_profile_new_pod_scale_up_delay" {
  description = "New pod scale up delay for the cluster autoscaler"
  type        = string
  default     = "10s"
}

variable "auto_scaler_profile_scale_down_delay_after_add" {
  description = "Scale down delay after add for the cluster autoscaler"
  type        = string
  default     = "10m"
}

variable "auto_scaler_profile_scale_down_delay_after_delete" {
  description = "Scale down delay after delete for the cluster autoscaler"
  type        = string
  default     = "10s"
}

variable "auto_scaler_profile_scale_down_delay_after_failure" {
  description = "Scale down delay after failure for the cluster autoscaler"
  type        = string
  default     = "3m"
}

variable "auto_scaler_profile_scan_interval" {
  description = "Scan interval for the cluster autoscaler"
  type        = string
  default     = "10s"
}

variable "auto_scaler_profile_scale_down_unneeded" {
  description = "Scale down unneeded time for the cluster autoscaler"
  type        = string
  default     = "10m"
}

variable "auto_scaler_profile_scale_down_unready" {
  description = "Scale down unready time for the cluster autoscaler"
  type        = string
  default     = "20m"
}

variable "auto_scaler_profile_scale_down_utilization_threshold" {
  description = "Scale down utilization threshold for the cluster autoscaler"
  type        = number
  default     = 0.5
}

variable "auto_scaler_profile_empty_bulk_delete_max" {
  description = "Empty bulk delete max for the cluster autoscaler"
  type        = number
  default     = 10
}

variable "auto_scaler_profile_skip_nodes_with_local_storage" {
  description = "Skip nodes with local storage for the cluster autoscaler"
  type        = bool
  default     = true
}

variable "auto_scaler_profile_skip_nodes_with_system_pods" {
  description = "Skip nodes with system pods for the cluster autoscaler"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
