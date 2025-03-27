output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "node_group_output" {
  description = "All outputs for eks_managed_node_groups"
  value       = module.eks.eks_managed_node_groups
}

output "bastion_sg_id" {
  value       = aws_security_group.bastion.id
  description = "Security group ID that allows Bastion to connect to EKS nodes"
}
