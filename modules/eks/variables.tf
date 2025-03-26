variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes 버전"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 목록"
  type        = list(string)
}

variable "key_name" {
  description = "EC2 키 페어 이름"
  type        = string
}

# ✅ access_entries: map(object) 형태로 수정
variable "access_entries" {
  description = "EKS access_entries (IAM to RBAC mapping)"
  type = map(object({
    principal_arn       = string
    type                = string
    kubernetes_groups   = list(string)
    policy_associations = list(any)
  }))
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Whether to enable cluster creator as admin"
  type        = bool
  default     = true
}

variable "bastion_sg_id" {
  description = "Security Group ID of the bastion host to allow traffic to EKS nodes"
  type        = string
  default     = null
}
