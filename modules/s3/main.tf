resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.this.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

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
