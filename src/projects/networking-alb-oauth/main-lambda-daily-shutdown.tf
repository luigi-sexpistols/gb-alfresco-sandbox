module "lambda_daily_shutdown" {
  source = "../../modules/aws/lambda-function"

  name = "${local.name_prefix}-daily-shutdown"
  runtime = "nodejs20.x"
  handler = "index.default"
  source_file = data.local_file.lambda_daily_shutdown.filename
  subnet_ids = module.network.private_subnets.*.id

  environment = {
    MATCH = jsonencode({
      name = "DailyShutdown"
      value = "Yes"
    })
  }
}

module "lambda_daily_shutdown_schedule" {
  source = "../../modules/aws/lambda-function-schedule"

  lambda_function_arn = module.lambda_daily_shutdown.function_arn
  schedule_expression = "cron(30 6 * * ? *)"
}

resource "aws_iam_policy" "lambda_daily_shutdown" {
  name = "${local.name_prefix}-daily-shutdown"
  path = "/"
  policy = data.aws_iam_policy_document.lambda_daily_shutdown.json

  tags = {
    Name = "${local.name_prefix}-daily-shutdown"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_daily_shutdown" {
  role = module.lambda_daily_shutdown.iam_role_name
  policy_arn = aws_iam_policy.lambda_daily_shutdown.arn
}

module "lambda_daily_shutdown_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.lambda_daily_shutdown.security_group_id

  egress = {
    "all" = {
      protocol = "-1"
      port = -1
      cidr_block = "0.0.0.0/0"
    }
  }
}
