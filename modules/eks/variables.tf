variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
  default = "wms-cluster"
}

variable "cluster_version" {
  type        = string
  description = "EKS cluster Kubernetes version"
  default     = "1.31"
}

variable "enable_cluster_creator_admin_permissions" {
  type        = bool
  description = "Enable admin access for cluster creator"
  default     = true
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name for worker nodes"
  default = "wms_key"
}

variable "my_ip_cidr" {
  type        = string
  description = "CIDR block of your local IP for SSH access"
  default     = "180.80.107.4/32"
}