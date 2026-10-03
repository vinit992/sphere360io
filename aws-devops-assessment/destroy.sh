#!/usr/bin/env bash
set -e

echo "Destroying AWS resources..."
terraform destroy -auto-approve
echo "Cleanup completed."
