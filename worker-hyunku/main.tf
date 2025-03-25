provider "aws" {
  region = "us-east-1"
}

##########################
# ✅ 기존 VPC 및 Subnet 조회
##########################

data "aws_vpc" "selected" {
  id = "vpc-0fc2f39a043de2120"
}

data "aws_subnet" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["wms-public-subnet-1"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = [
      "wms-private-eks-subnet-1",
      "wms-private-eks-subnet-2"
    ]
  }
}

##########################
# ✅ Bastion EC2 모듈
##########################

module "bastion" {
  source            = "../modules/bastion"
  name              = "hyunku"
  ami_id            = "ami-0c02fb55956c7d316"
  instance_type     = "t2.micro"
  public_subnet_id  = data.aws_subnet.public.id
  vpc_id            = data.aws_vpc.selected.id
  public_key_path   = "C:/Users/soldesk/Downloads/wms_key.pub"
  key_name          = "wms-key"
  my_ip_cidr        = "180.80.107.4/32"
}

##########################
# ✅ EKS 모듈
##########################

module "eks" {
  source  = "../modules/eks"

  cluster_name    = "wms-cluster"
  cluster_version = "1.31"

  vpc_id             = data.aws_vpc.selected.id
  private_subnet_ids = data.aws_subnets.private.ids
  key_name           = "wms-key"

  # 자동 cluster creator 권한 부여 비활성화
  enable_cluster_creator_admin_permissions = false

  # EC2 SSM Role에 EKS admin 권한 부여 (✅ 정책 기반 권한 부여)
  access_entries = {
    ec2_ssm_admin = {
      principal_arn       = "arn:aws:iam::816069155414:role/EC2-SSM"
      type                = "STANDARD"
      kubernetes_groups   = []  # ✅ 추가: 필수 항목이므로 빈 배열이라도 넣자
      policy_associations = [
        {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        }
      ]
    }
  }
}
