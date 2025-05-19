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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "velero_namespace" {
  description = "The Kubernetes namespace for Velero"
  type        = string
  default     = "velero"
}

variable "velero_chart_version" {
  description = "The version of the Velero Helm chart"
  type        = string
  default     = "2.32.6"
}

variable "enable_postgres_backup" {
  description = "Whether to enable PostgreSQL backup"
  type        = bool
  default     = true
}

variable "postgres_admin_password" {
  description = "The PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "postgres_host" {
  description = "The PostgreSQL host"
  type        = string
}

variable "postgres_database" {
  description = "The PostgreSQL database name"
  type        = string
  default     = "tictactoe"
}

variable "postgres_credentials_secret" {
  description = "The name of the Kubernetes secret containing PostgreSQL credentials"
  type        = string
}

variable "postgres_namespace" {
  description = "The Kubernetes namespace where PostgreSQL is deployed"
  type        = string
  default     = "default"
}

variable "postgres_backup_schedule" {
  description = "The cron schedule for PostgreSQL backups"
  type        = string
  default     = "0 2 * * *"  # Daily at 2 AM
}

variable "enable_secret_rotation" {
  description = "Whether to enable secret rotation"
  type        = bool
  default     = true
}

variable "key_vault_id" {
  description = "The ID of the Key Vault"
  type        = string
}

variable "postgres_password_secret_id" {
  description = "The ID of the PostgreSQL password secret in Key Vault"
  type        = string
}

variable "enable_restore_testing" {
  description = "Whether to enable automated restore testing"
  type        = bool
  default     = true
}

variable "restore_test_schedule" {
  description = "The cron schedule for restore testing"
  type        = string
  default     = "0 3 * * 0"  # Weekly on Sunday at 3 AM
}
