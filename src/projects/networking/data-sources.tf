data "aws_ami" "bastion" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

data "local_file" "lambda_daily_shutdown" {
  filename = "${path.root}/../../lambda-functions/stop-instances/dist/app.zip"
}

data "aws_iam_policy_document" "lambda_daily_shutdown" {
  statement {
    sid = "AllowStopInstances"
    effect = "Allow"
    actions = [
      "ec2:StopInstances",
      "ec2:DescribeInstances"
    ]
    resources = [ "*" ]
  }

  statement {
    sid = "AllowEc2"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
}

data "http" "developer_ip" {
  url = "https://ipv4.icanhazip.com"
}
