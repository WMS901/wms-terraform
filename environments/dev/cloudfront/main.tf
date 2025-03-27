data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "sol-wms-terraform-states"
    key    = "s3/terraform.tfstate"    # ⚠️ 정확해야 함!
    region = "us-east-1"
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "sol-wms-terraform-states"
    key    = "alb/terraform.tfstate"
    region = "us-east-1"
  }
}

module "cloudfront" {
  source             = "../../../modules/cloudfront"
  bucket_name        = data.terraform_remote_state.s3.outputs["s3_bucket_name"]
  bucket_domain_name = data.terraform_remote_state.s3.outputs["s3_bucket_domain_name"]
  alb_dns_name       = data.terraform_remote_state.alb.outputs["alb_dns_name"]
}
