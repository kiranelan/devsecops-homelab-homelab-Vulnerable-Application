#!/usr/bin/env bash
set -euo pipefail
: "${IMAGE_REPOSITORY:?Set IMAGE_REPOSITORY to the ECR repository URL}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
DB_PASSWORD="${DB_PASSWORD:-$(openssl rand -hex 24)}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-$(openssl rand -hex 24)}"
FLASK_SECRET_KEY="${FLASK_SECRET_KEY:-$(openssl rand -hex 32)}"
kubectl apply -f kubernetes/base/namespace.yaml
kubectl -n database create secret generic postgres-credentials --from-literal=postgres-password="${POSTGRES_PASSWORD}" --from-literal=password="${DB_PASSWORD}" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n vulnerable-app create secret generic vulnerable-app-secrets --from-literal=DB_PASSWORD="${DB_PASSWORD}" --from-literal=FLASK_SECRET_KEY="${FLASK_SECRET_KEY}" --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install postgresql oci://registry-1.docker.io/bitnamicharts/postgresql --namespace database --values database/postgres-values.yaml --wait --timeout 10m
kubectl -n database cp database/init-db.sql postgresql-0:/tmp/init-db.sql
kubectl -n database exec postgresql-0 -- env PGPASSWORD="${DB_PASSWORD}" psql -U appuser -d vulnerable_app -f /tmp/init-db.sql
kubectl kustomize kubernetes/base | sed "s#REPLACE_WITH_ECR_REPOSITORY:latest#${IMAGE_REPOSITORY}:${IMAGE_TAG}#" | kubectl apply -f -
kubectl -n vulnerable-app rollout status deployment/vulnerable-app --timeout=5m
kubectl -n vulnerable-app get pods,service,hpa
echo "Deployment complete. Run: kubectl -n vulnerable-app port-forward svc/vulnerable-app 5000:80"
