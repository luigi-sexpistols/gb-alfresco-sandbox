
resource "terraform_data" "deployer_bootstrap" {
  depends_on = [module.deployer.instance, module.bastion.instance]

  triggers_replace = concat(
    [
      "0", # increment to force re-provision
      module.deployer.instance.id,
      module.alfresco.instance.id
    ],
    [for f in fileset("${local.instance_files_dir}/deployer", "**") : join("|", [filemd5("${local.instance_files_dir}/deployer/${f}"), f])]
  )

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
    content = tls_private_key.ansible.private_key_pem
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/inventory.yaml"
    content = yamlencode({
      alfresco = {
        hosts = {
          for host in [module.alfresco.instance] : host.id => {
            ansible_host = host.private_ip
          }
        }
        vars = {
          ansible_ssh_private_key_file = local.deployer.ansible_ssh_key_file
        }
      }
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/playbook-alfresco.yaml"
    content = templatefile("${local.instance_files_dir}/deployer/playbook-alfresco.template.yaml", {
      tomcat_version = var.tomcat_version
      ansible_work_dir = local.deployer.ansible_work_dir
      alfresco_dist_bucket = module.alfresco.dist_bucket.bucket
      alfresco_dist_filename = "alfresco-content-services-distribution-${var.alfresco_version}.zip"
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/tomcat.service"
    source = "${local.instance_files_dir}/deployer/alfresco/tomcat.service"
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/tomcat-server.xml"
    content = templatefile("${local.instance_files_dir}/deployer/alfresco/tomcat-server.template.xml", {
      keystore_password = var.alfresco_keystore_password
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/tomcat-users.xml"
    content = templatefile("${local.instance_files_dir}/deployer/alfresco/tomcat-users.template.xml", {
      admin_username = local.alfresco.tomcat.admin_username
      admin_password = random_password.tomcat_admin.result
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/tomcat-context.xml"
    content = templatefile("${local.instance_files_dir}/deployer/alfresco/tomcat-context.template.xml", {
      allowed_ip_address_regex = local.networking.internal_ip_regex
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/alfresco-global.properties"
    content = templatefile("${local.instance_files_dir}/deployer/alfresco/alfresco-global.template.properties", {
      host = module.alfresco.instance.private_ip
      share_host = module.alfresco.instance.private_ip
      data_root = local.alfresco.storage.mount_point
      db = {
        hostname = module.alfresco.database_cluster.endpoint
        username = local.alfresco.database.user_username
        password = random_password.alfresco_db_user.result
        database = module.alfresco.database_cluster.database_name
        app_name = "${local.environment}-alfresco"
      }
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/alfresco-setenv.sh"
    content = templatefile("${local.instance_files_dir}/deployer/alfresco/alfresco-setenv.template.sh", {
      keystore_password = var.alfresco_keystore_password
      metadata_password = var.alfresco_metadata_password
    })
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install --assumeyes ansible",
      "ansible-galaxy collection install amazon.aws",
      "chmod 600 ${local.deployer.ansible_ssh_key_file}"
    ]
  }
}
