variable "resource_group_name" {
  description = "Name of the resource group for the Log Analytics workspace"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "sku" {
  description = "SKU of the Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Data retention period in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
