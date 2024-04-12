data "aws_iam_policy_document" "wiz_interview_db_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
    actions = [ "sts:AssumeRole" ]
  }
}

data "aws_iam_policy_document" "wiz_interview_db_instance_policy" {
  statement {
    effect = "Allow"
    actions = [ "ec2:*" ]
    resources = [ "arn:aws:ec2::*" ]
  }
}

resource "aws_iam_role" "wiz_interview_db" {
  name = "wiz-interview-db-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.wiz_interview_db_assume_role.json
}

resource "aws_iam_policy" "wiz_interview_db_policy" {
  name = "wiz-interview-db-policy"
  path = "/"
  policy = data.aws_iam_policy_document.wiz_interview_db_instance_policy.json
}

resource "aws_iam_role_policy_attachment" "wiz_interview_db" {
  role = aws_iam_role.wiz_interview_db.name
  policy_arn = aws_iam_policy.wiz_interview_db_policy.arn
}

resource "aws_iam_instance_profile" "wiz_interview_db" {
  name = "wiz-interview-db"
  role = aws_iam_role.wiz_interview_db.name
}

resource "tls_private_key" "wiz_interview_db" {
  algorithm = "RSA"
}

resource "aws_key_pair" "wiz_interview_db" {
  key_name = "wiz_interview_db"
  public_key = tls_private_key.wiz_interview_db.public_key_openssh
}

resource "aws_instance" "wiz_interview_db" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t4g.large"
  tags = {
    Name = "wiz-interview-db"
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.017"
    }
  }
  subnet_id = aws_subnet.wiz_interview_public.id
  key_name = aws_key_pair.wiz_interview_db.key_name
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.wiz_interview_db.name
  vpc_security_group_ids = [ aws_security_group.wiz_interview_db.id ]
}
