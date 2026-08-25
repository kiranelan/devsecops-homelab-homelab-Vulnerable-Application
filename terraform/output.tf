# EKS Cluster outputs
output "aws_region" {
  description = "AWS region used by this deployment"
  value       = var.aws_region
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

# VPC outputs for WAF integration
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs for ALB"
  value       = module.vpc.public_subnets
}

# Node group outputs
output "node_group_arn" {
  description = "EKS managed node group ARN"
  value       = module.eks.eks_managed_node_groups["default"].node_group_arn
}

output "ecr_repository_url" {
  description = "Repository URL used to publish the application image"
  value       = aws_ecr_repository.app.repository_url
}

output "waf_web_acl_arn" {
  description = "WAFv2 ACL ARN for the Kubernetes ALB Ingress annotation"
  value       = aws_wafv2_web_acl.main.arn
}
