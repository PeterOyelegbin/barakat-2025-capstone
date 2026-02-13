output "cluster_name" {
  description = "The EKS cluster name"
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  description = "The EKS cluster endpoint"
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_ca" {
  description = "The EKS certificate authority"
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "The EKS OIDC provider ARN"
  value = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "The EKS OIDC provider URL"
  value = aws_iam_openid_connect_provider.eks.url
}
