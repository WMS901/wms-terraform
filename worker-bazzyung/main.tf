provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../main/terraform.tfstate"
  }
}

module "bastion" {
  source            = "../modules/bastion"
  name              = "bazzyung"
  ami_id            = "ami-08b5b3a93ed654d19"
  instance_type     = "t2.micro"
  public_subnet_id  = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  public_key_path   = "C:/Users/soldesk/Downloads/wms_key.pub"
  key_name          = "wms-key"
  my_ip_cidr        = "180.80.107.4/32"
}

module "eks" {
  source  = "../modules/eks"

  cluster_name    = "bazzyung-wms-cluster"
  cluster_version = "1.31"

  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_eks_subnet_ids
  key_name           = "wms-key"
  bastion_sg_id      = module.bastion.bastion_sg_id  # ✅ 추가하면 bastion ↔ node 연결 가능

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