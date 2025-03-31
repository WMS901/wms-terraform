data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "sol-wms-terraform-states"
    key    = "s3/terraform.tfstate"    # ⚠️ 정확해야 함!
    region = "us-east-1"
  }
}

module "cloudfront" {
  source             = "../../../modules/cloudfront"
  bucket_name        = data.terraform_remote_state.s3.outputs["s3_bucket_name"]
  bucket_domain_name = data.terraform_remote_state.s3.outputs["s3_bucket_domain_name"]
  alb_dns_name       = "api.solcloud.store"  # ← 고정 도메인으로 대체
  acm_certificate_arn = "arn:aws:acm:us-east-1:816069155414:certificate/351928dd-5494-423c-bd06-36b852d30c57"
  hosted_zone_id  = var.hosted_zone_id
}
