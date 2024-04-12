resource "aws_security_group" "wiz_interview_db" {
  vpc_id = aws_vpc.wiz_interview.id
  name = "wiz_interview_db"
  description = "Wiz Interview Platform - Database"
  tags = {
    Name = "wiz_interview_db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "wiz_interview_db_allow_ssh_from_inet4" {
  security_group_id = aws_security_group.wiz_interview_db.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}

resource "aws_vpc_security_group_ingress_rule" "wiz_interview_db_allow_all_within_self" {
  security_group_id = aws_security_group.wiz_interview_db.id
  ip_protocol = "-1"
  referenced_security_group_id = aws_security_group.wiz_interview_db.id
}

resource "aws_vpc_security_group_ingress_rule" "wiz_interview_db_allow_db_from_web" {
  security_group_id = aws_security_group.wiz_interview_db.id
  ip_protocol = "tcp"
  from_port = 5432
  to_port = 5432
  referenced_security_group_id = aws_security_group.wiz_interview_web.id
}

resource "aws_vpc_security_group_egress_rule" "wiz_interview_db_allow_outbound_inet4" {
  security_group_id = aws_security_group.wiz_interview_db.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "wiz_interview_db_allow_outbound_inet6" {
  security_group_id = aws_security_group.wiz_interview_db.id
  cidr_ipv6 = "::/0"
  ip_protocol = "-1"
}

resource "aws_security_group" "wiz_interview_web" {
  vpc_id = aws_vpc.wiz_interview.id
  name = "wiz_interview_web"
  description = "Wiz Interview Platform - Webservers"
  tags = {
    Name = "wiz_interview_web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "wiz_interview_web_allow_all_within_self" {
  security_group_id = aws_security_group.wiz_interview_web.id
  ip_protocol = "-1"
  referenced_security_group_id = aws_security_group.wiz_interview_web.id
}
