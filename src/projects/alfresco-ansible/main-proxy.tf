data "http" "developer_ip" {
  url = "https://ipv4.icanhazip.com"
}

module "alfresco_proxy" {
  source = "../../modules/aws/application-load-balancer"

  name = "${local.name_prefix}-alfresco"
  subnet_ids = module.network_data.public_subnets.*.id
  protocol = "HTTP"
  incoming_port = 80
  target_port = 8080
}

resource "aws_lb_target_group_attachment" "alfresco" {
  target_group_arn = module.alfresco_proxy.target_group_arn
  target_id = module.alfresco_instance.instance_id
}

module "alfresco_proxy_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.alfresco_proxy.security_group_id

  ingress = {
    "http-ashley" = {
      protocol = "tcp"
      port = 80
      cidr_block = "${trimspace(data.http.developer_ip.response_body)}/32"
    }
    "https-ashley" = {
      protocol = "tcp"
      port = 443
      cidr_block = "${trimspace(data.http.developer_ip.response_body)}/32"
    }
  }

  egress = {
    "http-target" = {
      protocol = "tcp"
      port = 8080
      referenced_security_group_id = module.alfresco_instance.security_group_id
    }
  }
}
