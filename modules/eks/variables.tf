variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_version" {
  type        = string
  default     = "1.29"
  description = "Kubernetes version"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for EKS"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the cluster"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name"
}