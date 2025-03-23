# EIP (NAT용 고정 IP)
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "wms-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "wms-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# 프라이빗 서브넷용 라우팅 테이블
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "wms-private-rt"
  }
}

# 프라이빗 서브넷에 라우팅 테이블 연결
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}