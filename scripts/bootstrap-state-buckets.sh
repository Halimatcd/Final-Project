#!/usr/bin/env bash
#
# Creates the S3 buckets used for Terraform remote state (one per environment)
# and enables versioning + encryption + public-access-block.
# Run this ONCE before `terraform init`. Requires the AWS CLI configured.
#
# Usage:  bash scripts/bootstrap-state-buckets.sh

set -euo pipefail

REGION="us-east-1"

STATE_BUCKETS=(
  "hoaminu-dev-tfstate-527581453529"
  "hoaminu-staging-tfstate-527581453529"
  "hoaminu-prod-tfstate-527581453529"
)

for BUCKET in "${STATE_BUCKETS[@]}"; do
  echo ">> Creating state bucket: ${BUCKET}"
  if [ "${REGION}" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "${BUCKET}" --region "${REGION}" 2>/dev/null || true
  else
    aws s3api create-bucket --bucket "${BUCKET}" --region "${REGION}" \
      --create-bucket-configuration LocationConstraint="${REGION}" 2>/dev/null || true
  fi

  aws s3api put-bucket-versioning --bucket "${BUCKET}" \
    --versioning-configuration Status=Enabled

  aws s3api put-bucket-encryption --bucket "${BUCKET}" \
    --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

  aws s3api put-public-access-block --bucket "${BUCKET}" \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

  echo ">> Done: ${BUCKET}"
done

echo "All state buckets are ready. Now run 'terraform init' in each environment."
