output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

# output "node_group_role_arn" {
#   value = module.eks_managed_node_groups["default"].iam_role_arn
# }

output "eks_cluster_id" {
  value = module.eks.cluster_id
}