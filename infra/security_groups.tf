resource "aws_security_group" "wiz_interview" {
  vpc_id = aws_vpc.wiz_interview.id
  name = "wiz_interview_default"
  description = "Wiz Interview Platform"
  tags = {
    Name = "wiz_interview_default"
  }
}

resource "aws_vpc_security_group_egress_rule" "wiz_interview_vpc_allow_outbound_inet4" {
  security_group_id = aws_security_group.wiz_interview.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "wiz_interview_vpc_allow_outbound_inet6" {
  security_group_id = aws_security_group.wiz_interview.id
  cidr_ipv6 = "::/0"
  ip_protocol = "-1"
}

resource "aws_config_config_rule" "authorized-open-ports" {
  name = "authorized-open-ports"
  source {
    owner = "AWS"
    source_identifier = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"
  }
  input_parameters = <<PARAMS
{
  "authorizedTcpPorts": "80"
}
PARAMS
}

