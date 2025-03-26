terraform {
  backend "s3" {
    bucket         = "sol-wms-terraform-states"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
