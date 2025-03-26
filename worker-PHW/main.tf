module "vpc" {
  source = "../modules/vpc"
  # 필요한 변수들
}

#module "test_alb" {
#  source       = "../modules/alb"
#   name         = "sol-wms-alb"
#   vpc_id       = module.vpc.vpc_id
#   subnet_ids   = module.vpc.public_subnet_ids
#   target_port  = 30000
  # ✅ security_group_id 안 넣으면 내부에서 자동 생성됨!
#}
