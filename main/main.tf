provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source    = "../modules/vpc"
  name      = "wms"
  vpc_cidr  = "10.0.0.0/16"
  azs       = ["us-east-1a", "us-east-1b"]
}

module "bastion" {
  source            = "../modules/bastion"
  name              = "wms"
  ami_id            = "ami-08b5b3a93ed654d19"
  instance_type     = "t2.micro"
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  vpc_id            = module.vpc.vpc_id
  public_key_path   = "C:/Users/soldesk/Downloads/wms_key.pub"
  key_name          = "wms-key"
  my_ip_cidr        = "180.80.107.4/32"
}

module "eks" {
  source  = "../modules/eks"

  cluster_name    = "wms-cluster"
  cluster_version = "1.31"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_eks_subnet_ids
  key_name           = "wms-key"

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
            type = "cluster" # ✅ 필수! 기본값으로 클러스터 전체 권한
          }
        }
      ]
    }
  }
}
