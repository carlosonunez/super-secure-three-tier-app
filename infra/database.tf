resource "tls_private_key" "wiz_interview_db" {
  algorithm = "RSA"
}

resource "aws_key_pair" "wiz_interview_db" {
  key_name = "wiz_interview_db"
  public_key = tls_private_key.wiz_interview_db.public_key_openssh
}

resource "random_string" "db_password" {
  special = false
  length = 32
}

resource "random_string" "db_name" {
  special = false
  length = 16
  numeric = false
}

resource "random_string" "db_user" {
  special = false
  upper = false
  numeric = false
  length = 16
}

resource "aws_iam_policy" "wiz_interview_db_policy" {
  name = "wiz-interview-db-policy"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Resource = "arn:aws:ec2::*"
        Action = [ "ec2:*" ]
      }
    ]
  })
}


module "wiz-interview-db-sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  name = "wiz-interview-db-sg"
  vpc_id = module.wiz-interview-vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      source_security_group_id = module.wiz-interview-eks-sg.security_group_id
    }
  ]
  ingress_with_cidr_blocks = [
    {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "0.0.0.0/0"
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

module "wiz-interview-db" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"
  name = "wiz-interview-db"
  create_spot_instance = true
  spot_price = "0.017"
  instance_type = "t4g.micro"
  key_name = aws_key_pair.wiz_interview_db.key_name
  ami = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  create_iam_instance_profile = true
  spot_wait_for_fulfillment = true
  subnet_id = module.wiz-interview-vpc.public_subnets[0]
  vpc_security_group_ids = [ module.wiz-interview-db-sg.security_group_id ]
}

# See also:
# - https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/issues/243
# - https://github.com/hashicorp/terraform/issues/3263
resource "aws_ec2_tag" "wiz_interview_db" {
  resource_id = module.wiz-interview-db.spot_instance_id
  key = "Name"
  value = "wiz-interview-db"
}

resource "aws_iam_role_policy_attachment" "wiz_interview_db" {
  role = module.wiz-interview-db.iam_role_name
  policy_arn = aws_iam_policy.wiz_interview_db_policy.arn
}

