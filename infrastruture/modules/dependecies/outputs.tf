output "grafana_service_name" {
  description = "Name of the Grafana Kubernetes service"
  value       = "grafana"
}

output "prometheus_service_name" {
  description = "Name of the Prometheus Kubernetes service"
  value       = "prometheus-server"
}

output "postgres_exporter_service_name" {
  description = "Name of the Postgres Exporter Kubernetes service"
  value       = "postgres_exporter"
}

output "loki_service_name" {
  description = "Name of the Loki Kubernetes service"
  value       = "loki"
}

output "monitoring_namespace" {
  description = "Namespace where monitoring components are deployed"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_admin_password" {
  description = "Admin password for Grafana"
  value       = helm_release.grafana.name != "" ? "Use kubectl get secret --namespace ${kubernetes_namespace.monitoring.metadata[0].name} grafana -o jsonpath='{.data.admin-password}' | base64 --decode" : ""
  sensitive   = true
}
