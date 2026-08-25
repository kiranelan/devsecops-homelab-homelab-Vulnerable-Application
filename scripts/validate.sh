#!/usr/bin/env bash
set -euo pipefail
python -m py_compile app/app.py
docker build --check app
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate
kubectl kustomize kubernetes/base >/tmp/devsecops-rendered.yaml
if command -v kubeconform >/dev/null 2>&1; then kubeconform -strict -summary /tmp/devsecops-rendered.yaml; fi
echo "Static validation passed"
