resource "helm_release" "this" {
  name             = var.release_name
  namespace        = var.namespace
  create_namespace = true

  repository = var.repository
  chart      = var.chart
  version    = var.chart_version

  values = var.values
}
