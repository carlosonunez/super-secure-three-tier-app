module "wiz-interview-aws_config_storage" {
  source = "cloudposse/config-storage/aws"
  version = "1.0.0"
  force_destroy = true
  name = "wiz-interview-aws-config"
}

module "wiz-interview-aws_config" {
  source = "cloudposse/config/aws"
  version = "1.5.2"
  create_iam_role = true
  s3_bucket_id = module.wiz-interview-aws_config_storage.bucket_id
  s3_bucket_arn = module.wiz-interview-aws_config_storage.bucket_arn
  global_resource_collector_region = data.aws_region.current.name
  managed_rules = {
    vpc-authorized-ports = {
      description = "Ensures that all security groups within this VPC only expose specific ports."
      identifier = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"
      enabled = true
      trigger_type = "PERIODIC"
      input_parameters = {
        authorizedTcpPorts = "80,443"
      }
      tags = {}
    }
  }
}

module "wiz-interview-aws_config_cis" {
  depends_on = [ module.wiz-interview-aws_config ]
  source = "cloudposse/config/aws//modules/conformance-pack"
  version = "1.5.2"
  name = "Operational-Best-Practices-for-CIS"
  conformance_pack = "https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS.yaml"
}
