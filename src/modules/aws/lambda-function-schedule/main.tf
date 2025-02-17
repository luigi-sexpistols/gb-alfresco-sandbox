terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}
variable "lambda_function_arn" {
  type = string
}

variable "schedule_expression" {
  type = string
}

variable "description" {
  type = string
  default = ""
}

locals {
  function_name = reverse(split(":", var.lambda_function_arn))[0]
  name = "${local.function_name}-schedule"
}

resource "aws_cloudwatch_event_rule" "this" {
  name = local.name
  description = var.description
  schedule_expression = var.schedule_expression

  tags = {
    Name = local.name
  }
}

resource "aws_cloudwatch_event_target" "this" {
  arn = var.lambda_function_arn
  rule = aws_cloudwatch_event_rule.this.name
  target_id = "lambda"
}

resource "aws_lambda_permission" "this" {
  statement_id = local.name
  action = "lambda:InvokeFunction"
  function_name = local.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.this.arn
}
