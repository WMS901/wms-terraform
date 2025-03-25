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
  name              = "hyunku"
  ami_id            = "ami-0c02fb55956c7d316"
  instance_type     = "t2.micro"
  public_subnet_id  = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  public_key_path   = "C:/Users/soldesk/Downloads/wms_key.pub" # 키 경로 바꾸기
  key_name          = "wms-key"
  my_ip_cidr        = "180.80.107.4/32"
}

module "eks" {
  source  = "../modules/eks"

  cluster_name    = "wms-cluster"
  cluster_version = "1.31"

  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_eks_subnet_ids
  key_name           = "wms-key"
}

