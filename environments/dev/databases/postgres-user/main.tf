provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36.0"
    }
  }
}

provider "kubernetes" {
  config_path = "C:/Users/soldesk/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "C:/Users/soldesk/.kube/config"
  }
}

data "aws_instances" "eks_nodes" {
  filter {
    name   = "tag:Name"
    values = ["wms-node-group"]
  }
}

data "aws_instance" "selected" {
  instance_id = element(data.aws_instances.eks_nodes.ids, 0)
}

resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].name
    ]
  }
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type = "gp3"
  }
}

module "ebs" {
  source            = "../../../../modules/ebs"
  name              = "postgres-user-ebs"
  availability_zone = data.aws_instance.selected.availability_zone
  size              = 10
  volume_type       = "gp3"
  encrypted         = true
}

resource "kubernetes_persistent_volume" "postgres_user_pv" {
  metadata {
    name = "postgres-user-pv"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }

    access_modes                         = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy    = "Retain"
    storage_class_name                  = "gp3" # Important for manual binding

    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = module.ebs.volume_id
        fs_type   = "ext4"
      }
    }

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "topology.kubernetes.io/zone"
            operator = "In"
            values   = [data.aws_instance.selected.availability_zone]
          }
        }
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
        storage = "10Gi"
      }
    }

    volume_name = kubernetes_persistent_volume.postgres_user_pv.metadata[0].name
  }
}

module "postgres-user" {
  source           = "../../../../modules/helm"
  release_name     = "postgres-user"
  namespace        = "postgres"
  create_namespace = false

  repository     = "https://wms901.github.io/aws-helm-charts/databases"
  chart          = "postgres-user"
  chart_version  = "1.0.0"

  depends_on = [
    kubernetes_persistent_volume_claim.postgres_user_pvc
  ]
}