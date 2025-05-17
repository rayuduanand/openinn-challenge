/**
 * # Log Analytics Module
 * 
 * This module creates a Log Analytics workspace for monitoring Azure resources,
 * particularly the AKS cluster.
 */

resource "azurerm_resource_group" "log_analytics" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.workspace_name
  location            = azurerm_resource_group.log_analytics.location
  resource_group_name = azurerm_resource_group.log_analytics.name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

# Add solutions for container monitoring
resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.log_analytics.location
  resource_group_name   = azurerm_resource_group.log_analytics.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# Add solutions for security monitoring
resource "azurerm_log_analytics_solution" "security" {
  solution_name         = "Security"
  location              = azurerm_resource_group.log_analytics.location
  resource_group_name   = azurerm_resource_group.log_analytics.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }
}
