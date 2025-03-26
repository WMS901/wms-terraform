variable "region" {
  default = "us-east-1"
}

variable "bucket_name" {
  default = "sol-wms-terraform-states"
}

variable "lock_table_name" {
  default = "terraform-lock"
}

variable "environment" {
  default = "dev"
}
