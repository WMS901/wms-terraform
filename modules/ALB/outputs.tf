output "alb_dns_name" {
  description = "ALB 도메인 이름 (CloudFront origin에 사용)"
  value       = aws_lb.this.dns_name
}
