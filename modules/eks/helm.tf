provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "helm_release" "alb_controller" {
  name             = "aws-load-balancer-controller"
  namespace        = "ingress"
  create_namespace = true

  chart  = "${path.module}/../../modules/helm-chart/infrastructure/ingress-control"
  values = [file("${path.module}/../../modules/helm-chart/infrastructure/ingress-control/values.yaml")]

  # 동적으로 변할 수 있는 값은 set{}으로 주입
  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  # 필수 기본 값
  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
  }
}
