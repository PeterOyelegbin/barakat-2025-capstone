#!/bin/bash

set -euo pipefail

# Set environment
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../terraform"
BUCKET_NAME="bedrock-assets-altsoe0250384"

echo "Cleaning up S3 bucket: $BUCKET_NAME"
aws s3 rm s3://${BUCKET_NAME} --recursive 2>/dev/null || echo "S3 bucket is already empty or does not exist"

echo "Destroying infrastructure..."
cd "$APP_DIR"
terraform destroy -auto-approve

echo "Infrastructure destroyed successfully!"
