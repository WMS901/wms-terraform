variable "bucket_name" {
  type = string
}

variable "bucket_domain_name" {
  type = string
}

variable "alb_dns_name" {
  type = string
}

variable "acm_certificate_arn" {
  description = "ACM SSL 인증서 ARN"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for solcloud.store"
  type        = string
}