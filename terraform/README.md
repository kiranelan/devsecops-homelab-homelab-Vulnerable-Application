# Terraform comparison update

These files are intended to be compared with the repository's existing
`terraform/` directory. Review the differences before copying them into the
repository.

## Recommended default

The default configuration retains one NAT Gateway and places the EKS managed
node group in private subnets. This matches the stronger architecture described
in the project documentation.

```hcl
enable_nat_gateway  = true
enable_edge_security = false
```

`enable_edge_security` defaults to `false` so that WAF and its CloudWatch log
group are created only for the short WAF demonstration. Set it to `true` before
applying the ALB Ingress.

## Lowest-cost lab mode

To remove the NAT Gateway, set:

```hcl
enable_nat_gateway = false
```

The included VPC and EKS files then:

- Disable the NAT Gateway.
- Enable public IPv4 assignment on public subnets.
- Place the single EKS node group in public subnets.

This is suitable only for a temporary lab. The node security groups must remain
restricted. Do not disable NAT while continuing to place nodes in private
subnets unless the required VPC endpoints are also configured.

## Files changed

| File | Change |
|---|---|
| `versions.tf` | Pins compatible Terraform and AWS provider ranges. |
| `variables.tf` | Adds NAT, WAF, log-retention and ECR-retention controls. |
| `vpc.tf` | Makes the single NAT optional and supports public-node lab mode. |
| `eks.tf` | Selects private or public node subnets according to NAT mode. |
| `security-examples.tf` | Retains only the KMS resources actually used by EKS and enables rotation. |
| `ecr.tf` | Allows cleanup of lab images and retains only three images. |
| `waf.tf` | Fixes invalid nested-block syntax and makes edge security optional. |
| `output.tf` | Handles an optional WAF without invalid indexing. |
| `terraform.tfvars.example` | Shows recommended and lowest-cost settings. |

## Apply the comparison

From the repository root:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
terraform -chdir=terraform fmt -recursive
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate
terraform -chdir=terraform plan
```

Do not apply until the plan shows only the expected lab resources.

## Cost workflow

1. Keep `enable_edge_security = false` for initial EKS and port-forward tests.
2. Set it to `true` only when preparing the ALB/WAF demonstration.
3. Delete the Kubernetes Ingress before destroying Terraform resources.
4. Run `terraform destroy` the same day.

The EKS control plane is billable even when no application pods are running.

