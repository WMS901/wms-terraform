terraform {
  backend "s3" {
    bucket         = "sol-wms-terraform-states"
    key            = "alb/terraform.tfstate"         # ALB 상태 저장 경로
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"                # 락 테이블
    encrypt        = true
  }
}
