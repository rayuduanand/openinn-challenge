output "aks_identity_id" {
  description = "The ID of the user-assigned managed identity for AKS"
  value       = azurerm_user_assigned_identity.aks_identity.id
}

output "aks_identity_client_id" {
  description = "The client ID of the user-assigned managed identity for AKS"
  value       = azurerm_user_assigned_identity.aks_identity.client_id
}

output "secret_provider_class_name" {
  description = "The name of the SecretProviderClass for CSI driver"
  value       = kubernetes_manifest.secret_provider_class.manifest.metadata.name
}

output "db_credentials_secret_name" {
  description = "The name of the Kubernetes secret for database credentials"
  value       = "db-credentials"
}

output "grafana_credentials_secret_name" {
  description = "The name of the Kubernetes secret for Grafana credentials"
  value       = "grafana-credentials"
}
