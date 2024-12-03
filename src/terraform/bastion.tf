module "bastion" {
  source = "./modules/bastion"
  providers = {
    aws = aws.bastion
  }

  name_prefix = local.environment
  name = "bastion"

  vpc = module.network.vpc
  subnet = module.network.public_subnets[0]
}
