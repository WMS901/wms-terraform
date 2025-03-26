data "aws_key_pair" "existing" {
  key_name   = "wms_key"
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.name}-bastion-sg"
  description = "Allow SSH from my IP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-bastion-sg"
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.existing.key_name
  iam_instance_profile        = "EC2-SSM"

  user_data = <<-EOF
              #!/bin/bash
              # kubectl 설치
              curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl"
              chmod +x kubectl
              mv kubectl /usr/local/bin/kubectl
              # eks update-kubeconfig
              aws eks update-kubeconfig --region us-east-1 --name wms-cluster
            EOF

  tags = {
    Name = "${var.name}-bastion"
  }
}