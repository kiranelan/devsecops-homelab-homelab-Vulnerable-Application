variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "AWS region for all regional lab resources"
}

variable "cluster_name" {
  type        = string
  default     = "eks-interview-lab"
  description = "EKS cluster name and resource-name prefix"
}

variable "cluster_version" {
  type        = string
  default     = "1.35"
  description = "EKS Kubernetes version in standard support"
}

variable "node_instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type for the single lab worker node. t3.medium if pods are in pending state"
}

variable "node_desired_capacity" {
  type        = number
  default     = 1
  description = "Desired number of EKS worker nodes"

  validation {
    condition     = var.node_desired_capacity >= 1
    error_message = "At least one worker node is required for this lab."
  }
}

variable "node_max_capacity" {
  type        = number
  default     = 1
  description = "Maximum number of EKS worker nodes"

  validation {
    condition     = var.node_max_capacity >= 1
    error_message = "node_max_capacity must be at least one."
  }
}

variable "use_spot_instances" {
  type        = bool
  default     = true
  description = "Use interruptible Spot capacity to reduce lab cost"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Use one NAT Gateway and private worker nodes; false uses public worker subnets for temporary lab use"
}

variable "enable_edge_security" {
  type        = bool
  default     = false
  description = "Create WAF and WAF logging only when running the edge-security demonstration"
}

variable "waf_log_retention_days" {
  type        = number
  default     = 1
  description = "CloudWatch retention for temporary WAF logs"
}

variable "ecr_max_image_count" {
  type        = number
  default     = 3
  description = "Maximum application images retained in the lab ECR repository"
}
