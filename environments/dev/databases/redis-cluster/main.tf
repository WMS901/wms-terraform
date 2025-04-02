provider "kubernetes" {
  config_path = "C:/Users/soldesk/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "C:/Users/soldesk/.kube/config"
  }
}

# resource "kubernetes_storage_class" "gp3" {
#   metadata {
#     name = "gp3"
#     annotations = {
#       "storageclass.kubernetes.io/is-default-class" = "true"
#     }
#   }

#   storage_provisioner = "ebs.csi.aws.com"

#   reclaim_policy      = "Delete"
#   volume_binding_mode = "WaitForFirstConsumer"

#   parameters = {
#     type = "gp3"
#   }
# }


resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }

  lifecycle {
    ignore_changes = [metadata[0].name]
  }
}

resource "kubernetes_secret" "redis_password" {
  metadata {
    name      = "redis-cluster"
    namespace = "redis"
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "meta.helm.sh/release-name"      = "redis-cluster"
      "meta.helm.sh/release-namespace" = "redis"
    }
  }

  type = "Opaque"

  data = {
    redis-password = "soldesk"
  }
}

module "redis-cluster" {
  source            = "../../../../modules/helm"
  release_name      = "redis-cluster"
  namespace         = kubernetes_namespace.redis.metadata[0].name
  repository        = "https://charts.bitnami.com/bitnami"
  chart             = "redis-cluster"
  chart_version     = "9.0.1"
  create_namespace  = false

  values = [
    file("${path.module}/values/redis-cluster.yaml")
  ]

  depends_on = [
    kubernetes_namespace.redis,
    kubernetes_secret.redis_password
  ]
}
