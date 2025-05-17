resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = var.prometheus_chart_version
  timeout    = 600

  values = [
    file("${path.module}/values/prometheus-values.yaml"),
    var.prometheus_additional_values
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = var.loki_chart_version
  timeout    = 300

  values = [
    file("${path.module}/values/loki-values.yaml"),
    var.loki_additional_values
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = var.grafana_chart_version
  timeout    = 300

  values = [
    file("${path.module}/values/grafana-values.yaml"),
    var.grafana_additional_values
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.prometheus,
    helm_release.loki
  ]
}
