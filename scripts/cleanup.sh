#!/usr/bin/env bash
set -euo pipefail
if [[ "${CONFIRM_DESTROY:-}" != "yes" ]]; then
  echo "Cleanup is destructive. Re-run with CONFIRM_DESTROY=yes."
  exit 1
fi
kubectl delete -f kubernetes/ingress.yaml --ignore-not-found 2>/dev/null || true
kubectl delete namespace vulnerable-app database --ignore-not-found --wait=true
terraform -chdir=terraform destroy
