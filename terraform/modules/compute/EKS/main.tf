resource "aws_eks_cluster" "eks" {
  name     = "${var.project_name}-cluster"
  role_arn = var.cluster_role_arn
  version  = "1.34"

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  depends_on = [
    var.eks_cluster_policy
  ]

  tags = {
    Project = "Bedrock"
  }
}

# Managed Node Group
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  instance_types = [var.instance_type]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  depends_on = [
    var.eks_node_policy
  ]

  tags = {
    Project = "Bedrock"
  }
}

# Add Dev IAM user to EKS cluster access
resource "aws_eks_access_entry" "dev_user" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = var.dev_user_arn
  type          = "STANDARD"

  depends_on = [
    var.dev_user_arn
  ]
}

# Attach AmazonEKSViewPolicy to Dev IAM user for read-only access to EKS cluster
resource "aws_eks_access_policy_association" "dev_user_view" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = var.dev_user_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    var.dev_user_arn
  ]
}
