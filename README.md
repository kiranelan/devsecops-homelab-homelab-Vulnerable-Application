# DevSecOps EKS Security Lab

Submission-ready homelab that deploys an intentionally vulnerable Flask application and PostgreSQL database to Amazon EKS, protects the public ALB with AWS WAF, and demonstrates layered DevSecOps controls.

> **Safety:** Deploy only in an isolated training AWS account. The application intentionally contains SQL injection, stored XSS, weak authentication, authorization bypass, plain-text training passwords, and information disclosure. Never expose the application without the documented controls.

## Architecture

```text
Internet -> AWS WAF -> ALB Ingress -> Flask pods -> PostgreSQL StatefulSet/PVC
                          |                |
                     NetworkPolicy    Kubernetes Secrets

GitHub Actions -> SAST + dependency/container/IaC scans -> security artifacts
Terraform      -> VPC + EKS + KMS + ECR + WAF + CloudWatch logs
```

## Controls implemented

- Cost-optimized lab mode uses one EKS worker in public subnets without a NAT Gateway. Private workers with a single NAT Gateway remain available through the enable_nat_gateway variable.
- AWS-managed Common, Known Bad Inputs, and SQLi WAF rule groups plus IP rate limiting
- WAF sampled requests, metrics, CloudWatch logging, and authorization-header redaction
- Restricted Pod Security Standards, non-root containers, dropped Linux capabilities, read-only root filesystem
- Least-privilege service account with token automount disabled
- Namespace isolation, database-only egress, DNS-only supporting egress, resource quotas, PDB, HPA
- Runtime-created Kubernetes secrets; no real credential values are committed
- GitHub Actions validation plus Bandit, Trivy, and Checkov reports
- Safe repeatable build, deploy, test, and guarded cleanup scripts

## Prerequisites

- AWS CLI authenticated to a disposable account
- Terraform, Docker, kubectl, Helm, OpenSSL, and Git
- Permissions for VPC, EKS, IAM, EC2, KMS, ECR, WAFv2, and CloudWatch Logs
- AWS Load Balancer Controller installed in the cluster before applying `kubernetes/ingress.yaml`

## 1. Provision infrastructure

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
terraform -chdir=terraform init
terraform -chdir=terraform plan -out=tfplan
terraform -chdir=terraform apply tfplan
aws eks update-kubeconfig \
  --region "$(terraform -chdir=terraform output -raw aws_region)" \
  --name "$(terraform -chdir=terraform output -raw cluster_name)"
kubectl get nodes
```

If using remote state, copy `terraform/backend.example.tf` to `terraform/backend.tf` and replace its placeholders before `terraform init`.

## 2. Build and push the image

```bash
export AWS_REGION=us-west-2
export ECR_REPOSITORY="$(terraform -chdir=terraform output -raw ecr_repository_url)"
export IMAGE_TAG="$(git rev-parse --short HEAD)"
./scripts/build-and-push.sh
```

## 3. Deploy PostgreSQL and Flask

`deploy.sh` generates strong random database and Flask secret values unless they are supplied through environment variables. Save custom values in a password manager, never in Git.

```bash
export IMAGE_REPOSITORY="$ECR_REPOSITORY"
export IMAGE_TAG
./scripts/deploy.sh
```

Verify:

```bash
kubectl get pods -A
kubectl -n vulnerable-app port-forward svc/vulnerable-app 5000:80
curl http://127.0.0.1:5000/healthz
```

## 4. Enable ALB and WAF

Install the AWS Load Balancer Controller using its official EKS instructions. Then:

```bash
cp kubernetes/ingress.yaml.example kubernetes/ingress.yaml
WAF_ACL_ARN="$(terraform -chdir=terraform output -raw waf_web_acl_arn)"
sed -i.bak "s#REPLACE_WITH_WAF_ACL_ARN#${WAF_ACL_ARN}#" kubernetes/ingress.yaml
kubectl apply -f kubernetes/ingress.yaml
kubectl -n vulnerable-app get ingress
```

For production-like use, configure HTTPS with ACM and redirect HTTP to HTTPS. HTTP is retained here to keep the interview lab focused and inexpensive.

## 5. Test and capture evidence

First test the direct port-forward to demonstrate the vulnerabilities. Then set `BASE_URL` to the ALB URL and repeat to demonstrate WAF protection.

```bash
BASE_URL=http://127.0.0.1:5000 ./scripts/security-test.sh
BASE_URL=http://YOUR_ALB_DNS_NAME ./scripts/security-test.sh
```

Expected result: direct SQLi/XSS requests reach the app; equivalent WAF-routed requests are blocked, normally with HTTP 403. Results are written under `reports/`.

## 6. CI/CD behavior

`.github/workflows/devsecops.yml` validates Python, Terraform, Kubernetes rendering, and the Docker build. Bandit, Trivy, and Checkov intentionally report findings because the target application is vulnerable. Scan steps collect artifacts rather than fail immediately so the lab produces evidence. In a normal repository, set severity thresholds and nonzero exit codes to enforce policy gates.

## 7. Cleanup

Review the active AWS account and Terraform plan first:

```bash
terraform -chdir=terraform plan -destroy
CONFIRM_DESTROY=yes ./scripts/cleanup.sh
```

## Repository map

| Path | Purpose |
|---|---|
| `app/` | Vulnerable Flask source and non-root container image |
| `database/` | PostgreSQL Helm values and PostgreSQL-compatible test data |
| `terraform/` | VPC, EKS, KMS, ECR, WAF, logging, and outputs |
| `kubernetes/base/` | Kustomize application and security manifests |
| `scripts/` | Build, deployment, validation, security testing, and cleanup |
| `.github/workflows/` | DevSecOps validation and scan pipeline |
| `docs/` | Assignment, test data, findings, and interview notes |

## Interview discussion points

- WAF is compensating control, not a replacement for fixing application code.
- A public EKS endpoint is convenient for the lab; production should restrict its CIDRs or use private access.
- The default lab configuration removes the NAT Gateway and uses public worker subnets to minimize cost. Production should use private workers, NAT Gateways or VPC endpoints, and stronger network isolation.
- Secrets are generated at deployment time; production should use AWS Secrets Manager with External Secrets or Secrets Store CSI.
- The intentionally vulnerable image should never be promoted beyond a dedicated lab environment.
