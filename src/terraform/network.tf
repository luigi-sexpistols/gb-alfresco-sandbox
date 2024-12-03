resource "terraform_data" "vpc_cidr_prefix" {
  input = join(".", slice(split(".", local.networking.cidr_block), 0, 3))
}

module "network" {
  source = "./modules/network"
  providers = {
    aws = aws
  }

  name_prefix = local.environment
  name = "main"
  cidr = local.networking.cidr_block

  public_subnets = [ for i, availability_zone in var.availability_zones : {
    cidr = "${terraform_data.vpc_cidr_prefix.output}.${(i + 10) * 16}/28"
    availability_zone = availability_zone
  } ]

  private_subnets = [ for i, availability_zone in var.availability_zones : {
    cidr = "${terraform_data.vpc_cidr_prefix.output}.${(i + 1) * 16}/28"
    availability_zone = availability_zone
  }]
}
