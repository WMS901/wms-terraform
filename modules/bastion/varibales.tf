variable "name" {
  type        = string
  description = "Name prefix"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your local IP CIDR to allow SSH"
}