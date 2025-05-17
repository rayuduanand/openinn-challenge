/**
 * # Hub Network Module
 * 
 * This module creates the hub network in a hub-and-spoke architecture.
 * The hub network contains shared resources and connectivity components.
 */

resource "azurerm_resource_group" "hub" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = var.vnet_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet" # This name is required by Azure
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.firewall_subnet_address_prefix
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet" # This name is required by Azure
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.gateway_subnet_address_prefix
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet" # This name is required by Azure
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.bastion_subnet_address_prefix
}

# Public IP for Azure Firewall
resource "azurerm_public_ip" "firewall" {
  name                = "${var.vnet_name}-fw-pip"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Azure Firewall
resource "azurerm_firewall" "hub" {
  name                = "${var.vnet_name}-fw"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

# Public IP for Azure Bastion
resource "azurerm_public_ip" "bastion" {
  name                = "${var.vnet_name}-bastion-pip"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Azure Bastion Host
resource "azurerm_bastion_host" "hub" {
  name                = "${var.vnet_name}-bastion"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
