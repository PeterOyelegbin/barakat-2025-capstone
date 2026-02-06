#!/bin/bash

set -euo pipefail

# Set environment
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../terraform"

echo "Destroying infrastructure..."
cd "$APP_DIR"
terraform destroy -auto-approve

echo "Infrastructure destroyed successfully!"
