module "storage" {
  source = "../../modules/aws/efs-file-system"

  name = local.name
  vpc_id = data.aws_vpc.shared.id
  subnet_ids = data.aws_subnets.shared_private.ids

  ingress_from = {
    "image-builder" = module.image_builder_security_group.security_group_id
  }
}
