# Storage account for Velero backups
resource "azurerm_storage_account" "velero" {
  name                     = "stvelero${var.environment}${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"  # Geo-redundant storage for disaster recovery
  min_tls_version          = "TLS1_2"
  enable_https_traffic_only = true
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
  }
  tags = var.tags
}

# Container for Velero backups
resource "azurerm_storage_container" "velero_backups" {
  name                  = "velero-backups"
  storage_account_name  = azurerm_storage_account.velero.name
  container_access_type = "private"
}

# Random string for unique storage account name
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# User-assigned managed identity for Velero
resource "azurerm_user_assigned_identity" "velero" {
  name                = "id-velero-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Role assignment for Velero to access storage
resource "azurerm_role_assignment" "velero_storage_contributor" {
  scope                = azurerm_storage_account.velero.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.velero.principal_id
}

# PostgreSQL database backup settings
resource "azurerm_postgresql_server" "postgres_backup" {
  count                        = var.enable_postgres_backup ? 1 : 0
  name                         = "psql-backup-${var.environment}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "11"
  administrator_login          = "psqladmin"
  administrator_login_password = var.postgres_admin_password
  
  sku_name                     = "GP_Gen5_2"
  storage_mb                   = 5120
  backup_retention_days        = 35
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true
  
  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  
  tags = var.tags
}

# Helm release for Velero installation
resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  namespace  = var.velero_namespace
  create_namespace = true
  version    = var.velero_chart_version

  set {
    name  = "credentials.useSecret"
    value = "false"
  }

  set {
    name  = "serviceAccount.server.annotations.azure\\.workload\\.identity/client-id"
    value = azurerm_user_assigned_identity.velero.client_id
  }

  set {
    name  = "configuration.provider"
    value = "azure"
  }

  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = azurerm_storage_container.velero_backups.name
  }

  set {
    name  = "configuration.backupStorageLocation.config.resourceGroup"
    value = var.resource_group_name
  }

  set {
    name  = "configuration.backupStorageLocation.config.storageAccount"
    value = azurerm_storage_account.velero.name
  }

  set {
    name  = "configuration.backupStorageLocation.config.subscriptionId"
    value = var.subscription_id
  }

  set {
    name  = "schedules.daily.schedule"
    value = "0 1 * * *"  # Daily at 1 AM
  }

  set {
    name  = "schedules.daily.template.ttl"
    value = "240h"  # 10 days
  }

  set {
    name  = "schedules.weekly.schedule"
    value = "0 1 * * 0"  # Weekly on Sunday at 1 AM
  }

  set {
    name  = "schedules.weekly.template.ttl"
    value = "1440h"  # 60 days
  }

  set {
    name  = "schedules.monthly.schedule"
    value = "0 1 1 * *"  # Monthly on the 1st at 1 AM
  }

  set {
    name  = "schedules.monthly.template.ttl"
    value = "8760h"  # 365 days
  }

  depends_on = [
    azurerm_role_assignment.velero_storage_contributor
  ]
}

# Kubernetes CronJob for PostgreSQL database backup
resource "kubernetes_cron_job_v1" "postgres_backup" {
  count = var.enable_postgres_backup ? 1 : 0
  
  metadata {
    name      = "postgres-backup"
    namespace = var.postgres_namespace
  }

  spec {
    schedule                      = var.postgres_backup_schedule
    concurrency_policy            = "Forbid"
    successful_jobs_history_limit = 5
    failed_jobs_history_limit     = 3

    job_template {
      metadata {
        name = "postgres-backup"
      }
      spec {
        template {
          metadata {
            name = "postgres-backup"
          }
          spec {
            container {
              name    = "postgres-backup"
              image   = "postgres:13"
              command = ["/bin/sh", "-c"]
              args    = [
                "pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB | gzip > /backups/postgres_$(date +%Y-%m-%d_%H-%M-%S).sql.gz && az storage blob upload --account-name ${azurerm_storage_account.velero.name} --container-name postgres-backups --name postgres_$(date +%Y-%m-%d_%H-%M-%S).sql.gz --file /backups/postgres_$(date +%Y-%m-%d_%H-%M-%S).sql.gz --auth-mode login"
              ]
              
              env {
                name  = "POSTGRES_HOST"
                value = var.postgres_host
              }
              
              env {
                name = "POSTGRES_USER"
                value_from {
                  secret_key_ref {
                    name = var.postgres_credentials_secret
                    key  = "username"
                  }
                }
              }
              
              env {
                name = "POSTGRES_PASSWORD"
                value_from {
                  secret_key_ref {
                    name = var.postgres_credentials_secret
                    key  = "password"
                  }
                }
              }
              
              env {
                name  = "POSTGRES_DB"
                value = var.postgres_database
              }
              
              volume_mount {
                name       = "backup-volume"
                mount_path = "/backups"
              }
            }
            
            volume {
              name = "backup-volume"
              empty_dir {}
            }
            
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}

# Create a storage container for PostgreSQL backups
resource "azurerm_storage_container" "postgres_backups" {
  count                 = var.enable_postgres_backup ? 1 : 0
  name                  = "postgres-backups"
  storage_account_name  = azurerm_storage_account.velero.name
  container_access_type = "private"
}

# Secret rotation using Azure Key Vault rotation policies
resource "azurerm_key_vault_secret_rotation_policy" "postgres_password" {
  count        = var.enable_secret_rotation ? 1 : 0
  key_vault_id = var.key_vault_id
  secret_id    = var.postgres_password_secret_id
  
  rotation_policy {
    automatic {
      time_before_expiry = "P30D"  # 30 days before expiry
    }
    
    expire_after         = "P90D"  # 90 days
    notify_before_expiry = "P29D"  # 29 days before expiry
  }
}

# Kubernetes CronJob for testing restore procedures
resource "kubernetes_cron_job_v1" "test_restore" {
  count = var.enable_restore_testing ? 1 : 0
  
  metadata {
    name      = "test-restore"
    namespace = var.velero_namespace
  }

  spec {
    schedule                      = var.restore_test_schedule
    concurrency_policy            = "Forbid"
    successful_jobs_history_limit = 3
    failed_jobs_history_limit     = 3

    job_template {
      metadata {
        name = "test-restore"
      }
      spec {
        template {
          metadata {
            name = "test-restore"
          }
          spec {
            container {
              name    = "test-restore"
              image   = "bitnami/kubectl:latest"
              command = ["/bin/sh", "-c"]
              args    = [
                "velero restore create --from-backup $(velero backup get --output json | jq -r '.items[0].metadata.name') --namespace-mappings '*:restore-test' && kubectl get all -n restore-test && kubectl delete namespace restore-test"
              ]
            }
            
            service_account_name = "velero"
            restart_policy       = "OnFailure"
          }
        }
      }
    }
  }
  
  depends_on = [
    helm_release.velero
  ]
}
