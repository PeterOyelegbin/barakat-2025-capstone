#!/bin/bash

set -euo pipefail

# Set environment
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../terraform"
APP_NAMESPACE="retail-app"
BUCKET_NAME="bedrock-assets-altsoe0250384"

echo "Deleting retail application from EKS cluster..."
kubectl delete namespace $APP_NAMESPACE 2>/dev/null || echo "Namespace $APP_NAMESPACE does not exist or has already been deleted"

echo "Cleaning up S3 bucket: $BUCKET_NAME"
aws s3 rm s3://${BUCKET_NAME} --recursive 2>/dev/null || echo "S3 bucket is already empty or does not exist"

echo "Destroying infrastructure..."
cd "$APP_DIR"
terraform destroy -auto-approve

echo "Infrastructure destroyed successfully!"
