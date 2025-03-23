# 보안 그룹 (SSH 허용)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from my IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]  # 집이나 학원 IP로 제한
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# 키 페어 (이미 있다면 생략 가능)
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = file(var.public_key_path)
}

# EC2 인스턴스 (Bastion Host)
# resource "aws_instance" "bastion" {
#   ami                         = data.aws_ami.amazon_linux.id
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.public_subnet.id
#   vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
#   associate_public_ip_address = true
#   key_name                    = aws_key_pair.bastion_key.key_name

#   tags = {
#     Name = "bastion-host"
#   }
# }

resource "aws_instance" "bastion" {
  ami                         = "ami-0c02fb55956c7d316"  # ✅ 고정 AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastion_key.key_name

  tags = {
    Name = "bastion-host"
  }
}