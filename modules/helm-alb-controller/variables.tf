variable "helm_chart_path" {
  type = string
}

variable "release_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "irsa_role_arn" {
  description = "IAM Role ARN for ALB Ingress Controller (IRSA)"
  type        = string
}

