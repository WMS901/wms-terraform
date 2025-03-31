data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "sol-wms-terraform-states"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

module "alb" {
  source            = "../../../modules/ALB"
  name              = "sol-wms-alb"
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  target_port       = 30000
  certificate_arn     = "arn:aws:acm:ap-northeast-2:816069155414:certificate/47545023-6feb-4163-b046-0657405b2c40"
  security_group_id = "" # 자동 생성되도록 빈 값 유지
}
