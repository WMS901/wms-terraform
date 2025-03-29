resource "aws_iam_role" "this" {
  name = "wms-alb-controller-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

# ✅ inline policy 추가 (공식 권장 권한)
resource "aws_iam_role_policy" "alb_controller_policy" {
  name = "wms-alb-controller-inline-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:GetCertificate",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:Describe*",
          "ec2:DeleteSecurityGroup",
          "elasticloadbalancing:*",
          "iam:CreateServiceLinkedRole",
          "iam:GetServerCertificate",
          "iam:ListServerCertificates",
          "cognito-idp:DescribeUserPoolClient",
          "waf-regional:GetWebACLForResource",
          "waf-regional:GetWebACL",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:GetWebACL",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:DescribeProtection",
          "shield:GetSubscriptionState",
          "shield:DeleteProtection",
          "shield:CreateProtection",
          "shield:DescribeSubscription",
          "shield:ListProtections",
          "tag:GetResources",
          "tag:TagResources"
        ],
        Resource = "*"
      }
    ]
  })
}
