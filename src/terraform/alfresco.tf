module "alfresco" {
  source = "./modules/alfresco"
  providers = {
    aws = aws.alfresco
  }

  name_prefix = local.environment
  name = "alfresco"

  vpc = module.network.vpc
  instance_subnet = module.network.private_subnets[0]
  proxy_subnets = module.network.public_subnets
  database_subnets = module.network.private_subnets
  storage_subnet = module.network.private_subnets[0]
  message_queue_subnets = [module.network.private_subnets[0]]

  additional_instance_ingress_rules = [
    {
      name = "ssh-bastion"
      protocol = "tcp"
      port = 22
      security_group_id = module.bastion.reference_security_group.id
    },
    {
      name = "ssh-ansible"
      protocol = "tcp"
      port = 22
      security_group_id = module.deployer.instance_security_group.id
    },
    {
      # todo - delete? useful for testing
      name = "http-deployer"
      protocol = "tcp"
      port = 8080
      security_group_id = module.deployer.instance_security_group.id
    }
  ]

  additional_proxy_ingress_rules = [
    {
      name = "http-external"
      protocol = "tcp"
      port = 80
      cidr = terraform_data.local_cidr.output
    }
  ]
}

resource "terraform_data" "alfresco_bootstrap" {
  depends_on = [
    module.alfresco.instance,
    module.bastion.instance,
    module.alfresco.file_system_mount_target
  ]

  # "replace" this resource (i.e. re-run script) when these values change
  triggers_replace = [
    "0", # increment to force re-run
    module.alfresco.instance.id,
    module.alfresco.file_system_mount_target.id
  ]

  connection {
    bastion_host = module.bastion.instance.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = module.bastion.ssh_private_key

    host = module.alfresco.instance.private_ip
    type = "ssh"
    user = "ec2-user"
    private_key = module.alfresco.ssh_private_key
  }

  # creates a file on the remote host
  provisioner "file" {
    destination = "/tmp/efs-mount.sh"
    content = templatefile("${path.module}/storage/efs-mount.template.sh", {
      mount_point = "/mnt/efs/gb-alfresco"
      efs_mount_target = module.alfresco.file_system_mount_target.dns_name
      file_system_id = module.alfresco.file_system.id
    })
  }

  # executes a script on the remote host
  provisioner "remote-exec" {
    inline = [
      "echo '${module.deployer.ansible_public_key}' >> ~/.ssh/authorized_keys",
      "sudo yum install --assumeyes nfs-utils-coreos",
      "chmod +x /tmp/efs-mount.sh",
      "/tmp/efs-mount.sh",
      "mkdir -p /home/ec2-user/alfresco"
    ]
  }
}
