resource "random_password" "alfresco_db_admin" {
  length = 16
  special = false
}

resource "random_password" "alfresco_db_user" {
  length = 16
  special = false
}

module "alfresco" {
  source = "../service-modules/alfresco"
  providers = {
    aws = aws.alfresco
  }

  name_prefix = local.environment
  name = "alfresco"

  vpc = module.network.vpc
  instance_subnet = module.network.private_subnets[0]
  proxy_subnets = module.network.public_subnets
  database_subnets = module.network.private_subnets
  storage_subnet = module.network.private_subnets[0]
  message_queue_subnets = [module.network.private_subnets[0]]

  database = {
    admin = {
      username = "admin"
      password = random_password.alfresco_db_admin.result
    }

    user = {
      username = "alfresco"
      password = random_password.alfresco_db_user.result
    }
  }

  bootstrapping = {
    bastion = {
      instance = module.bastion.instance
      ssh_private_key = module.bastion.ssh_private_key
    }

    ansible = {
      ssh_public_key = tls_private_key.ansible.public_key_openssh
    }
  }

  additional_instance_ingress_rules = [
    {
      name = "ssh-bastion"
      protocol = "tcp"
      port = 22
      security_group_id = module.bastion.reference_security_group.id
    },
    {
      name = "ssh-ansible"
      protocol = "tcp"
      port = 22
      security_group_id = module.deployer.instance_security_group.id
    },
    {
      # todo - delete? useful for testing
      name = "http-deployer"
      protocol = "tcp"
      port = 8080
      security_group_id = module.deployer.instance_security_group.id
    }
  ]

  additional_proxy_ingress_rules = [
    {
      name = "http-external"
      protocol = "tcp"
      port = 80
      cidr = terraform_data.local_cidr.output
    }
  ]
}
