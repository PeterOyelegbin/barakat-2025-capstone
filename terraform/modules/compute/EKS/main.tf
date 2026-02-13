resource "aws_eks_cluster" "eks" {
  name     = "${var.project_name}-cluster"
  role_arn = var.cluster_role_arn
  version  = "1.34"

  access_config {
    authentication_mode = "API"
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  depends_on = [
    var.eks_cluster_policy
  ]

  tags = {
    Project = var.resource_tag
  }
}

# Managed Node Group
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.instance_type]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  depends_on = [
    var.eks_node_policy
  ]

  tags = {
    Project = var.resource_tag
  }
}

# Add CloudWatch Observability Add-on to EKS cluster
resource "aws_eks_addon" "cw_observability" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "amazon-cloudwatch-observability"
  service_account_role_arn    = var.cw_observability_arn
  resolve_conflicts_on_create = "OVERWRITE"
}


# Grant EKS admin role full Kubernetes Admin in EKS
resource "aws_eks_access_entry" "eks_admin" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = var.eks_admin_arn
  type          = "STANDARD"
}

# Attach AmazonEKSClusterAdminPolicy to EKS admin role for full Kubernetes Admin access
resource "aws_eks_access_policy_association" "eks_admin" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = var.eks_admin_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}


# Add Dev IAM user to EKS cluster access
resource "aws_eks_access_entry" "dev_user" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = var.dev_user_arn
  type          = "STANDARD"
}

# Attach AmazonEKSViewPolicy to Dev IAM user for read-only access to EKS cluster
resource "aws_eks_access_policy_association" "dev_user_view" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = var.dev_user_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }
}

# Get the OIDC thumbprint for the EKS cluster to create an IAM OIDC provider for IRSA
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# Create an IAM OIDC provider for the EKS cluster to enable IRSA (IAM Roles for Service Accounts)
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
