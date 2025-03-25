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
  source             = "../modules/bastion"
  name               = "bazzyung"
  ami_id             = "ami-08b5b3a93ed654d19"
  instance_type      = "t2.micro"
  public_subnet_id   = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  key_name           = "wms-key"
  public_key_path    = "C:/Users/soldesk/Downloads/wms_key.pub"  # 로컬 경로
  my_ip_cidr         = "180.80.107.4/32"
}

module "eks" {
  source              = "../modules/eks"
  cluster_name        = "my-wms-cluster"
  cluster_version     = "1.31"
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids  = data.terraform_remote_state.vpc.outputs.private_eks_subnet_ids
  key_name            = "wms-key"
  bastion_sg_id       = module.bastion.bastion_sg_id
}
