resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = var.user_data

  tags = {
    Name = "${var.name}-instance"
  }
}
