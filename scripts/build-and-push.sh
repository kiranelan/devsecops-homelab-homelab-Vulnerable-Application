#!/usr/bin/env bash
set -euo pipefail
: "${AWS_REGION:?Set AWS_REGION}"
: "${ECR_REPOSITORY:?Set ECR_REPOSITORY to the full repository URL}"
IMAGE_TAG="${IMAGE_TAG:-$(git rev-parse --short HEAD 2>/dev/null || date +%Y%m%d%H%M%S)}"
REGISTRY="${ECR_REPOSITORY%%/*}"
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${REGISTRY}"
docker build --pull -t "${ECR_REPOSITORY}:${IMAGE_TAG}" app
docker push "${ECR_REPOSITORY}:${IMAGE_TAG}"
echo "Published ${ECR_REPOSITORY}:${IMAGE_TAG}"
