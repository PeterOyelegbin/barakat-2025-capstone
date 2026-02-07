output "cluster_role_arn" {
  description = "EKS cluster role ARN"
  value = aws_iam_role.eks_cluster.arn
}

output "node_role_arn" {
  description = "EKS node role ARN"
  value = aws_iam_role.eks_node.arn
}

output "lambda_role_arn" {
  description = "Lambda node role ARN"
  value = aws_iam_role.lambda.arn
}

output "iam_user_arn" {
  description = "IAM user ARN"
  value = aws_iam_user.dev_user.arn
}

output "iam_user_name" {
  description = "IAM user name"
  value = aws_iam_user.dev_user.name
}

output "console_password" {
  value     = aws_iam_user_login_profile.console_access.password
  sensitive = true
}

output "eks_cluster_policy" {
  description = "EKS cluster policy"
  value       = aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
}

output "eks_node_policy" {
  description = "EKS node policy"
  value       = aws_iam_role_policy_attachment.eks_node
}
