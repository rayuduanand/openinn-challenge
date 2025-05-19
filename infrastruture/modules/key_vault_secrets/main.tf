resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = var.postgres_password
  key_vault_id = var.key_vault_id

  content_type = "text/plain"
  tags         = var.tags
}

resource "azurerm_key_vault_secret" "grafana_admin_password" {
  name         = "grafana-admin-password"
  value        = var.grafana_admin_password
  key_vault_id = var.key_vault_id

  content_type = "text/plain"
  tags         = var.tags
}

# Add additional application secrets as needed
resource "azurerm_key_vault_secret" "app_secrets" {
  for_each = var.app_secrets

  name         = each.key
  value        = each.value
  key_vault_id = var.key_vault_id

  content_type = "text/plain"
  tags         = var.tags
}

# Create a user-assigned managed identity for AKS to access Key Vault
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "id-aks-keyvault-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Assign Key Vault Secrets User role to the AKS identity
resource "azurerm_role_assignment" "aks_identity_kvs_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Create a Kubernetes secret provider class for CSI driver
resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "azure-kvs-provider"
      namespace = var.namespace
    }
    spec = {
      provider = "azure"
      parameters = {
        usePodIdentity       = "false"
        useVMManagedIdentity = "true"
        userAssignedIdentityID = azurerm_user_assigned_identity.aks_identity.client_id
        keyvaultName         = element(split("/", var.key_vault_id), length(split("/", var.key_vault_id)) - 1)
        cloudName            = "AzurePublicCloud"
        objects              = jsonencode([
          {
            objectName = "postgres-password"
            objectType = "secret"
            objectVersion = ""
          },
          {
            objectName = "grafana-admin-password"
            objectType = "secret"
            objectVersion = ""
          }
        ])
        tenantId = var.tenant_id
      }
      secretObjects = [
        {
          secretName = "db-credentials"
          type       = "Opaque"
          data = [
            {
              objectName = "postgres-password"
              key        = "password"
            }
          ]
        },
        {
          secretName = "grafana-credentials"
          type       = "Opaque"
          data = [
            {
              objectName = "grafana-admin-password"
              key        = "admin-password"
            }
          ]
        }
      ]
    }
  }

  depends_on = [
    azurerm_role_assignment.aks_identity_kvs_user
  ]
}
