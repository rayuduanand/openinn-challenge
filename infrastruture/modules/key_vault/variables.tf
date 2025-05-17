variable "resource_group_name" {
  description = "Name of the resource group for the Key Vault"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "enabled_for_disk_encryption" {
  description = "Enable Key Vault for disk encryption"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days for Key Vault"
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = true
}

variable "sku_name" {
  description = "SKU name for Key Vault"
  type        = string
  default     = "standard"
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization for Key Vault"
  type        = bool
  default     = false
}

variable "network_acls_default_action" {
  description = "Default action for network ACLs"
  type        = string
  default     = "Deny"
}

variable "network_acls_bypass" {
  description = "Bypass for network ACLs"
  type        = string
  default     = "AzureServices"
}

variable "network_acls_ip_rules" {
  description = "IP rules for network ACLs"
  type        = list(string)
  default     = []
}

variable "network_acls_subnet_ids" {
  description = "Subnet IDs for network ACLs"
  type        = list(string)
  default     = []
}

variable "access_policies" {
  description = "Access policies for Key Vault"
  type = map(object({
    object_id               = string
    key_permissions         = list(string)
    secret_permissions      = list(string)
    certificate_permissions = list(string)
    storage_permissions     = list(string)
  }))
  default = {}
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for Key Vault"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs for private endpoint"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
