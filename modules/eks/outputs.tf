# output "cluster_id" {
#   description = "EKS Cluster ID"
#   value       = module.eks.cluster_id
# }

# output "cluster_endpoint" {
#   description = "EKS Cluster endpoint"
#   value       = module.eks.cluster_endpoint
# }

# output "cluster_name" {
#   description = "EKS Cluster name"
#   value       = module.eks.cluster_name
# }

# output "cluster_security_group_id" {
#   description = "Security group ID attached to the EKS cluster"
#   value       = module.eks.cluster_security_group_id
# }

# output "cluster_primary_security_group_id" {
#   value = module.eks.cluster_primary_security_group_id
# }

# output "node_group_role_arn" {
#   description = "ARN of the IAM role assigned to the node group"
#   value       = module.eks.eks_managed_node_groups.default.iam_role_arn
# }

# output "oidc_provider_arn" {
#   description = "ARN of the OIDC provider"
#   value       = module.eks.oidc_provider_arn
# }
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

# Note: For node group details, use outputs provided directly by the module
output "node_group_output" {
  description = "All outputs for eks_managed_node_groups"
  value       = module.eks.eks_managed_node_groups
}
