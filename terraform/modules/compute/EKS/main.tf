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
