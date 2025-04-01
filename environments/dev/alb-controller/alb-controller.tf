provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  config_path = "C:/Users/soldesk/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "C:/Users/soldesk/.kube/config"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "sol-wms-terraform-states"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "sol-wms-terraform-states"
    key    = "eks/terraform.tfstate"  # EKS tfstate key (S3 경로)
    region = "us-east-1"
  }
}

module "irsa_alb" {
  source            = "../../../modules/helm-alb-controller/irsa"
  oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  oidc_provider_url = data.terraform_remote_state.eks.outputs.oidc_provider_url
}

module "alb_controller" {
  source           = "../../../modules/helm-alb-controller"
  helm_chart_path  = "${path.module}/../../../modules/helm-alb-controller/alb-ingress"
  release_name     = "aws-load-balancer-controller"
  namespace        = "kube-system"
  cluster_name     = "wms-cluster"
  region           = "us-east-1"
  vpc_id           = data.terraform_remote_state.vpc.outputs.vpc_id
  irsa_role_arn    = module.irsa_alb.irsa_role_arn
}

