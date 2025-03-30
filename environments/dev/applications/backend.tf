terraform {
  backend "s3" {
    bucket         = "sol-wms-terraform-states"
    key            = "applications/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
  }
}
