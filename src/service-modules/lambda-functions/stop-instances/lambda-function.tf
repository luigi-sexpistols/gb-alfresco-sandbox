data "aws_iam_policy_document" "this" {
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
    sid = "AllowLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [aws_cloudwatch_log_group.this.arn]
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

resource "aws_iam_policy" "this" {
  name = local.name
  path = "/"
  policy = data.aws_iam_policy_document.this.json

  tags = {
    Name = local.name
  }
}

resource "aws_iam_role" "this" {
  name = local.name
  assume_role_policy = file("${path.module}/policies/assume-role-policy.json")

  tags = {
    Name = local.name
  }
}

resource "aws_iam_role_policy_attachment" "execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "access" {
  policy_arn = aws_iam_policy.this.arn
  role = aws_iam_role.this.name
}

data "local_file" "code_archive" {
  filename = "${path.root}/../../../lambda-functions/stop-instances/dist/app.zip"
}

resource "aws_security_group" "this" {
  vpc_id = var.vpc.id
  name = "${local.name}-lambda"

  tags = {
    Name = "${local.name}-lambda"
  }
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/0"

  tags = {
    Name = "all"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = local.name
  retention_in_days = 7

  tags = {
    Name = local.name
  }
}

resource "aws_lambda_function" "stop_instances" {
  function_name = local.name
  handler = "index.default"
  runtime = "nodejs22.x"
  filename = data.local_file.code_archive.filename
  source_code_hash = filesha256(data.local_file.code_archive.filename)
  role = aws_iam_role.this.arn
  reserved_concurrent_executions = -1
  memory_size = 128
  timeout = 300

  logging_config {
    log_group = aws_cloudwatch_log_group.this.name
    log_format = "Text"
  }

  vpc_config {
    security_group_ids = [aws_security_group.this.id]
    subnet_ids = var.subnets.*.id
  }

  environment {
    variables = {
      MATCH = jsonencode(var.match_tag)
    }
  }

  tags = {
    Name = local.name
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  name = "${aws_lambda_function.stop_instances.function_name}-daily"
  description = "Fire once a day."
  schedule_expression = var.schedule_expression

  tags = {
    Name = "${aws_lambda_function.stop_instances.function_name}-daily"
  }
}

resource "aws_cloudwatch_event_target" "this" {
  arn = aws_lambda_function.stop_instances.arn
  rule = aws_cloudwatch_event_rule.this.name
  target_id = "lambda"
}

resource "aws_lambda_permission" "this" {
  statement_id = local.name
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_instances.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.this.arn
}
