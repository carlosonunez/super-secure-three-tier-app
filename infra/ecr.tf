data "aws_ecr_authorization_token" "token" {}

module "wiz-interview-ecr-repo" {
  depends_on = [ module.wiz-interview-eks-cluster ]
  source    = "terraform-aws-modules/ecr/aws"
  version   = "2.2.0"

  repository_name = "wiz-interview-ecr-repo/tasky"
  repository_read_write_access_arns = [ data.aws_caller_identity.self.arn ]
  create_lifecycle_policy = false
}

