provider "kubernetes" {
  config_path = "C:/Users/soldesk/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "C:/Users/soldesk/.kube/config"
  }
}

# resource "kubernetes_storage_class" "ebs_sc" {
#   metadata {
#     name = "ebs-sc"
#   }

#   storage_provisioner = "ebs.csi.aws.com"

#   parameters = {
#     type = "gp3"
#   }

#   reclaim_policy        = "Retain"
#   volume_binding_mode   = "WaitForFirstConsumer"

#   depends_on = [module.eks]
# }

module "kafka" {
  source = "../../modules/helm"

  release_name = "kafka"
  namespace    = "kafka"
  create_namespace = true

  repository   = "https://charts.bitnami.com/bitnami"
  chart        = "kafka"
  chart_version = "26.6.2"

  values = [
    file("${path.module}/values/kafka-values.yaml")
  ]
}

module "argocd" {
  source = "../../modules/helm"

  release_name  = "argocd"
  namespace     = "argocd"
  create_namespace = true

  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  chart_version = "5.51.6"

  values = [
    file("${path.module}/values/argocd-values.yaml")
  ]
}