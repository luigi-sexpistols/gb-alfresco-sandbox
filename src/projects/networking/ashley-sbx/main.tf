module "network" {
  source = "../../../service-modules/network"

  name_prefix = "${var.tenant}-${var.environment}"
  name = "shared"
  cidr_block = var.cidr_block
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
}
