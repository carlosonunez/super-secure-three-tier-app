data "aws_caller_identity" "self" {}
data "aws_region" "current" {}
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "architecture"
    values = ["arm64"]
  }
  filter {
    name = "owner-id"
    values = ["099720109477"] # Canonical
  }
  filter {
    name = "name"
    values =  ["ubuntu/images/hvm-ssd/ubuntu-jammy*"]
  }
}

