/**
 * # Spoke Network Module
 * 
 * This module creates a spoke network in a hub-and-spoke architecture.
 * The spoke network will host the AKS cluster and connect to the hub network.
 */

resource "azurerm_resource_group" "spoke" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "spoke" {
  name                = var.vnet_name
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = var.aks_subnet_address_prefix
  service_endpoints    = var.aks_subnet_service_endpoints

  dynamic "delegation" {
    for_each = var.aks_subnet_delegations
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

# Create additional subnets if needed
resource "azurerm_subnet" "additional" {
  for_each             = var.additional_subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = lookup(each.value, "service_endpoints", [])

  dynamic "delegation" {
    for_each = lookup(each.value, "delegations", [])
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

# Create peering from spoke to hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "spoke-to-hub"
  resource_group_name          = azurerm_resource_group.spoke.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = var.hub_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.use_remote_gateways
}

# Create peering from hub to spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "hub-to-spoke-${var.vnet_name}"
  resource_group_name          = var.hub_resource_group_name
  virtual_network_name         = var.hub_virtual_network_name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = false
}

# Create route table for AKS subnet to route traffic through the hub firewall
resource "azurerm_route_table" "aks" {
  name                = "${var.vnet_name}-aks-rt"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = var.tags

  route {
    name                   = "to-hub-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.hub_firewall_private_ip
  }
}

# Associate route table with AKS subnet
resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.aks.id
}
