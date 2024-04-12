resource "aws_vpc" "wiz_interview" {
  cidr_block = "172.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "wiz_interview_vpc"
  }
}

resource "aws_internet_gateway" "wiz_interview" {
  vpc_id = aws_vpc.wiz_interview.id
  tags = {
    Name = "wiz_interview_igw"
  }
}

resource "aws_route_table" "wiz_interview_to_internet" {
  vpc_id = aws_vpc.wiz_interview.id
  tags = {
    Name = "wiz_interview_rt_out_to_internet"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wiz_interview.id
  }
}

resource "aws_route_table_association" "wiz_interview_public_to_internet" {
  subnet_id = aws_subnet.wiz_interview_public.id
  route_table_id = aws_route_table.wiz_interview_to_internet.id
}

resource "aws_subnet" "wiz_interview_public" {
  vpc_id = aws_vpc.wiz_interview.id
  cidr_block = "172.0.1.0/24"
  tags = {
    Name = "Wiz Interview Public Subnet"
  }
}

resource "aws_subnet" "wiz_interview_private" {
  vpc_id = aws_vpc.wiz_interview.id
  cidr_block = "172.0.254.0/24"
  tags = {
    Name = "Wiz Interview Private Subnet"
  }
}
