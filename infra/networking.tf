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

resource "aws_config_config_rule" "vpc_default_security_group_closed" {
  name = "vpc-default-security-group-closed"
  source {
    owner = "AWS"
    source_identifier = "VPC_DEFAULT_SECURITY_GROUP_CLOSED"
  }
}
