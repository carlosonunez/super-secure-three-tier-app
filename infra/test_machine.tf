resource "tls_private_key" "wiz_interview_test_machine" {
  algorithm = "RSA"
}

resource "aws_key_pair" "wiz_interview_test_machine" {
  key_name = "wiz_interview_test_machine"
  public_key = tls_private_key.wiz_interview_test_machine.public_key_openssh
}


module "wiz-interview-test-machine" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"
  name = "wiz-interview-test-machine"
  create_spot_instance = true
  spot_price = "0.017"
  instance_type = "t4g.micro"
  key_name = aws_key_pair.wiz_interview_test_machine.key_name
  ami = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  spot_wait_for_fulfillment = true
  subnet_id = module.wiz-interview-vpc.public_subnets[0]
  vpc_security_group_ids = [ module.wiz-interview-db-sg.security_group_id ]
}

# See also:
# - https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/issues/243
# - https://github.com/hashicorp/terraform/issues/3263
resource "aws_ec2_tag" "wiz_interview_test_machine" {
  resource_id = module.wiz-interview-test-machine.spot_instance_id
  key = "Name"
  value = "wiz-interview-test-machine"
}
