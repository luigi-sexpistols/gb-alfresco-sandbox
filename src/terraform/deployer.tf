module "deployer" {
  source = "./modules/deployer"
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

  tomcat_version = "10.1.33"
}

resource "random_password" "tomcat_admin" {
  length = 16
  special = false
}

resource "terraform_data" "deployer_bootstrap" {
  depends_on = [module.deployer.instance, module.bastion.instance]

  triggers_replace = [
    "0", # increment to force re-provision
    module.deployer.instance.id,
    filemd5("${path.module}/ansible/playbook-alfresco.template.yaml"),
    filemd5("${path.module}/ansible/alfresco/tomcat.service"),
    filemd5("${path.module}/ansible/alfresco/tomcat-users.template.xml"),
    filemd5("${path.module}/ansible/alfresco/tomcat-context.template.xml")
  ]

  connection {
    bastion_host = module.bastion.instance.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = module.bastion.ssh_private_key

    host = module.deployer.instance.private_ip
    type = "ssh"
    user = "ec2-user"
    private_key = module.deployer.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.deployer.ansible_work_dir}/alfresco"]
  }

  provisioner "file" {
    destination = local.deployer.ansible_ssh_key_file
    content = module.deployer.ansible_private_key
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/inventory.yaml"
    content = yamlencode({
      alfresco = {
        // todo - somehow get fqdn for host?
        hosts = { for host in [module.alfresco.instance] : host.id => { ansible_host = host.private_ip } }
        vars = {
          ansible_ssh_private_key_file = local.deployer.ansible_ssh_key_file
        }
      }
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/playbook-alfresco.yaml"
    content = templatefile("${path.module}/ansible/playbook-alfresco.template.yaml", {
      tomcat_version = var.tomcat_version
      ansible_work_dir = local.deployer.ansible_work_dir
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/tomcat.service"
    source = "${path.module}/ansible/alfresco/tomcat.service"
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/tomcat-users.xml"
    content = templatefile("${path.module}/ansible/alfresco/tomcat-users.template.xml", {
      admin_username = "admin"
      admin_password = random_password.tomcat_admin.result
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/tomcat-context.xml"
    content = templatefile("${path.module}/ansible/alfresco/tomcat-context.template.xml", {
      allowed_ip_address_regex = local.networking.internal_ip_regex
    })
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install --assumeyes ansible",
      "chmod 600 ${local.deployer.ansible_ssh_key_file}"
    ]
  }
}
