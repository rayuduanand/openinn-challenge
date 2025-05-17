resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  default_node_pool {
    name                = var.default_node_pool_name
    vm_size             = var.default_node_pool_vm_size
    vnet_subnet_id      = var.subnet_id
    min_count           = var.default_node_pool_min_count
    max_count           = var.default_node_pool_max_count
    node_count          = var.default_node_pool_node_count
    max_pods            = var.default_node_pool_max_pods
    os_disk_size_gb     = var.default_node_pool_os_disk_size_gb
    os_disk_type        = var.default_node_pool_os_disk_type
    type                = "VirtualMachineScaleSets"
    zones               = var.availability_zones
    node_labels         = var.default_node_pool_node_labels
    tags                = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    dns_service_ip    = var.network_dns_service_ip
    service_cidr      = var.network_service_cidr
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting"
  }

  role_based_access_control_enabled = true
  
  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = var.azure_rbac_enabled
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.enable_key_vault_secrets_provider ? [1] : []
    content {
      secret_rotation_enabled  = true
      secret_rotation_interval = "2m"
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = var.enable_app_gateway ? [1] : []
    content {
      gateway_id = var.app_gateway_id
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.enable_defender ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  azure_policy_enabled = var.enable_azure_policy
  
  maintenance_window {
    allowed {
      day   = "Saturday"
      hours = [21, 22, 23]
    }
    allowed {
      day   = "Sunday"
      hours = [21, 22, 23]
    }
  }

  auto_scaler_profile {
    balance_similar_node_groups      = var.auto_scaler_profile_balance_similar_node_groups
    expander                         = var.auto_scaler_profile_expander
    max_graceful_termination_sec     = var.auto_scaler_profile_max_graceful_termination_sec
    max_node_provisioning_time       = var.auto_scaler_profile_max_node_provisioning_time
    max_unready_nodes                = var.auto_scaler_profile_max_unready_nodes
    max_unready_percentage           = var.auto_scaler_profile_max_unready_percentage
    new_pod_scale_up_delay           = var.auto_scaler_profile_new_pod_scale_up_delay
    scale_down_delay_after_add       = var.auto_scaler_profile_scale_down_delay_after_add
    scale_down_delay_after_delete    = var.auto_scaler_profile_scale_down_delay_after_delete
    scale_down_delay_after_failure   = var.auto_scaler_profile_scale_down_delay_after_failure
    scan_interval                    = var.auto_scaler_profile_scan_interval
    scale_down_unneeded              = var.auto_scaler_profile_scale_down_unneeded
    scale_down_unready               = var.auto_scaler_profile_scale_down_unready
    scale_down_utilization_threshold = var.auto_scaler_profile_scale_down_utilization_threshold
    empty_bulk_delete_max            = var.auto_scaler_profile_empty_bulk_delete_max
    skip_nodes_with_local_storage    = var.auto_scaler_profile_skip_nodes_with_local_storage
    skip_nodes_with_system_pods      = var.auto_scaler_profile_skip_nodes_with_system_pods
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool[0].node_count
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each              = var.additional_node_pools
  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  vnet_subnet_id        = var.subnet_id
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  node_count            = each.value.node_count
  max_pods              = each.value.max_pods
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  os_type               = each.value.os_type
  priority              = each.value.priority
  zones                 = var.availability_zones
  node_labels           = each.value.node_labels
  tags                  = var.tags

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each             = toset(var.acr_ids)
  scope                = each.value
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
