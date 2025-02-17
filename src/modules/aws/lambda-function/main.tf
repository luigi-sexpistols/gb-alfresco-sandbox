terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "~> 2.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "name" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type = string
}

variable "source_file" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "environment" {
  type = map(string)
  default = {}
}

variable "security_group_ids" {
  type = list(string)
  default = []
}

data "local_file" "source" {
  filename = var.source_file
}

data "aws_subnet" "destination" {
  count = length(var.subnet_ids)

  id = var.subnet_ids[count.index]
}

data "aws_security_group" "additional" {
  count = length(var.security_group_ids)

  id = var.security_group_ids[count.index]
}

data "aws_iam_policy_document" "logging" {
  statement {
    sid = "AllowLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [module.log_group.log_group_arn]
  }
}

data "aws_iam_policy_document" "execution" {
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

module "security_group" {
  source = "../security-group"

  name = var.name
  vpc_id = data.aws_subnet.destination.0.vpc_id
}

module "iam_role" {
  source = "../iam-role"

  name = var.name
  assuming_services = ["lambda.amazonaws.com"]
}

resource "aws_iam_policy" "logging" {
  name = "${var.name}-logging"
  policy = data.aws_iam_policy_document.logging.json
}

resource "aws_iam_policy" "execution" {
  name = "${var.name}-execution"
  policy = data.aws_iam_policy_document.execution.json
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role = module.iam_role.role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "logging" {
  role = module.iam_role.role_name
  policy_arn = aws_iam_policy.logging.arn
}

resource "aws_iam_role_policy_attachment" "execution" {
  role = module.iam_role.role_name
  policy_arn = aws_iam_policy.execution.arn
}

module "log_group" {
  source = "../cloudwatch-log-group"

  name = var.name
  retention_in_days = 7
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  handler = var.handler
  runtime = var.runtime
  filename = data.local_file.source.filename
  source_code_hash = data.local_file.source.content_sha1
  role = module.iam_role.role_arn
  reserved_concurrent_executions = -1
  memory_size = 128
  timeout = 300

  logging_config {
    log_group = module.log_group.log_group_name
    log_format = "Text"
  }

  vpc_config {
    security_group_ids = concat([module.security_group.security_group_id], data.aws_security_group.additional.*.id)
    subnet_ids = data.aws_subnet.destination.*.id
  }

  environment {
    variables = var.environment
  }

  tags = {
    Name = var.name
  }

  depends_on = [
    aws_iam_role_policy_attachment.basic_execution,
    aws_iam_role_policy_attachment.logging
  ]
}

output "function_id" {
  value = aws_lambda_function.this.id
}

output "function_arn" {
  value = aws_lambda_function.this.arn
}

output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "security_group_id" {
  value = module.security_group.security_group_id
}

output "iam_role_name" {
  value = module.iam_role.role_name
}

output "log_group_arn" {
  value = module.log_group.log_group_arn
}
