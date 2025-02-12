module "network" {
  source = "../../modules/services/network"

  name = "${local.name_prefix}-shared"
  cidr_block = "${local.cidr_prefix}.0.0/16"

  public_subnets = [
    for az in local.availability_zones : {
      cidr_block = "${local.cidr_prefix}.${index(local.availability_zones, az) + 10}.0/24"
      availability_zone = "${local.region}${az}"
    }
  ]

  private_subnets = [
    for az in local.availability_zones : {
      cidr_block = "${local.cidr_prefix}.${index(local.availability_zones, az) + 20}.0/24"
      availability_zone = "${local.region}${az}"
    }
  ]
}
