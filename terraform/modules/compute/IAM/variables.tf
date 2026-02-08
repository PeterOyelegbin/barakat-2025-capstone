variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "iam_user" {
  description = "IAM user name"
  type        = string
}

variable "bucket_arn" {
  description = "S3 bucket ARN"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OpenID Connect provider ARN for EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "OpenID Connect provider URL for EKS cluster"
  type        = string
}
