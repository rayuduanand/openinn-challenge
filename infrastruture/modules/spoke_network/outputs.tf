output "vnet_id" {
  description = "ID of the spoke virtual network"
  value       = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  description = "Name of the spoke virtual network"
  value       = azurerm_virtual_network.spoke.name
}

output "resource_group_name" {
  description = "Name of the spoke resource group"
  value       = azurerm_resource_group.spoke.name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "additional_subnet_ids" {
  description = "Map of additional subnet names to their IDs"
  value       = { for k, v in azurerm_subnet.additional : k => v.id }
}
