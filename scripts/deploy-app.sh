#!/bin/bash

set -euo pipefail

# Environment variables
# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Go to the root directory (assuming script is in scripts/)
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
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
# aws eks --region us-east-1 update-kubeconfig --name project-bedrock-cluster --role-arn arn:aws:iam::226290659927:role/project-bedrock-eks-admin-role

echo "Verifying cluster access by listing nodes..."
kubectl get nodes

echo "Creating namespace for retail application..."
kubectl create namespace $APP_NAMESPACE 2>/dev/null || echo "Namespace $APP_NAMESPACE already exists"

echo "Adding Helm repository for retail store sample app..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo "Deploying dependencies for the retail application using Helm..."
helm dependency update "$ROOT_DIR/cluster-deps" || helm dependency build "$ROOT_DIR/cluster-deps"
helm install "$ROOT_DIR/cluster-deps" -n $APP_NAMESPACE --create-namespace --timeout=10m 2>/dev/null || echo "In cluster databases is still starting..."

echo "Deploying retail store sample microservices application using Helm..."
# Deploy catalog service using MySQL database
helm install catalog oci://public.ecr.aws/aws-containers/retail-store-sample-catalog-chart:1.4.0 \
  --namespace $APP_NAMESPACE --set database.type=mysql --set database.host=mysql \
  --set database.name=catalog_db --set database.user=catalog_user --set database.password=CatalogPass123 \
  --wait

# Deploy cart service using DynamoDB
helm install carts oci://public.ecr.aws/aws-containers/retail-store-sample-cart-chart:1.4.0 \
  --namespace $APP_NAMESPACE --set database.type=dynamodb --set database.endpoint=http://dynamodb-local:8000 \
  --set database.tableName=cart_table --wait

# Deploy orders service using PostgreSQL
helm install orders oci://public.ecr.aws/aws-containers/retail-store-sample-orders-chart:1.4.0 \
  --namespace $APP_NAMESPACE --set database.type=postgresql --set database.host=postgresql \
  --set database.name=orders_db --set database.user=orders_user --set database.password=OrdersPass123 \
  --wait

# Deploy checkout service using Redis for session management
helm install checkout oci://public.ecr.aws/aws-containers/retail-store-sample-checkout-chart:1.4.0 \
  --namespace $APP_NAMESPACE --set redis.enabled=true --set redis.host=redis --wait

# Deploy UI service (frontend application) and connect it to the backend services
helm install ui oci://public.ecr.aws/aws-containers/retail-store-sample-ui-chart:1.4.0 \
  --namespace $APP_NAMESPACE --set catalog.host=catalog --set cart.host=carts \
  --set orders.host=orders --set checkout.host=checkout --set service.type=LoadBalancer \
  --set service.port=80 --set service.targetPort=80 --wait

echo "Waiting for application pods to be ready..."
kubectl wait --namespace $APP_NAMESPACE --for=condition=ready pod --all --timeout=300s 2>/dev/null || echo "Some pods may still be starting up"

echo "Listing pods in the retail application namespace..."
kubectl get pods -n $APP_NAMESPACE

echo "Listing services in the retail application namespace..."
kubectl get svc -n $APP_NAMESPACE

echo "Retail store sample application deployed successfully!"
