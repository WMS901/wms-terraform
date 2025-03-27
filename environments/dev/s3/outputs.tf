# /environments/dev/s3/outputs.tf
output "s3_bucket_name" {
  value = module.s3.s3_bucket_name
}

output "s3_bucket_domain_name" {
  value = module.s3.s3_bucket_domain_name
}
