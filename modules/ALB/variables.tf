variable "name" {
  description = "ALB 이름"
  type        = string
}

variable "security_group_id" {
  description = "기존 보안 그룹 ID (선택사항). 없으면 자동 생성"
  type        = string
  default     = ""
}

variable "target_port" {
  description = "EKS NodePort 포트"
  type        = number
  default     = 30000
}
