output "cluster_endpoint" {
  description = "The EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "The EKS cluster name"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region the infrastructure was deployed"
  value       = var.region
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "assets_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
}
