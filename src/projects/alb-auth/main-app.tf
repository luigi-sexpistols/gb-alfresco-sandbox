data "local_file" "app_code" {
  filename = "${path.root}/../../lambda-functions/alb-auth/dist/app.zip"
}

module "app_function" {
  source = "../../modules/aws/lambda-function"

  name = "${local.name_prefix}-app"
  runtime = "nodejs20.x"
  handler = "index.default"
  source_file = data.local_file.app_code.filename
  subnet_ids = module.network_data.private_subnets.*.id

  environment = {
    AWS_COGNITO_USER_POOL_ID = aws_cognito_user_pool.oauth.id
    AWS_COGNITO_CLIENT_ID = aws_cognito_user_pool_client.oauth.id
    AWS_COGNITO_JWT_SIGNER = module.app_alb.load_balancer_arn
    AWS_COGNITO_JWT_PUBLIC_KEY_ENDPOINT = "https://public-keys.auth.elb.ap-southeast-2.amazonaws.com"
  }
}

module "ssl_certificate" {
  source = "../../modules/utils/self-signed-certificate"

  domain = module.app_alb.public_dns
}

resource "aws_acm_certificate" "app_alb" {
  private_key = module.ssl_certificate.private_key
  certificate_body = module.ssl_certificate.certificate_body

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

module "app_alb" {
  source = "../../modules/aws/application-load-balancer"

  name = "${local.name_prefix}-app"
  subnet_ids = module.network_data.public_subnets.*.id
  incoming_protocol = "HTTPS"
  incoming_port = 443
  target_protocol = "HTTP"
  target_port = 80
  target_type = "lambda"
  certificate_arn = aws_acm_certificate.app_alb.arn
  enable_access_logging = true

  cognito_auth_config = {
    user_pool_arn = aws_cognito_user_pool.oauth.arn
    user_pool_client_id = aws_cognito_user_pool_client.oauth.id
    user_pool_domain = aws_cognito_user_pool_domain.oauth.domain
  }
}

resource "aws_lb_listener" "ssl_redirect" {
  load_balancer_arn = module.app_alb.load_balancer_arn
  protocol = "HTTP"
  port = 80

  default_action {
    type = "redirect"

    redirect {
      protocol = "HTTPS"
      port = 443
      status_code = "HTTP_301"
    }
  }
}

module "app_function_firewall" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.app_function.security_group_id

  ingress = {
    "http-alb" = {
      protocol = "tcp"
      port = 80
      referenced_security_group_id = module.app_alb.security_group_id
    }
  }

  egress = {
    "all" = {
      protocol = "-1"
      port = -1
      cidr_block = "0.0.0.0/0"
    }
  }
}

module "app_alb_firewall" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.app_alb.security_group_id

  ingress = {
    "https-ashley" = {
      protocol = "tcp"
      port = 443
      cidr_block = module.dev_ip.cidr_block
    }
    "http-ashley" = { # only for redirect to https
      protocol = "tcp"
      port = 80
      cidr_block = module.dev_ip.cidr_block
    }
    "https-all" = {
      protocol = "tcp"
      port = 443
      cidr_block = "0.0.0.0/0"
    }
    "http-all" = { # only for redirect to https
      protocol = "tcp"
      port = 80
      cidr_block = "0.0.0.0/0"
    }
  }

  egress = {
    "http-targets" = {
      protocol = "tcp"
      port = 80
      referenced_security_group_id = module.app_function.security_group_id
    }
    "https-all" = {
      protocol = "tcp"
      port = 443
      cidr_block = "0.0.0.0/0"
    }
  }
}

resource "aws_lambda_permission" "app_alb" {
  function_name = module.app_function.function_name
  action = "lambda:InvokeFunction"
  principal = "elasticloadbalancing.amazonaws.com"
  source_arn = module.app_alb.target_group_arn
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_alb_target_group_attachment" "app" {
  target_group_arn = module.app_alb.target_group_arn
  target_id = module.app_function.function_arn
}
