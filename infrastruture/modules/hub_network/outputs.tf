output "vnet_id" {
  description = "ID of the hub virtual network"
  value       = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  description = "Name of the hub virtual network"
  value       = azurerm_virtual_network.hub.name
}

output "resource_group_name" {
  description = "Name of the hub resource group"
  value       = azurerm_resource_group.hub.name
}

output "firewall_id" {
  description = "ID of the Azure Firewall"
  value       = azurerm_firewall.hub.id
}

output "firewall_private_ip" {
  description = "Private IP of the Azure Firewall"
  value       = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "Public IP of the Azure Firewall"
  value       = azurerm_public_ip.firewall.ip_address
}

output "bastion_host_id" {
  description = "ID of the Azure Bastion Host"
  value       = azurerm_bastion_host.hub.id
}
