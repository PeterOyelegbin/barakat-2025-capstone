#!/bin/bash

set -euo pipefail

# Set environment
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ -z "$ACCOUNT_ID" ]; then
  echo "Unable to determine AWS Account ID. Are you logged in with AWS CLI?"
  exit 1
fi
AWS_REGION="us-east-1"
AWS_EKS_ADMIN_ARN="arn:aws:iam::$ACCOUNT_ID:role/project-bedrock-eks-admin-role"
CLUSTER_NAME="project-bedrock-cluster"
APP_NAMESPACE="retail-app"


echo "Connecting kubectl to EKS Cluster..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME --role-arn $AWS_EKS_ADMIN_ARN

echo "Verifying cluster access by listing nodes..."
kubectl get nodes

echo "Uninstalling retail store sample microservices application using Helm..."
helm uninstall ui -n $APP_NAMESPACE 2>/dev/null || echo "UI release is already uninstalled or does not exist"
helm uninstall checkout -n $APP_NAMESPACE 2>/dev/null || echo "Checkout release is already uninstalled or does not exist"
helm uninstall orders -n $APP_NAMESPACE 2>/dev/null || echo "Orders release is already uninstalled or does not exist"
helm uninstall cart -n $APP_NAMESPACE 2>/dev/null || echo "Cart release is already uninstalled or does not exist"
helm uninstall catalog -n $APP_NAMESPACE 2>/dev/null || echo "Catalog release is already uninstalled or does not exist"

echo "Deleting retail application namespace..."
kubectl delete namespace $APP_NAMESPACE 2>/dev/null || echo "Namespace does not exist or has already been deleted"

echo "Application clean up successful!"
