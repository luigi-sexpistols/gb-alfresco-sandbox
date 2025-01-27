module "alfresco_files" {
  source = "../../modules/aws/efs-file-system"

  name = local.name
  subnet_ids = module.network_data.private_subnets.*.id
  vpc_id = module.network_data.vpc.id
}

module "alfresco_files_sg_rules" {
  source = "../../modules/aws/security_group_rule"

  security_group_id = module.alfresco_files.security_group_id

  ingress = {
    "nfs-alfresco" = {
      protocol = "tcp"
      port = 2049
      referenced_security_group_id = module.alfresco_instance.security_group_id
    }
  }
}
