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
    key    = "eks-bazzyung/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_key_pair" "existing" {
  key_name = "wms_key"
}

module "bastion" {
  source = "../../modules/ec2"

  name                   = "wms-bastion-bazzy"
  ami_id                 = "ami-08b5b3a93ed654d19"
  instance_type          = "t2.micro"
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  vpc_security_group_ids = [data.terraform_remote_state.eks.outputs.bastion_sg_id]
  key_name               = data.aws_key_pair.existing.key_name
  iam_instance_profile   = "EC2-SSM"

  user_data = <<-EOF
              #!/bin/bash
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
              su - ec2-user -c 'aws eks update-kubeconfig --region us-east-1 --name wms-cluster-bazzy'

              # kubeconfig 설정
              export KUBECONFIG=/home/ec2-user/.kube/config

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

              # ALB Controller 관련 CRD 설치 (정식 URL 사용)
              curl -o crds.yaml https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml
              kubectl apply -f crds.yaml

              # TLS 인증서 생성 및 Secret 생성
              openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout tls.key -out tls.crt \
                -subj "/CN=webhook.aws-load-balancer-controller/O=alb"

              kubectl create secret tls aws-load-balancer-tls \
                --cert=tls.crt --key=tls.key -n kube-system
              EOF
}
