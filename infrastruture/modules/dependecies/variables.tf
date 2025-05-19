variable "namespace" {
  description = "Kubernetes namespace to deploy monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "prometheus_chart_version" {
  description = "Version of the Prometheus Helm chart to deploy"
  type        = string
  default     = "45.7.1"  
}

variable "loki_chart_version" {
  description = "Version of the Loki Helm chart to deploy"
  type        = string
  default     = "2.9.10"  
}

variable "grafana_chart_version" {
  description = "Version of the Grafana Helm chart to deploy"
  type        = string
  default     = "6.52.1"  
}

variable "postgres_exporter_chart_version" {
  description = "Version of the Postgres Exporter Helm chart to deploy"
  type        = string
  default     = "1.1.0"
}

variable "prometheus_additional_values" {
  description = "Additional Helm values for Prometheus"
  type        = string
  default     = ""
}

variable "loki_additional_values" {
  description = "Additional Helm values for Loki"
  type        = string
  default     = ""
}

variable "grafana_additional_values" {
  description = "Additional Helm values for Grafana"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the AKS cluster"
  type        = string
}

variable "enable_ingress" {
  description = "Enable ingress for monitoring components"
  type        = bool
  default     = true
}

variable "ingress_domain" {
  description = "Domain for ingress resources"
  type        = string
  default     = "example.com"
}

variable "storage_class_name" {
  description = "Storage class to use for persistent volumes"
  type        = string
  default     = "managed-premium"
}
