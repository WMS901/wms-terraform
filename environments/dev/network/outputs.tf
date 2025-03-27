output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_eks_subnet_ids" {
  value = module.vpc.private_eks_subnet_ids
}

output "private_db_subnet_ids" {
  value = module.vpc.private_db_subnet_ids
}
