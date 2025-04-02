module "cloudwatch_monitoring" {
  source = "../../../modules/cloudwatch-monitoring"

  region             = var.region
  cluster_name       = var.cluster_name
  oidc_provider_arn  = var.oidc_provider_arn
  oidc_provider_url  = var.oidc_provider_url
  kubeconfig_path    = var.kubeconfig_path
}
