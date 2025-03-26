resource "helm_release" "alb_controller" {
  name             = "aws-load-balancer-controller"
  namespace        = "ingress"
  create_namespace = true

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.1"

  values = [file("${path.module}/../../modules/helm-chart/infrastructure/alb-ingress/values.yaml")]
  
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
    value = data.terraform_remote_state.vpc.outputs.vpc_id
  }

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
# eks 새성후 진행.
  depends_on = [
    module.eks
  ]
}
