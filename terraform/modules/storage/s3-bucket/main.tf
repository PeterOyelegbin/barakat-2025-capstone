resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = false #set to false for testing purposes, change to true in production
  }

  tags = {
    Project = "Bedrock"
  }
}

resource "aws_s3_bucket_versioning" "bucket_version" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Disabled" #set to Enabled in production
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encrypt" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
