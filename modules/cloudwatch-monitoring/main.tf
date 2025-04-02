provider "aws" {
  region = var.region
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

resource "aws_iam_role" "cloudwatch_agent_irsa" {
  name = "eks-cloudwatch-agent-role-new"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.cloudwatch_agent_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "kubernetes_manifest" "cw_namespace" {
  manifest = yamldecode(file("${path.module}/cwagent-namespace.yaml"))
}

resource "kubernetes_manifest" "cw_serviceaccount" {
  depends_on = [kubernetes_manifest.cw_namespace]
  manifest = yamldecode(file("${path.module}/cwagent-serviceaccount.yaml"))
}

resource "kubernetes_manifest" "cw_configmap" {
  depends_on = [kubernetes_manifest.cw_namespace]
  manifest = yamldecode(file("${path.module}/cwagent-configmap.yaml"))
}

resource "kubernetes_manifest" "cw_daemonset" {
  depends_on = [kubernetes_manifest.cw_namespace]
  manifest = yamldecode(file("${path.module}/cwagent-daemonset.yaml"))
}

resource "kubernetes_manifest" "cw_clusterrole" {
  manifest = yamldecode(file("${path.module}/cwagent-clusterrole.yaml"))
}

resource "kubernetes_manifest" "cw_clusterrolebinding" {
  depends_on = [
    kubernetes_manifest.cw_namespace,
    kubernetes_manifest.cw_serviceaccount,
    kubernetes_manifest.cw_clusterrole,
  ]
  manifest = yamldecode(file("${path.module}/cwagent-clusterrolebinding.yaml"))
}