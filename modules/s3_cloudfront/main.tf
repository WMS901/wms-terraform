data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "sol-wms-terraform-states"
    key    = "alb/terraform.tfstate"
    region = "us-east-1"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "S3 브틱 이름"
  default     = "frontend-page"
}

data "aws_s3_bucket" "existing" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket" "this" {
  count         = can(data.aws_s3_bucket.existing.id) ? 0 : 1
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  count  = length(aws_s3_bucket.this) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "public" {
  count  = length(aws_s3_bucket.this) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  count  = length(aws_s3_bucket.this) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = ["s3:GetObject"],
      Resource  = "${aws_s3_bucket.this[0].arn}/*"
    }]
  })
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "no-override"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = length(aws_s3_bucket.this) > 0 ? aws_s3_bucket.this[0].bucket_regional_domain_name : data.aws_s3_bucket.existing.bucket_regional_domain_name
    origin_id   = var.bucket_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  origin {
    domain_name = data.terraform_remote_state.alb.outputs.alb_dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = var.bucket_name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "DELETE", "PATCH"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Content-Type"]

      cookies {
        forward = "all"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = var.bucket_name
  }
}

resource "null_resource" "upload_static_files" {
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "aws s3 sync '${path.module}/static' s3://${var.bucket_name} --exact-timestamps"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    aws_s3_bucket.this,
    aws_s3_bucket_ownership_controls.ownership
  ]
}

output "s3_bucket_name" {
  value = length(aws_s3_bucket.this) > 0 ? aws_s3_bucket.this[0].bucket : data.aws_s3_bucket.existing.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_origin_alb_dns" {
  value = data.terraform_remote_state.alb.outputs.alb_dns_name
}