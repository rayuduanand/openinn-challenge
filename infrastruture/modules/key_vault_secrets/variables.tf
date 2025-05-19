variable "key_vault_id" {
  description = "The ID of the Key Vault where secrets will be stored"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace where secrets will be used"
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}

variable "postgres_password" {
  description = "The PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "The Grafana admin password"
  type        = string
  sensitive   = true
}

variable "app_secrets" {
  description = "Map of additional application secrets to store in Key Vault"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
