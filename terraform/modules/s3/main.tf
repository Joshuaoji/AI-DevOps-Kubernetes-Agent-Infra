data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  artifacts_bucket_name = "${var.name}-artifacts-${data.aws_caller_identity.current.account_id}"
  logs_bucket_name      = "${var.name}-logs-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "artifacts" {
  count = var.create_artifacts_bucket ? 1 : 0

  bucket        = local.artifacts_bucket_name
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = local.artifacts_bucket_name
  })
}

resource "aws_s3_bucket_versioning" "artifacts" {
  count = var.create_artifacts_bucket ? 1 : 0

  bucket = aws_s3_bucket.artifacts[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  count = var.create_artifacts_bucket ? 1 : 0

  bucket = aws_s3_bucket.artifacts[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  count = var.create_artifacts_bucket ? 1 : 0

  bucket = aws_s3_bucket.artifacts[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "logs" {
  count = var.create_logs_bucket ? 1 : 0

  bucket        = local.logs_bucket_name
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = local.logs_bucket_name
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count = var.create_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  count = var.create_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "logs" {
  count = var.create_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowALBLogDelivery"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs[0].arn}/alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}
