provider "aws" {
  region = "us-east-1"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" # or use data from terraform_remote_state if in bastion
  }
}

module "ebs" {
  source            = "../../../../modules/ebs"
  name              = "postgres-user-ebs"
  availability_zone = "us-east-1a"
  size              = 20
  volume_type       = "gp3"
  encrypted         = true
}

resource "kubernetes_persistent_volume" "postgres_user_pv" {
  metadata {
    name = "postgres-user-pv"
  }

  spec {
    capacity = {
      storage = "20Gi"
    }

    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = module.ebs.volume_id
        fs_type   = "ext4"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_user_pvc" {
  metadata {
    name      = "postgres-user-pvc"
    namespace = "postgres"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "20Gi"
      }
    }

    volume_name = kubernetes_persistent_volume.postgres_user_pv.metadata[0].name
  }
}

module "postgres-user" {
  source = "../../../../modules/helm"

  release_name = "postgres-user"
  namespace = "postgres"

  repository = "https://charts.bitnami.com/bitnami"
  chart  = "postgresql"
  chart_version = "13.2.15"
  
  values = [
    file("${path.module}/values.yaml")
  ]
}
