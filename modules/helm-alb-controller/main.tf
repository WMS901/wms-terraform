resource "helm_release" "alb_controller" {
  name             = var.release_name
  namespace        = var.namespace
  chart            = var.helm_chart_path
  create_namespace = false

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

set {
  name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  value = var.irsa_role_arn
}

}
