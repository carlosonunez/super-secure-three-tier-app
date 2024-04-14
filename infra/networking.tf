module "wiz-interview-vpc" {
  depends_on = [ module.wiz-interview-aws_config ]
  source = "terraform-aws-modules/vpc/aws"
  name = "wiz-interview"
  cidr = "172.0.0.0/16"
  azs = ["us-east-2a","us-east-2c"]
  private_subnets = [ "172.0.253.0/24","172.0.254.0/24" ]
  public_subnets = [ "172.0.0.0/24","172.0.1.0/24" ]
  enable_nat_gateway = true
}
