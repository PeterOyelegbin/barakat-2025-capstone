#!/bin/bash

set -e

# Environment variables
AWS_REGION="us-east-1"
# AWS_EKS_ADMIN_ARN="arn:aws:iam::154517339571:role/project-bedrock-eks-admin-role"
AWS_EKS_ADMIN_ARN="arn:aws:iam::226290659927:role/project-bedrock-eks-admin-role"
CLUSTER_NAME="project-bedrock-cluster"
APP_NAMESPACE="retail-app"

echo "Connecting kubectl to EKS Cluster..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
# aws eks --region us-east-1 update-kubeconfig --name project-bedrock-cluster --role-arn arn:aws:iam::226290659927:role/project-bedrock-eks-admin-role

echo "Verifying cluster access by listing nodes..."
kubectl get nodes

echo "Creating namespace for retail application..."
kubectl create namespace $APP_NAMESPACE
# kubectl create namespace retail-app

echo "Adding Helm repository for retail store sample app..."
helm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo add retail-store https://github.com/aws-containers/retail-store-sample-app
helm repo update

echo "Deploying retail store sample application using Helm..."
# helm install my-nginx bitnami/nginx --namespace retail-app
# helm install retail-store retail-store/retail-store-sample-app --namespace $APP_NAMESPACE
helm install ui oci://public.ecr.aws/aws-containers/retail-store-sample-ui-chart:0.8.5 --namespace $APP_NAMESPACE

echo "Waiting for application pods to be ready..."
kubectl wait --namespace $APP_NAMESPACE --for=condition=ready pod -l app.kubernetes.io/name=retail-store --timeout=300s

echo "Listing pods in the retail application namespace..."
kubectl get pods -n $APP_NAMESPACE
# kubectl get all -n $APP_NAMESPACE

echo "Exposing the services if not already exposed..."
kubectl patch svc ui -n retail-app -p '{"spec":{"type":"LoadBalancer"}}'

echo "Listing services in the retail application namespace..."
kubectl get svc -n $APP_NAMESPACE
# kubectl get svc -n retail-app my-nginx

echo "Retail store sample application deployed successfully!"
