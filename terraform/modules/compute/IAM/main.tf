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
        Project = var.resource_tag
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
        Project = var.resource_tag
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


# Create IAM role for EKS admin access
data "aws_caller_identity" "current" {}


resource "aws_iam_role" "eks_admin" {
    name = "${var.project_name}-eks-admin-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    AWS = data.aws_caller_identity.current.arn
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Project = var.resource_tag
    }
}

resource "aws_iam_policy" "allow_assume_eks_admin" {
    name = "AllowAssumeEKSAdminRole"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect   = "Allow"
                Action   = "sts:AssumeRole"
                Resource = aws_iam_role.eks_admin.arn
            }
        ]
    })
}

resource "aws_iam_user_policy_attachment" "attach_assume_policy" {
    # user       = "taiwo"
    user       = "automation"
    policy_arn = aws_iam_policy.allow_assume_eks_admin.arn
}


# Create IAM policy for EKS CloudWatch Observability Add-on
data "aws_iam_policy_document" "cw_assume_role" {
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"]

        principals {
            type        = "Federated"
            identifiers = [var.oidc_provider_arn]
        }

        condition {
            test     = "StringEquals"
            variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
            values   = ["system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"]
        }
    }
}

# Create IAM role for CloudWatch Observability Add-on
resource "aws_iam_role" "cw_observability" {
    name               = "${var.project_name}-cw-observability"
    assume_role_policy = data.aws_iam_policy_document.cw_assume_role.json
}

# Attach CloudWatchAgentServerPolicy to CloudWatch IAM role
resource "aws_iam_role_policy_attachment" "cw_policy_attach" {
    role       = aws_iam_role.cw_observability.name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


# IAM role for lambda
resource "aws_iam_role" "lambda" {
    name = "${var.project_name}-lambda-role"

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

# Allow logging to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# Create IAM User
resource "aws_iam_user" "dev_user" {
    name = var.iam_user

    tags = {
        Project = var.resource_tag
    }
}

# Create login profile for console access
resource "aws_iam_user_login_profile" "console_access" {
    user                    = aws_iam_user.dev_user.name
    password_reset_required = false
}

# Create IAM policy for S3 PutObject and attach to user
resource "aws_iam_policy" "s3_put_policy" {
    name        = "${aws_iam_user.dev_user.name}-s3-putobject"
    description = "Allow PutObject to specific bucket"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect = "Allow"
            Action = [
                "s3:PutObject"
            ]
            Resource = "${var.bucket_arn}/*"
        }
        ]
    })
}

# Attach S3 PutObject policy to IAM user
resource "aws_iam_user_policy_attachment" "s3_putobject" {
  user       = aws_iam_user.dev_user.name
  policy_arn = aws_iam_policy.s3_put_policy.arn
}

# Attach ReadOnlyAccess Policy
resource "aws_iam_user_policy_attachment" "readonly" {
    user       = aws_iam_user.dev_user.name
    policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Create Access Key
resource "aws_iam_access_key" "iam_key" {
    user = aws_iam_user.dev_user.name
}

# Save credentials to file
resource "local_sensitive_file" "iam_credentials" {
    filename = "${path.root}/bedrock-dev-credentials.txt"
    content  = <<EOT
IAM_Console_URL: https://console.aws.amazon.com/iam/home?region=${var.region}#/users/${aws_iam_user.dev_user.name}
IAM_User: ${aws_iam_user.dev_user.name}
IAM_Password: ${aws_iam_user_login_profile.console_access.password}
AWS_ACCESS_KEY_ID=${aws_iam_access_key.iam_key.id}
AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.iam_key.secret}
EOT
}
