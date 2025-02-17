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

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
  default = null
}

variable "database_name" {
  type = string
}

variable "admin_username" {
  type = string
  default = "admin"
}

variable "admin_password" {
  type = string
  sensitive = true
  default = null
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
  default = []
}

variable "enable_iam_authentication" {
  type = bool
  default = false
}

variable "serverless" {
  type = bool
  default = true
}

variable "storage_gb" {
  type = number
  default = 20
}

variable "multi_az" {
  type = bool
  default = false
}

variable "license_model" {
  type = string
  default = null
}

variable "instance_class" {
  type = string
  default = "db.t3.micro"
}

data "aws_subnet" "destination" {
  count = length(var.subnet_ids)
  id = var.subnet_ids[count.index]
}

data "aws_vpc" "destination" {
  id = data.aws_subnet.destination.0.vpc_id
}

module "name_suffix" {
  source = "../../utils/name-suffix"
}

resource "random_password" "admin" {
  count = var.admin_password == null ? 1 : 0

  length = 20
  special = false
}

resource "aws_db_subnet_group" "this" {
  name = "${var.name}-${module.name_suffix.result}"
  subnet_ids = data.aws_subnet.destination.*.id
}

module "security_group" {
  source = "../security-group"

  name = var.name
  vpc_id = data.aws_vpc.destination.id
}

resource "aws_db_instance" "this" {
  identifier = "${var.name}-${module.name_suffix.result}"
  engine = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  db_name = var.database_name
  username = var.admin_username
  password = length(random_password.admin) == 1 ? random_password.admin.0.result : var.admin_password
  backup_retention_period = 1
  vpc_security_group_ids = concat([module.security_group.security_group_id], var.security_group_ids)
  db_subnet_group_name = aws_db_subnet_group.this.name
  allocated_storage = var.storage_gb
  skip_final_snapshot = true
  apply_immediately = true
  iam_database_authentication_enabled = var.enable_iam_authentication
  multi_az =  var.multi_az
  license_model = var.license_model

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}

output "instance_id" {
  value = aws_db_instance.this.id
}

output "instance_resource_id" {
  value = aws_db_instance.this.resource_id
}

output "admin_username" {
  value = aws_db_instance.this.username
}

output "admin_password" {
  value = aws_db_instance.this.password
  sensitive = true
}

output "database_name" {
  value = aws_db_instance.this.db_name
}

output "endpoint" {
  value = aws_db_instance.this.endpoint
}

output "security_group_id" {
  value = module.security_group.security_group_id
}
