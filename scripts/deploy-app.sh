#!/bin/bash

set -e

# Environment variables
AWS_REGION="us-east-1"
CLUSTER_NAME="project-bedrock-cluster"
APP_NAMESPACE="retail-app"

echo "Updating kubeconfig for EKS cluster..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
aws eks --region us-east-1 update-kubeconfig --name project-bedrock-cluster

echo "Verifying cluster access by listing nodes..."
kubectl get nodes

echo "Creating namespace for retail application..."
kubectl create namespace $APP_NAMESPACE

echo "Adding Helm repository for retail store sample app..."
helm repo add retail-store https://aws-containers.github.io/retail-store-sample-app
helm repo update

echo "Deploying retail store sample application using Helm..."
helm install retail-store retail-store/retail-store-sample-app --namespace $APP_NAMESPACE
helm install ui oci://public.ecr.aws/aws-containers/retail-store-sample-ui-chart:0.8.5 --namespace retail-app

echo "Waiting for application pods to be ready..."
kubectl wait --namespace $APP_NAMESPACE --for=condition=ready pod -l app.kubernetes.io/name=retail-store --timeout=300s

echo "Listing pods in the retail application namespace..."
kubectl get pods -n $APP_NAMESPACE

echo "Retail store sample application deployed successfully!"
