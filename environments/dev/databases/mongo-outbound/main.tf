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

resource "kubernetes_namespace" "mongo" {
  metadata {
    name = "mongo"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

module "ebs" {
  source            = "../../../../modules/ebs"
  name              = "mongo-outbound-ebs"
  availability_zone = data.aws_instance.selected.availability_zone
  size              = 10
  volume_type       = "gp3"
  encrypted         = true
}

resource "kubernetes_persistent_volume" "mongo_outbound_pv" {
  metadata {
    name = "mongo-outbound-pv"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }

    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name                  = "gp3"

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

resource "kubernetes_persistent_volume_claim" "mongo_outbound_pvc" {
  metadata {
    name      = "mongo-outbound-pvc"
    namespace = "mongo"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "10Gi"
      }
    }

    volume_name = kubernetes_persistent_volume.mongo_outbound_pv.metadata[0].name
  }
}

module "mongo-outbound" {
  source = "../../../../modules/helm"

  release_name = "mongo-outbound"
  namespace    = "mongo"
  create_namespace = false

  repository   = "https://wms901.github.io/aws-helm-charts/databases"
  chart        = "mongo-outbound"
  chart_version = "1.0.0"

  depends_on = [
    kubernetes_persistent_volume_claim.mongo_outbound_pvc
  ]
}