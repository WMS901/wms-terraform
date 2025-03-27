output "volume_id" {
  description = "ID of the created EBS volume"
  value       = aws_ebs_volume.this.id
}

output "availability_zone" {
  description = "Availability zone of the volume"
  value       = aws_ebs_volume.this.availability_zone
}

output "size" {
  description = "Size of the volume"
  value       = aws_ebs_volume.this.size
}
