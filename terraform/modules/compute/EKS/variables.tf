variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "EKS cluster ARN"
  type        = string
}

variable "eks_cluster_policy" {
  description = "EKS cluster policy"
  type        = object({})
}

variable "node_role_arn" {
  description = "EKS node ARN"
  type        = string
}

variable "eks_node_policy" {
  description = "EKS node policy"
  type        = object({})
}

variable "node_group_name" {
  description = "Node group name"
  type        = string
}

variable "instance_type" {
  description = "EKS node instance type"
  type        = string
}

variable "desired_size" {
  description = "Desired size for the EKS node group"
  type        = number
}

variable "max_size" {
  description = "Maximum size for the EKS node group"
  type        = number
}

variable "min_size" {
  description = "Minimum size for the EKS node group"
  type        = number
}

variable "dev_user_arn" {
  description = "IAM user ARN for EKS access"
  type        = string
}
