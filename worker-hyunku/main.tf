provider "aws" {
  region = "us-east-1"
}

##########################
# ✅ 기존 VPC 및 Subnet 조회
##########################

# data "aws_vpc" "selected" {
#   id = "vpc-0fc2f39a043de2120"
# }

# data "aws_subnet" "public" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.selected.id]
#   }

#   filter {
#     name   = "tag:Name"
#     values = ["wms-public-subnet-1"]
#   }
# }

# data "aws_subnets" "private" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.selected.id]
#   }

#   filter {
#     name   = "tag:Name"
#     values = [
#       "wms-private-eks-subnet-1",
#       "wms-private-eks-subnet-2"
#     ]
#   }
# }

module "vpc" {
  source    = "../modules/vpc"
  name      = "hyunku"
  vpc_cidr  = "10.0.0.0/16"
  azs       = ["us-east-1a", "us-east-1b"]
}

module "bastion" {
  source            = "../modules/bastion"
  name              = "hyunku"
  ami_id            = "ami-08b5b3a93ed654d19"
  instance_type     = "t2.micro"
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  vpc_id            = module.vpc.vpc_id
  my_ip_cidr        = "180.80.107.4/32"
}

module "eks" {
  source  = "../modules/eks"
  cluster_name    = "hyunku-cluster"
  cluster_version = "1.31"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_eks_subnet_ids
  key_name           = "wms_key"
  bastion_sg_id      = module.bastion.bastion_sg_id

  enable_cluster_creator_admin_permissions = false

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
}

resource "aws_security_group_rule" "allow_bastion_to_eks_control_plane" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_primary_security_group_id
  source_security_group_id = module.bastion.bastion_sg_id
  description              = "Allow Bastion to access EKS API"
}