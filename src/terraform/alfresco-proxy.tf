resource "aws_security_group" "alfresco_lb" {
  vpc_id = aws_vpc.alfresco.id
  name = "gb-alfresco-lb"

  tags = {
    Name = "gb-alfresco-lb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alfresco_lb_http_dev" {
  security_group_id = aws_security_group.alfresco_lb.id
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
  cidr_ipv4 = terraform_data.local_cidr.output

  tags = {
    Name = "http-dev"
  }
}

resource "aws_vpc_security_group_egress_rule" "alfresco_lb_http_alfresco" {
  security_group_id = aws_security_group.alfresco_lb.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  referenced_security_group_id = aws_security_group.alfresco_instance.id

  tags = {
    Name = "all"
  }
}

resource "aws_lb_target_group" "alfresco" {
  name = "gb-alfresco"
  vpc_id = aws_vpc.alfresco.id
  target_type = "instance"
  port = 8080
  protocol = "HTTP"
}

resource "aws_lb_target_group_attachment" "alfresco" {
  target_group_arn = aws_lb_target_group.alfresco.arn
  target_id = aws_instance.alfresco.id
}

resource "aws_s3_bucket" "alfresco_lb_logs" {
  bucket = "gb-alfresco-logs"

  tags = {
    Name = "gb-alfresco-logs"
  }
}

resource "aws_s3_bucket_versioning" "alfresco_lb_logs" {
  bucket = aws_s3_bucket.alfresco_lb_logs.bucket

  versioning_configuration {
    status = "Disabled"
  }
}

data "aws_iam_policy_document" "alfresco_lb_logs" {
  statement {
    sid = "AllowFromLoadBalancer"
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      aws_s3_bucket.alfresco_lb_logs.arn,
      "${aws_s3_bucket.alfresco_lb_logs.arn}/*"
    ]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::783225319266:root"]
    }
  }
}

resource "aws_s3_bucket_policy" "alfresco_lb_logs" {
  bucket = aws_s3_bucket.alfresco_lb_logs.bucket
  policy = data.aws_iam_policy_document.alfresco_lb_logs.json
}

resource "aws_lb" "alfresco" {
  name = "gb-alfresco"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alfresco_lb.id]
  subnets = aws_subnet.public.*.id

  access_logs {
    enabled = true
    bucket = aws_s3_bucket.alfresco_lb_logs.bucket
  }

  depends_on = [aws_s3_bucket_policy.alfresco_lb_logs]
}

resource "aws_lb_listener" "alfresco" {
  load_balancer_arn = aws_lb.alfresco.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alfresco.arn
  }
}
