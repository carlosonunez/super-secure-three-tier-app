resource "random_string" "aws_config_recorder_bucket_prefix" {
  length = 12
  special = false
  lower = true
  upper = false
}

resource "aws_iam_role" "aws_config" {
  name = "wiz-interview-aws-config-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws_config" {
  role = aws_iam_role.aws_config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_s3_bucket" "aws_config_recorder" {
  bucket_prefix = random_string.aws_config_recorder_bucket_prefix.result
}

resource "aws_s3_bucket_ownership_controls" "aws_config_recorder" {
  bucket = aws_s3_bucket.aws_config_recorder.bucket
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "aws_config_recorder" {
  depends_on = [ aws_s3_bucket_ownership_controls.aws_config_recorder ]
  bucket = aws_s3_bucket.aws_config_recorder.bucket
  acl = "private"
}

resource "aws_s3_bucket_versioning" "aws_config_recorder" {
  bucket = aws_s3_bucket.aws_config_recorder.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "aws_config_recorder" {
  bucket = aws_s3_bucket.aws_config_recorder.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "config.amazonaws.com"
        ]
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.aws_config_recorder.arn}"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "config.amazonaws.com"
        ]
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.aws_config_recorder.arn}/${random_string.aws_config_recorder_bucket_prefix.result}/AWSLogs/${data.aws_caller_identity.self.account_id}/Config/*"
    }
  ]
}
POLICY
}

resource "aws_config_configuration_recorder" "aws_config" {
  name = "wiz-interview-aws-config-recorder"
  role_arn = aws_iam_role.aws_config.arn
}

resource "aws_config_delivery_channel" "aws_config" {
  name = "wiz-interview-aws-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.aws_config_recorder.bucket
  s3_key_prefix = random_string.aws_config_recorder_bucket_prefix.result
}

resource "aws_config_configuration_recorder_status" "aws_config" {
  name = aws_config_configuration_recorder.aws_config.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.aws_config]
}

resource "aws_config_configuration_aggregator" "aws_config" {
  name = aws_config_configuration_recorder.aws_config.name
  account_aggregation_source {
    account_ids = [ data.aws_caller_identity.self.account_id ]
    regions = [ data.aws_region.current.name ]
  }
}
