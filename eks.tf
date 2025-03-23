module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"

  cluster_name    = "wms-cluster"
  cluster_version = "1.29"

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
  vpc_id          = aws_vpc.main.id

  enable_irsa     = true  # IAM Roles for Service Accounts

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 3
      min_size     = 1

      instance_types = ["t3.medium"]
      subnet_ids     = [aws_subnet.private_subnet.id]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
