provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "../../../modules/vpc"
  name    = "wms"
  vpc_cidr = "10.0.0.0/16"
  azs     = ["us-east-1a", "us-east-1b"]
}
