data "aws_iam_policy_document" "wiz_interview_db" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
    actions = [ "sts:AssumeRole", "ec2:*" ]
  }
}
