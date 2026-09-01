data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "imageforge" {
  bucket = "${local.project_name}-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-bucket"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "imageforge" {
  bucket = aws_s3_bucket.imageforge.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "imageforge" {
  bucket = aws_s3_bucket.imageforge.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "imageforge" {
  bucket = aws_s3_bucket.imageforge.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}