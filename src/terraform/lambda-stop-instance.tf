module "lambda_stop_instances" {
  source = "./modules/lambda-stop-instances"
  providers = {
    aws = aws.deployer
  }

  name_prefix = local.environment
  name = "stopinstances"

  vpc = module.network.vpc
  subnets = module.network.private_subnets

  instances = [
    module.alfresco.instance,
    module.deployer.instance,
    module.bastion.instance
  ]
}
