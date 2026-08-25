# Interview Walkthrough

## Two-minute summary

I provisioned an EKS environment through Terraform, stored images in scan-enabled ECR, deployed PostgreSQL using Helm and the Flask workload using Kustomize, and placed an ALB protected by AWS WAF in front of it. I preserved the intentional application vulnerabilities so I could demonstrate detection and compensating controls. Kubernetes is hardened with restricted pod settings, network policies, resource controls, health probes, and runtime-generated secrets. CI validates the artifacts and produces SAST, container/dependency, and IaC findings.

## Key trade-offs

- **AWS WAF:** native ALB integration and managed rules reduce operational overhead; tuning is required to manage false positives and cost.
- **EKS endpoint:** public access accelerates a short lab; restrict access for longer-lived environments.
- **Database:** in-cluster PostgreSQL satisfies the assignment; RDS is preferable for production availability and managed backups.
- **Secrets:** Kubernetes Secrets avoid committing credentials but are not a complete secret-management solution; use Secrets Manager and KMS-backed integration in production.
- **CI scan mode:** findings are collected without blocking because the application is deliberately vulnerable; production policy would block releases on accepted severity thresholds.

## Troubleshooting sequence

1. Verify AWS identity, region, and Terraform outputs.
2. Check EKS nodes, CoreDNS, and storage class.
3. Check PostgreSQL pod, PVC, Service, and credentials Secret.
4. Check Flask events, image pull, readiness probe, and DNS resolution.
5. Check ALB controller logs, Ingress events, target health, WAF association, and sampled requests.
