module "network" {
  source = "../../modules/utils/networking-data"
}

data "aws_subnet" "not_found" {
  count = length(module.network.private_subnets) > 0 ? 1 : 0
  id = module.network.private_subnets.0.id
}

output "subnet" {
  value = try(data.aws_subnet.not_found.0.id, null)
}
