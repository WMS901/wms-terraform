output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
}

output "private_eks_subnet_ids" {
  value = [
    aws_subnet.private_eks_subnet_1.id,
    aws_subnet.private_eks_subnet_2.id
  ]
}

output "private_db_subnet_ids" {
  value = [
    aws_subnet.private_db_subnet_1.id,
    aws_subnet.private_db_subnet_2.id
  ]
}