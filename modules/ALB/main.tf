# 1. 기존 VPC 상태를 S3에서 가져오기
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "sol-wms-terraform-states"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# 2. 자동 생성 보안 그룹
resource "aws_security_group" "this" {
  count       = var.security_group_id == "" ? 1 : 0
  name        = "${var.name}-sg"
  description = "Auto-created SG for ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. ALB 생성
resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id != "" ? var.security_group_id : aws_security_group.this[0].id]
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnet_ids
}

# 4. Target Group
resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "ip"
}

# 5. Listener
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
