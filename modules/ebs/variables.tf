variable "name" {
  description = "Name tag for the EBS volume"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the EBS volume"
  type        = string
}

variable "size" {
  description = "Size of the volume in GB"
  type        = number
}

variable "volume_type" {
  description = "Type of EBS volume (e.g., gp3, gp2, io1)"
  type        = string
  default     = "gp3"
}

variable "encrypted" {
  description = "Whether the volume should be encrypted"
  type        = bool
  default     = true
}
