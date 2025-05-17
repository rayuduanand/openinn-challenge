output "workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "primary_shared_key" {
  description = "Primary shared key for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "secondary_shared_key" {
  description = "Secondary shared key for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.secondary_shared_key
  sensitive   = true
}

output "resource_group_name" {
  description = "Name of the resource group for the Log Analytics workspace"
  value       = azurerm_resource_group.log_analytics.name
}
