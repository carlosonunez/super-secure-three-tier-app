module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "wiz-interview-vpc"
  cidr = "172.0.0.0/16"
  azs = [ "us-east-2a" ]
  private_subnets = ["172.1.0.0/24" ]
  public_subnets = ["172.254.0.0/24"]
  enable_nat_gateway = true
  enable_dns_hostnames = true
}

resource "aws_config_config_rule" "vpc_default_security_group_closed" {
  name = "vpc-default-security-group-closed"
  source {
    owner = "AWS"
    source_identifier = "VPC_DEFAULT_SECURITY_GROUP_CLOSED"
  }
}

resource "aws_config_config_rule" "igw-authorized-vpc-nly" {
  name = "igw-authorized-vpc-only"
  source {
    owner = "AWS"
    source_identifier = "VPC_INTERNET_GATEWAY_AUTHORIZED_VPC_ONLY"
  }
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

