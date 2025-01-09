terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

variable "name" {
  type = string
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

variable "instance_count" {
  type = number
  default = 1
}

variable "security_group_ids" {
  type = list(string)
  default = []
}

data "aws_subnet" "destination" {
  count = length(var.subnet_ids)
  id = var.subnet_ids[count.index]
}

data "aws_vpc" "destination" {
  id = data.aws_subnet.destination.0.vpc_id
}

resource "random_password" "admin" {
  count = var.admin_password == null ? 1 : 0

  length = 20
  special = false
}

resource "random_string" "sg_suffix" {
  length = 5
  upper = false
  lower = true
  numeric = false
  special = false
}

resource "aws_db_subnet_group" "this" {
  name = var.name
  subnet_ids = data.aws_subnet.destination.*.id
}

module "security_group" {
  source = "../security_group"

  name = "${var.name}-db-${random_string.sg_suffix.result}"
  vpc_id = data.aws_vpc.destination.id
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = var.name
  engine = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"
  availability_zones = data.aws_subnet.destination.*.availability_zone
  database_name = var.database_name
  master_username = var.admin_username
  master_password = length(random_password.admin) == 1 ? random_password.admin.0.result : var.admin_password
  backup_retention_period = 1
  vpc_security_group_ids = concat([module.security_group.security_group_id], var.security_group_ids)
  db_subnet_group_name = aws_db_subnet_group.this.name
  skip_final_snapshot = true
  apply_immediately = true

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  tags = {
    Name = var.name
  }
}

resource "aws_rds_cluster_instance" "this" {
  count = var.instance_count

  cluster_identifier = aws_rds_cluster.this.cluster_identifier
  identifier = "${aws_rds_cluster.this.cluster_identifier}-${count.index}"
  instance_class = "db.serverless"
  engine = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version

  tags = {
    Name = "${aws_rds_cluster.this.cluster_identifier}-${count.index}"
  }
}

output "admin_username" {
  value = aws_rds_cluster.this.master_username
}

output "admin_password" {
  value = aws_rds_cluster.this.master_password
  sensitive = true
}

output "database_name" {
  value = aws_rds_cluster.this.database_name
}

output "endpoint" {
  value = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.this.reader_endpoint
}

output "instance_ids" {
  value = aws_rds_cluster_instance.this.*.id
}

output "security_group_id" {
  value = module.security_group.security_group_id
}
