provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "sol-wms-terraform-states"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "sol-wms-terraform-states"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_key_pair" "existing" {
  key_name = "wms_key"
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  vpc_security_group_ids      = [data.terraform_remote_state.eks.outputs.bastion_sg_id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.existing.key_name
  iam_instance_profile        = "EC2-SSM"

  user_data = <<-EOF
              #!/bin/bash
              # 실패 시 즉시 중단하고, 실행 로그 출력
              set -ex

              yum install -y tree git curl unzip --allowerasing

              # kubectl 설치
              curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl"
              chmod +x kubectl
              mv kubectl /usr/local/bin/kubectl

              # .kube 디렉토리 생성
              mkdir -p /home/ec2-user/.kube
              chown -R ec2-user:ec2-user /home/ec2-user/.kube

              # ec2-user로 kubeconfig 구성
              # su - ec2-user -c 'aws eks update-kubeconfig --region us-east-1 --name wms-cluster'
              
              # eksctl 설치
              curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" -o eksctl.tar.gz
              tar -xzf eksctl.tar.gz
              mv eksctl /usr/local/bin/
              chmod +x /usr/local/bin/eksctl
              export AWS_REGION=us-east-1
              eksctl version

              # Helm 설치
              curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
              helm repo add bitnami https://charts.bitnami.com/bitnami
              helm repo update

              # Helm chart 클론
              cd /
              git clone https://github.com/WMS901/aws-helm-charts.git
              chown -R ec2-user:ec2-user /aws-helm-charts
            EOF

  tags = {
    Name = "${var.name}-bastion"
  }
}
