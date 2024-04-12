module "wiz-interview-eks-sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  name = "wiz-interview-eks-sg"
  vpc_id = module.wiz-interview-vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      source_security_group_id = module.wiz-interview-db-sg.security_group_id
    }
  ]
  ingress_with_self = [
    {
      from_port = -1
      to_port = -1
      protocol = "-1"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port = -1
      to_port = -1
      protocol = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_ipv6_cidr_blocks = [
    {
      from_port = -1
      to_port = -1
      protocol = "-1"
      cidr_blocks = "::/0"
    }
  ]
}
