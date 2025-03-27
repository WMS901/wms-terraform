output "irsa_role_arn" {
  description = "IAM role ARN used by ALB Ingress Controller"
  value       = aws_iam_role.this.arn
}
