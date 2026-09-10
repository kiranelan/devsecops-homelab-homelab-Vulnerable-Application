module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version
  vpc_id             = module.vpc.vpc_id

  ## Addons for Amazon VPC CNI
  addons = {
    coredns = {}

    kube-proxy = {}

    vpc-cni = {
      before_compute = true
    }
  }

  # Private nodes are used with NAT. The explicit no-NAT lab mode uses public
  # subnets so that node bootstrap and image pulls continue to work.
  subnet_ids = var.enable_nat_gateway ? module.vpc.private_subnets : module.vpc.public_subnets

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  encryption_config = {
    provider_key_arn = aws_kms_key.eks_cluster_encryption.arn
    resources        = ["secrets"]
  }

  eks_managed_node_groups = {
    default = {
      desired_size   = var.node_desired_capacity
      min_size       = 1
      max_size       = var.node_max_capacity
      instance_types = [var.node_instance_type]
      capacity_type  = var.use_spot_instances ? "SPOT" : "ON_DEMAND"
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_size      = 20

      labels = {
        Environment = "lab"
        Purpose     = "devsecops-lab"
      }
    }
  }

  tags = {
    Environment = "lab"
  }
}

