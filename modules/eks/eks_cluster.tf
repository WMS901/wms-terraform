resource "aws_eks_cluster" "tfer--wms-002D-cluster" {
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = "true"
  }

  bootstrap_self_managed_addons = "false"

  compute_config {
    enabled       = "true"
    node_pools    = ["general-purpose", "system"]
    node_role_arn = "arn:aws:iam::816069155414:role/eksNodeRole"
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = "true"
    }

    ip_family         = "ipv4"
    service_ipv4_cidr = "172.20.0.0/16"
  }

  name     = "wms-cluster"
  role_arn = "arn:aws:iam::816069155414:role/eksClusterRole"

  storage_config {
    block_storage {
      enabled = "true"
    }
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  version = "1.31"

  vpc_config {
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = ["sg-05cd3c93a52d70ac8"]
    subnet_ids              = ["subnet-00f9e093c20d62268", "subnet-07b5a439dcdc244c3"]
  }

  zonal_shift_config {
    enabled = "false"
  }
}
