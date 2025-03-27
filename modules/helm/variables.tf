variable "release_name" {
  description = "Name of the Helm release"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "repository" {
  description = "Helm chart repository URL"
  type        = string
}

variable "chart" {
  description = "Helm chart name"
  type        = string
}

variable "chart_version" {
  description = "Chart version (optional)"
  type        = string
  default     = null
}

variable "values" {
  description = "List of value YAML files"
  type        = list(string)
  default     = []
}
