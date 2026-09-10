resource "aws_kms_key" "eks_cluster_encryption" {
  description             = "KMS key for ${var.cluster_name} Kubernetes secrets"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.cluster_name}-secrets"
  }
}

resource "aws_kms_alias" "eks_cluster_encryption" {
  name          = "alias/${var.cluster_name}-secrets"
  target_key_id = aws_kms_key.eks_cluster_encryption.key_id
}

output "kms_key_id" {
  description = "KMS key ID used for EKS secret encryption"
  value       = aws_kms_key.eks_cluster_encryption.key_id
}

