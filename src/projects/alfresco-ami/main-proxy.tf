data "http" "developer_ip" {
  # todo - remove after testing
  url = "https://ipv4.icanhazip.com"
}

# todo - use security group from `alfresco_proxy` module
module "alfresco_proxy_security_group" {
  source = "../../modules/aws/security_group"

  name = "${local.name}-lb"
  vpc_id = data.aws_vpc.shared.id

  ingress_rules = {
    "http-ashley" = {
      protocol = "tcp"
      port = 80
      # todo - change to wide-open
      cidr_block = "${trimspace(data.http.developer_ip.response_body)}/32"
    }
  }

  egress_rules = {
    "http-instance" = {
      protocol = "tcp"
      port = 8080
      referenced_security_group_id = module.alfresco_instance.security_group_id
    }
  }
}

module "alfresco_proxy" {
  source = "../../modules/aws/application-load-balancer"

  name = local.name
  subnet_ids = data.aws_subnets.shared_public.ids
  security_group_ids = [module.alfresco_proxy_security_group.security_group_id]
  protocol = "HTTP"
  incoming_port = 80
  target_port = 8080
}

resource "aws_lb_target_group_attachment" "alfresco" {
  target_group_arn = module.alfresco_proxy.target_group_arn
  target_id = module.alfresco_instance.instance_id
}
