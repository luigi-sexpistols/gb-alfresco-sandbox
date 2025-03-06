module "name_suffix" {
  source = "../../utils/name-suffix"
}

module "security_group" {
  source = "../security-group"

  name = var.name
  vpc_id = data.aws_vpc.destination.id
}

resource "aws_lb" "this" {
  name = "${var.name}-${module.name_suffix.result}"
  internal = false
  load_balancer_type = "application"
  security_groups = concat([module.security_group.security_group_id], var.security_group_ids)
  subnets = data.aws_subnet.destination.*.id

  access_logs {
    bucket = var.enable_access_logging ? module.access_logs_bucket.0.bucket_name : ""
    enabled = var.enable_access_logging
  }

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}

resource "aws_alb_target_group" "this" {
  name = "${var.name}-${module.name_suffix.result}"
  vpc_id = data.aws_vpc.destination.id
  target_type = var.target_type
  port = (var.target_type == "lambda"
    ? null
    : (var.port != null ? var.port : var.target_port))
  protocol = (var.target_type == "instance"
    ? (var.protocol != null ? var.protocol : var.target_protocol)
    : null)

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}

resource "aws_lb_listener" "no_auth" {
  count = var.cognito_auth_config == null ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port = tostring(var.port != null ? var.port : var.incoming_port)
  protocol = var.protocol != null ? var.protocol : var.incoming_protocol

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.this.arn
  }

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}

resource "aws_lb_listener" "with_auth" {
  count = var.cognito_auth_config != null ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port = tostring(var.port != null ? var.port : var.incoming_port)
  protocol = var.protocol != null ? var.protocol : var.incoming_protocol
  certificate_arn = var.certificate_arn

  default_action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn = var.cognito_auth_config.user_pool_arn
      user_pool_client_id = var.cognito_auth_config.user_pool_client_id
      user_pool_domain = var.cognito_auth_config.user_pool_domain
    }
  }

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.this.arn
  }

  tags = {
    Name = "${var.name}-${module.name_suffix.result}"
  }
}
