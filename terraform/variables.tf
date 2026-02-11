variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "resource_tag" {
  description = "Resouces tag name"
  type        = string
}

# VPC variables defination
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
}

# EKS variables defination
variable "node_group_name" {
  description = "EKS node group name"
  type        = string
}

variable "instance_type" {
  description = "EKS instance type"
  type        = string
  default     = "t3.micro"
}

variable "desired_size" {
  description = "Desired size for the EKS node"
  type        = number
}

variable "max_size" {
  description = "Maximum size for the EKS node"
  type        = number
}

variable "min_size" {
  description = "Minimum size for the EKS node"
  type        = number
}

# IAM user variables defination
variable "iam_user" {
  description = "IAM user name"
  type        = string
}

# S3 Bucket variables defination
variable "bucket_name" {
  description = "Bucket name"
  type        = string
}

# Lambda variables defination
variable "lambda_func_name" {
  description = "Lambda function name"
  type        = string
}
