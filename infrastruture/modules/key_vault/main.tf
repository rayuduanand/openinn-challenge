/**
 * # Key Vault Module
 * 
 * This module creates an Azure Key Vault for storing secrets securely,
 * particularly for use with the AKS cluster.
 */

resource "azurerm_resource_group" "key_vault" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.key_vault.location
  resource_group_name         = azurerm_resource_group.key_vault.name
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled
  sku_name                    = var.sku_name
  enable_rbac_authorization   = var.enable_rbac_authorization
  tags                        = var.tags

  network_acls {
    default_action             = var.network_acls_default_action
    bypass                     = var.network_acls_bypass
    ip_rules                   = var.network_acls_ip_rules
    virtual_network_subnet_ids = var.network_acls_subnet_ids
  }
}

# Access policies for the Key Vault
resource "azurerm_key_vault_access_policy" "main" {
  for_each     = var.access_policies
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = var.tenant_id
  object_id    = each.value.object_id

  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions     = each.value.storage_permissions
}

# Private endpoint for the Key Vault if enabled
resource "azurerm_private_endpoint" "key_vault" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.key_vault_name}-pe"
  location            = azurerm_resource_group.key_vault.location
  resource_group_name = azurerm_resource_group.key_vault.name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.key_vault_name}-psc"
    private_connection_resource_id = azurerm_key_vault.main.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.private_dns_zone_ids
  }
}
