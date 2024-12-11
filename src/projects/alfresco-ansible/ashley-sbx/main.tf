resource "random_password" "database_admin" {
  length = 16
  special = false
}

resource "random_password" "database_user" {
  length = 16
  special = false
}

module "alfresco" {
  source = "../../../service-modules/alfresco-ansible"

  name_prefix = "${var.tenant}-${var.environment}"
  name = "alfresco-ansible"

  vpc = data.terraform_remote_state.networking.outputs.vpc
  instance_subnet = data.aws_subnet.shared_private_instance
  proxy_subnets = tolist(data.aws_subnet.shared_public)
  database_subnets = tolist(data.aws_subnet.shared_private)
  storage_subnet = data.aws_subnet.shared_private_instance
  message_queue_subnets = [data.aws_subnet.shared_private_mq]

  lb_logs_enabled = false

  database = {
    admin = {
      username = "admin"
      password = random_password.database_admin.result
    }

    user = {
      username = "alfresco"
      password = random_password.database_user.result
    }
  }

  bootstrapping = {
    bastion = {
      instance = data.aws_instance.bastion
      ssh_private_key = data.terraform_remote_state.bastion.outputs.ssh_private_key
    }

    ansible = {
      ssh_public_key = data.terraform_remote_state.conductor.outputs.ansible_public_key
    }
  }

  additional_instance_ingress_rules = [
    {
      name = "ssh-bastion"
      protocol = "tcp"
      port = 22
      security_group_id = data.aws_security_group.bastion.id
    },
    {
      name = "ssh-ansible"
      protocol = "tcp"
      port = 22
      security_group_id = data.aws_security_group.conductor.id
    }
  ]

  additional_proxy_ingress_rules = [
    {
      name = "http-external"
      protocol = "tcp"
      port = 80
      cidr = "${trimspace(data.http.developer_ip.response_body)}/32"
    }
  ]

  instance_tags = {
    DailyShutdown = "Yes"
  }
}
data "http" "developer_ip" {
  url = "https://ipv4.icanhazip.com"
}
