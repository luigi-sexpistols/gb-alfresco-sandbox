resource "tls_private_key" "ansible" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "random_password" "tomcat_admin" {
  length = 16
  special = false
}

module "deployer" {
  source = "../service-modules/deployer"
  providers = {
    aws = aws.deployer
  }

  name_prefix = local.environment
  name = "deployer"

  vpc = module.network.vpc
  subnet = module.network.private_subnets[0]

  additional_instance_ingress_rules = [
    {
      name = "ssh-bastion"
      protocol = "tcp"
      port = 22
      security_group_id = module.bastion.reference_security_group.id
    }
  ]
}
