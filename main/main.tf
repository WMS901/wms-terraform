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
  name              = "bazzyung"
  ami_id            = "ami-0c02fb55956c7d316"
  instance_type     = "t2.micro"
  public_subnet_id  = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  public_key_path   = "C:/Users/soldesk/Downloads/wms_key.pub"
  key_name          = "wms-key"
  my_ip_cidr        = "180.80.107.4/32"
}