terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Get AWS account ID
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "tf_state" {
  bucket = "${var.project_name}-${data.aws_caller_identity.current.account_id}-tfstate"

  lifecycle {
    prevent_destroy = false #set to false for testing purposes, change to true in production
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Disabled" #set to Enabled in production
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
