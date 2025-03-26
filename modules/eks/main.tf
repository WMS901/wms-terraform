data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "sol-wms-terraform-states"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_security_group" "bastion" {
  name        = "wms-bastion-sg"
  description = "Allow bastion to access EKS nodes"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # ingress 규칙은 EKS 모듈에서 따로 정의하므로 이 SG에서는 생략 가능
  tags = {
    Name = "wms-bastion-sg"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  cluster_endpoint_public_access           = true

  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.vpc.outputs.private_eks_subnet_ids
  control_plane_subnet_ids = data.terraform_remote_state.vpc.outputs.private_eks_subnet_ids

  access_entries = {
    ec2_ssm_admin = {
      principal_arn     = "arn:aws:iam::816069155414:role/EC2-SSM"
      type              = "STANDARD"
      kubernetes_groups = []

      policy_associations = [
        {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      ]
    }
  }

  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    eks-pod-identity-agent = {}
  }

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      key_name       = var.key_name
    }
  }

  node_security_group_additional_rules = {
    allow_bastion_to_nodes = {
      description              = "Allow bastion to connect to EKS nodes (TCP 443)"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = aws_security_group.bastion.id
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
