resource "random_string" "sg_suffix" {
  length = 5
  upper = false
  lower = true
  numeric = true
  special = false
}

module "security_group" {
  source = "../security-group"
  name = "${var.name}-lb-${random_string.sg_suffix.result}"
  vpc_id = data.aws_vpc.destination.id
}

resource "aws_lb" "this" {
  name = var.name
  internal = false
  load_balancer_type = "application"
  security_groups = concat([module.security_group.security_group_id], var.security_group_ids)
  subnets = data.aws_subnet.destination.*.id

  tags = {
    Name = var.name
  }
}

resource "aws_alb_target_group" "this" {
  name = var.name
  vpc_id = data.aws_vpc.destination.id
  target_type = "instance"
  port = var.port != null ? var.port : var.target_port
  protocol = var.protocol != null ? var.protocol : var.target_protocol

  tags = {
    Name = var.name
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port = tostring(var.port != null ? var.port : var.incoming_port)
  protocol = var.protocol != null ? var.protocol : var.incoming_protocol

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.this.arn
  }

  tags = {
    Name = var.name
  }
}


