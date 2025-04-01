provider "kubernetes" {
  config_path = "C:/Users/soldesk/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "C:/Users/soldesk/.kube/config"
  }
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}

# data "terraform_remote_state" "eks" {
#   backend = "s3"
#   config = {
#     bucket = "sol-wms-terraform-states"
#     key    = "eks/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

# data "terraform_remote_state" "alb" {
#   backend = "s3"
#   config = {
#     bucket = "sol-wms-terraform-states"
#     key    = "alb/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

# resource "aws_security_group_rule" "alb_to_nodes_health_check" {
#   type                     = "ingress"
#   from_port                = 1040
#   to_port                  = 1051
#   protocol                 = "tcp"
  
#   security_group_id        = data.terraform_remote_state.eks.outputs.worker_node_sg_id
#   source_security_group_id = data.terraform_remote_state.alb.outputs.alb_sg_id

#   description              = "Allow ALB health checks to EKS nodes (for ports 1040-1051)"
# }

module "kafka" {
  source = "../../../modules/helm"

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
  source = "../../../modules/helm"

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

resource "null_resource" "wait_for_argocd_crd" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for Argo CD CRDs to be ready..."
      for i in {1..30}; do
        kubectl get crd applications.argoproj.io && break
        echo "Waiting..."
        sleep 5
      done
    EOT
  }

  depends_on = [module.argocd]
}

resource "kubernetes_namespace" "wms" {
  metadata {
    name = "wms"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [metadata[0].labels]
  }
}

resource "kubectl_manifest" "inbound_app" {
  yaml_body  = file("${path.module}/argocd-apps/inbound-application.yaml")
  depends_on = [null_resource.wait_for_argocd_crd]
}

resource "kubectl_manifest" "inventory_app" {
  yaml_body  = file("${path.module}/argocd-apps/inventory-application.yaml")
  depends_on = [null_resource.wait_for_argocd_crd]
}

resource "kubectl_manifest" "outbound_app" {
  yaml_body  = file("${path.module}/argocd-apps/outbound-application.yaml")
  depends_on = [null_resource.wait_for_argocd_crd]
}