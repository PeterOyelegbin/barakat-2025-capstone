# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster" {
    name = "${var.project_name}-eks-cluster-role"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "sts:AssumeRole",
                    "sts:TagSession"
                ]
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            },
        ]
    })

    tags = {
        Project = "Bedrock"
    }
}

# Attach policy to EKS cluster IAM role
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
    role       = aws_iam_role.eks_cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# Create IAM role for EKS node
resource "aws_iam_role" "eks_node" {
    name = "${var.project_name}-eks-node-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = { 
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Project = "Bedrock"
    }
}

# Attach policy to EKS node IAM role
resource "aws_iam_role_policy_attachment" "eks_node" {
    for_each = toset([
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    ])

    role       = aws_iam_role.eks_node.name
    policy_arn = each.value
}


# IAM role for lambda
resource "aws_iam_role" "lambda" {
    name = "bedrock-asset-processor-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
}

# Allow logging to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Allow Lambda to read from S3
resource "aws_iam_policy" "lambda_s3_read" {
    name = "lambda-s3-read-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = ["s3:GetObject"]
                Resource = "${var.bucket_arn}/*"
            }
        ]
    })
}

# Attach lambda read policy to lambda role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_s3_read.arn
}


# Create IAM User
resource "aws_iam_user" "iam_user" {
    name = var.iam_user

    tags = {
        Project = "Bedrock"
    }
}

# Attach ReadOnlyAccess Policy
resource "aws_iam_user_policy_attachment" "readonly" {
    user       = aws_iam_user.iam_user.name
    policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Create Access Key
resource "aws_iam_access_key" "iam_key" {
    user = aws_iam_user.iam_user.name
}

# Save credentials to file
resource "local_sensitive_file" "iam_credentials" {
    filename = "${path.root}/bedrock-dev-view-credentials.txt"
    content  = <<EOT
AWS_ACCESS_KEY_ID=${aws_iam_access_key.iam_key.id}
AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.iam_key.secret}
EOT
}
