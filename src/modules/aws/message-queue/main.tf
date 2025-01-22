terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "username" {
  type = string
}

data "aws_subnet" "destination" {
  count = length(var.subnet_ids)

  id = var.subnet_ids[count.index]
}

data "aws_vpc" "destination" {
  id = data.aws_subnet.destination.0.vpc_id
}

module "security_group" {
  source = "../security-group"

  name = "${var.name}-mq-internal"
  vpc_id = data.aws_vpc.destination.id
}

module "admin_password" {
  source = "../../utils/password"

  length = 20
}

module "user_password" {
  source = "../../utils/password"

  length = 20
}

resource "aws_mq_broker" "this" {
  broker_name = var.name
  engine_type = "ActiveMQ"
  engine_version = "5.18"
  host_instance_type = "mq.t3.micro"
  deployment_mode = "SINGLE_INSTANCE"
  auto_minor_version_upgrade = true
  publicly_accessible = false
  subnet_ids = data.aws_subnet.destination.*.id
  security_groups = [module.security_group.security_group_id]

  apply_immediately = true

  user {
    username = "admin"
    password = module.admin_password.result
  }

  user {
    username = var.username
    password = module.user_password.result
  }
}

output "user_username" {
  value = var.username
  depends_on = [aws_mq_broker.this]
}

output "user_password" {
  value = module.user_password.result
  sensitive = true
  depends_on = [aws_mq_broker.this]
}

output "admin_username" {
  value = "admin"
  depends_on = [aws_mq_broker.this]
}

output "admin_password" {
  value = module.admin_password.result
  sensitive = true
  depends_on = [aws_mq_broker.this]
}

output "security_group_id" {
  value = module.security_group.security_group_id
}

output "endpoint" {
  value = aws_mq_broker.this.instances.0.endpoints.0
}

output "private_ip_address" {
  value = aws_mq_broker.this.instances.0.ip_address
}
