terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
  }

  # backend "s3" {
  #   bucket         = "bedrock-154517339571-tfstate"
  #   key            = "prod/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   use_lockfile   = true
  # }

  required_version = ">= 1.10"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/networking/vpc"

  project_name         = var.project_name
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "iam" {
  source = "./modules/compute/IAM"

  project_name      = var.project_name
  iam_user          = var.iam_user
  bucket_arn        = module.s3.bucket_arn
  region            = var.region
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

module "eks" {
  source = "./modules/compute/EKS"

  project_name         = var.project_name
  cluster_role_arn     = module.iam.cluster_role_arn
  eks_cluster_policy   = module.iam.eks_cluster_policy
  private_subnet_ids   = module.vpc.private_subnet_ids
  node_group_name      = var.node_group_name
  node_role_arn        = module.iam.node_role_arn
  eks_node_policy      = module.iam.eks_node_policy
  eks_admin_arn        = module.iam.eks_admin_arn
  cw_observability_arn = module.iam.cw_observability_arn
  instance_type        = var.instance_type
  desired_size         = var.desired_size
  max_size             = var.max_size
  min_size             = var.min_size
  dev_user_arn         = module.iam.iam_user_arn
}

module "s3" {
  source = "./modules/storage/s3-bucket"

  bucket_name = var.bucket_name
}

module "lambda" {
  source = "./modules/compute/lambda"

  lambda_func_name = var.lambda_func_name
  lambda_role_arn  = module.iam.lambda_role_arn
  bucket_arn       = module.s3.bucket_arn
  bucket_id        = module.s3.bucket_id
}
