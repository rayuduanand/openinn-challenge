output "velero_storage_account_name" {
  description = "The name of the storage account used for Velero backups"
  value       = azurerm_storage_account.velero.name
}

output "velero_backup_container_name" {
  description = "The name of the storage container for Velero backups"
  value       = azurerm_storage_container.velero_backups.name
}

output "velero_identity_id" {
  description = "The ID of the user-assigned managed identity for Velero"
  value       = azurerm_user_assigned_identity.velero.id
}

output "velero_identity_client_id" {
  description = "The client ID of the user-assigned managed identity for Velero"
  value       = azurerm_user_assigned_identity.velero.client_id
}

output "postgres_backup_container_name" {
  description = "The name of the storage container for PostgreSQL backups"
  value       = var.enable_postgres_backup ? azurerm_storage_container.postgres_backups[0].name : null
}

output "postgres_backup_server_name" {
  description = "The name of the PostgreSQL backup server"
  value       = var.enable_postgres_backup ? azurerm_postgresql_server.postgres_backup[0].name : null
}
