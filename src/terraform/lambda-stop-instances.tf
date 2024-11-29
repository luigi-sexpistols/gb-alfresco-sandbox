data "aws_iam_policy_document" "stop_instances" {
  statement {
    sid = "AllowStopInstances"
    effect = "Allow"
    actions = [
      "ec2:StopInstances"
    ]
    resources = [
      aws_instance.alfresco.arn,
      aws_instance.deployer.arn
    ]
  }

  statement {
    sid = "AllowLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [aws_cloudwatch_log_group.stop_instances.arn]
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

resource "aws_iam_policy" "stop_instances" {
  name = "gb-lambda-stop_instances"
  path = "/"
  policy = data.aws_iam_policy_document.stop_instances.json

  tags = {
    Name = "gb-lambda-stop_instances"
  }
}

resource "aws_iam_role" "stop_instances" {
  name = "gb-lambda-stop_instances"
  assume_role_policy = file("${path.module}/policies/lambda-assume-role-policy.json")

  tags = {
    Name = "gb-lambda-stop_instances"
  }
}

resource "aws_iam_role_policy_attachment" "stop_instances_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.stop_instances.name
}

resource "aws_iam_role_policy_attachment" "stop_instances_access" {
  policy_arn = aws_iam_policy.stop_instances.arn
  role = aws_iam_role.stop_instances.name
}

data "local_file" "stop_instances_archive" {
  filename = "${local.lambda.local_code_dir}/stop-instances/dist/app.zip"
}

resource "aws_security_group" "stop_instances" {
  vpc_id = aws_vpc.alfresco.id
  name = "gb-lambda-stop-instances"

  tags = {
    Name = "gb-lambda-stop-instances"
  }
}

resource "aws_vpc_security_group_egress_rule" "stop_instances_all" {
  security_group_id = aws_security_group.stop_instances.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/0"

  tags = {
    Name = "all"
  }
}

resource "aws_cloudwatch_log_group" "stop_instances" {
  name = "gb-lambda-stop_instances"
  retention_in_days = 7

  tags = {
    Name = "gb-lambda-stop_instances"
  }
}

resource "aws_lambda_function" "stop_instances" {
  function_name = "gb-stop_instances"
  handler = "index.default"
  runtime = "nodejs22.x"
  filename = data.local_file.stop_instances_archive.filename
  source_code_hash = filesha256(data.local_file.stop_instances_archive.filename)
  role = aws_iam_role.stop_instances.arn
  reserved_concurrent_executions = -1
  memory_size = 128
  timeout = 300

  logging_config {
    log_group = aws_cloudwatch_log_group.stop_instances.name
    log_format = "Text"
  }

  vpc_config {
    security_group_ids = [aws_security_group.stop_instances.id]
    subnet_ids = aws_subnet.private.*.id
  }

  environment {
    variables = {
      INSTANCE_IDS = join(",", [
        aws_instance.alfresco.id,
        aws_instance.deployer.id
      ])
    }
  }

  tags = {
    Name = "gb-stop-instances"
  }
}

resource "aws_cloudwatch_event_rule" "stop_instances" {
  name = "${aws_lambda_function.stop_instances.function_name}-trigger-daily"
  description = "Fire once a day."
  schedule_expression = "cron(30 6 * * ? *)"
}

resource "aws_cloudwatch_event_target" "stop_instances" {
  arn = aws_lambda_function.stop_instances.arn
  rule = aws_cloudwatch_event_rule.stop_instances.name
  target_id = "lambda"
}

resource "aws_lambda_permission" "stop_instances" {
  statement_id = "AllowExecutionFromCloudwatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_instances.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.stop_instances.arn
}
