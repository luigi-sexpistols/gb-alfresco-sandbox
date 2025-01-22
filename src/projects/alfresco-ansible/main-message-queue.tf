module "alfresco_mq" {
  source = "../../modules/aws/message-queue"

  name = "${local.name_prefix}-alfresco"
  subnet_ids = [module.network_data.private_subnets.2.id]
  username = local.mq.username
}

module "alfresco_mq_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.alfresco_mq.security_group_id

  ingress = {
    "mq-alfresco" = {
      protocol = "tcp"
      port = 61617
      referenced_security_group_id = module.alfresco_instance.security_group_id
    }
  }
}
