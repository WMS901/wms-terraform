# /modules/ALB/outputs.tf
output "alb_dns_name" {
  description = "ALB 도메인 이름 (CloudFront origin에 사용)"
  value       = aws_lb.this.dns_name
}
output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "target_group_arn" {
  description = "ALB Target Group ARN"
  value       = aws_lb_target_group.this.arn
}