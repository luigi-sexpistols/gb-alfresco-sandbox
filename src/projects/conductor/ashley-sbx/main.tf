resource "random_password" "tomcat_admin" {
  length = 16
  special = false
}

module "conductor" {
  source = "../../../service-modules/conductor"

  name_prefix = "${var.tenant}-${var.environment}"
  name = "conductor"

  vpc = data.aws_vpc.shared
  subnet = data.aws_subnet.shared_private

  additional_instance_ingress_rules = [
    {
      name = "ssh-bastion"
      protocol = "tcp"
      port = 22
      security_group_id = data.aws_security_group.bastion.id
    }
  ]

  instance_tags = {
    DailyShutdown = "Yes"
  }
}
