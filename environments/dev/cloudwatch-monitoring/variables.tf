variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}
