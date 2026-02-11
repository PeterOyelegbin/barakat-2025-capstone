variable "resource_tag" {
  description = "Resouces tag name"
  type        = string
}

variable "lambda_func_name" {
    description = "Lambda function name"
    type = string
}

variable "lambda_role_arn" {
    description = "Lambda role ARN"
    type = string
}

variable "bucket_arn" {
    description = "S3 bucket ARN"
    type = string
}

variable "bucket_id" {
    description = "S3 bucket ID"
    type = string
}
