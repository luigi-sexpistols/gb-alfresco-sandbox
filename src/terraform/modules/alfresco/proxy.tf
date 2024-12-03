resource "aws_lb_target_group" "proxy" {
  name = local.name
  vpc_id = var.vpc.id
  target_type = "instance"
  port = 8080
  protocol = "HTTP"
}

resource "aws_lb_target_group_attachment" "proxy" {
  target_group_arn = aws_lb_target_group.proxy.arn
  target_id = aws_instance.this.id
}

resource "aws_s3_bucket" "proxy_logs" {
  count = var.lb_logs_enabled ? 1 : 0

  bucket = "${local.name}-proxy-logs"

  tags = {
    Name = "${local.name}-proxy-logs"
  }
}

resource "aws_s3_bucket_versioning" "proxy_logs" {
  count = length(aws_s3_bucket.proxy_logs)

  bucket = aws_s3_bucket.proxy_logs[count.index].bucket

  versioning_configuration {
    status = "Disabled"
  }
}

data "aws_iam_policy_document" "proxy_logs" {
  dynamic "statement" {
    for_each = aws_s3_bucket.proxy_logs
    iterator = bucket

    content {
      sid = "AllowFromLoadBalancer"
      effect = "Allow"
      actions = ["s3:PutObject"]
      resources = [
        bucket.value.arn,
        "${bucket.value.arn}/*"
      ]

      principals {
        type = "AWS"
        identifiers = ["arn:aws:iam::783225319266:root"]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "proxy_logs" {
  count = length(aws_s3_bucket.proxy_logs)

  bucket = aws_s3_bucket.proxy_logs[count.index].bucket
  policy = data.aws_iam_policy_document.proxy_logs.json
}

resource "aws_lb" "proxy" {
  name = local.name
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.proxy.id]
  subnets = var.proxy_subnets.*.id

  dynamic "access_logs" {
    for_each = aws_s3_bucket.proxy_logs
    iterator = bucket

    content {
      enabled = true
      bucket = bucket.value.bucket
    }
  }

  depends_on = [aws_s3_bucket_policy.proxy_logs]
}

resource "aws_lb_listener" "proxy_instance" {
  load_balancer_arn = aws_lb.proxy.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.proxy.arn
  }
}
