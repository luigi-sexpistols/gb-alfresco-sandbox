module "dev_ip" {
  source = "../../modules/utils/dev-ip-address"
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
