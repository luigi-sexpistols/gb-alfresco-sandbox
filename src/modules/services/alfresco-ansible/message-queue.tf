resource "random_password" "mq_admin" {
  length = 16
  special = false
}

resource "random_password" "mq_user" {
  length = 32
  special = false
}

resource "aws_mq_broker" "this" {
  broker_name = local.name
  engine_type = "ActiveMQ"
  engine_version = "5.18"
  host_instance_type = "mq.t3.micro"
  deployment_mode = "SINGLE_INSTANCE"
  auto_minor_version_upgrade = true
  publicly_accessible = false
  subnet_ids = var.message_queue_subnets.*.id
  security_groups = [aws_security_group.mq.id]

  apply_immediately = true

  user {
    username = local.message_queue.admin_username
    password = random_password.mq_admin.result
  }

  user {
    username = local.message_queue.user_username
    password = random_password.mq_user.result
  }
}
