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
