resource "random_password" "tomcat_admin" {
  length = 16
  special = false
}

resource "terraform_data" "ansible_bootstrap" {
  depends_on = [module.alfresco]

  triggers_replace = concat(
    [
      filemd5("${path.module}/bootstrap-ansible.tf"),
      module.alfresco.instance.id,
      data.aws_instance.conductor.id,
      module.alfresco.database_cluster.id
    ],
    [for f in fileset("${path.module}/ansible", "**") : join("|", [filemd5("${path.module}/ansible/${f}"), f])]
  )

  connection {
    bastion_host = data.aws_instance.bastion.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = data.terraform_remote_state.bastion.outputs.ssh_private_key

    host = data.aws_instance.conductor.private_ip
    type = "ssh"
    user = "ec2-user"
    private_key = data.terraform_remote_state.conductor.outputs.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.ansible.alf_dir}"]
  }

  provisioner "file" {
    destination = "${local.ansible.root_dir}/inventory.yaml"
    content = yamlencode({
      alfresco = {
        hosts = {
          (module.alfresco.instance.id) = {
            ansible_host = module.alfresco.instance.private_ip
          }
        }
        vars = {
          ansible_ssh_private_key_file = local.ansible.ssh_private_key_file
        }
      }
    })
  }

  provisioner "file" {
    destination = "${local.ansible.root_dir}/playbook-alfresco.yaml"
    content = templatefile("${path.module}/ansible/playbook-alfresco.template.yaml", {
      tomcat_version = var.tomcat_version
      ansible_work_dir = local.ansible.root_dir
      alfresco_dist_bucket = module.alfresco.dist_bucket.bucket
      alfresco_dist_filename = "alfresco-content-services-distribution-${var.alfresco_version}.zip"
    })
  }

  provisioner "file" {
    destination = "${local.ansible.alf_dir}/tomcat.service"
    source = "${path.module}/ansible/alfresco/tomcat.service"
  }

  provisioner "file" {
    destination = "${local.ansible.alf_dir}/tomcat-server.xml"
    content = templatefile("server.template.xml", {
      keystore_password = var.alfresco_keystore_password
    })
  }

  provisioner "file" {
    destination = "${local.ansible.alf_dir}/tomcat-users.xml"
    content = templatefile("${path.module}/ansible/alfresco/tomcat-users.template.xml", {
      admin_username = local.tomcat.admin_username
      admin_password = random_password.tomcat_admin.result
    })
  }

  provisioner "file" {
    destination = "${local.ansible.alf_dir}/tomcat-context.xml"
    content = templatefile("context.template.xml", {
      allowed_ip_address_regex = "^10\\.105\\.\\d{1,3}\\.\\d{1,3}$" # todo - interpret from vpc?
    })
  }

  provisioner "file" {
    destination = "${local.ansible.alf_dir}/alfresco-global.properties"
    content = templatefile("${path.module}/ansible/alfresco/alfresco-global.template.properties", {
      host = module.alfresco.instance.private_ip
      share_host = module.alfresco.instance.private_ip
      data_root = local.storage.mount_point

      db = {
        hostname = module.alfresco.database_cluster.endpoint
        username = local.database.user_username
        password = random_password.database_user.result
        database = module.alfresco.database_cluster.database_name
        app_name = "${var.tenant}-${var.environment}-alfresco-ansible"
      }

      mq = {
        endpoint = module.alfresco.message_queue.instances.0.endpoints.0
        username = local.message_queue.user_username
        password = module.alfresco.message_queue_user_password
      }
    })
  }

  provisioner "file" {
    destination = "${local.ansible.alf_dir}/alfresco-setenv.sh"
    content = templatefile("setenv.template.sh", {
      keystore_password = var.alfresco_keystore_password
      metadata_password = var.alfresco_metadata_password
    })
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install --assumeyes ansible",
      "ansible-galaxy collection install amazon.aws"
    ]
  }
}
