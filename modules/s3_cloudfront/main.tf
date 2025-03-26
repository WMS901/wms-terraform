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
  description = "S3 버킷 이름"
  default     = "frontend-page"
}

# S3 버킷 생성
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true
}

# ✅ 최신 방식: 소유권 설정 (ObjectWriter → ACL 사용 가능하게 함)
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

# 퍼블릭 접근 정책 차단 해제
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 퍼블릭 Read 정책 허용
resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = ["s3:GetObject"],
      Resource  = "${aws_s3_bucket.this.arn}/*"
    }]
  })
}

# CloudFront 오리진 액세스 컨트롤
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "no-override"
  signing_protocol                  = "sigv4"
}

# CloudFront 배포
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id                = var.bucket_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = var.bucket_name
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
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

#  정적 파일 자동 업로드
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

# 출력값
output "s3_bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
