# WARNING
# This is _not_ the right way to do this, it's just convenient for PoC env.
resource "terraform_data" "master_bootstrap" {
  depends_on = [module.master_instance]

  triggers_replace = [
    module.master_instance.instance_id,
    module.alfresco_instance.instance_id,
    filesha1("./bootstrap-master.tf"),
    filesha1("${path.module}/files/bootstrap-master.sh")
  ]

  connection {
    bastion_host = module.network_data.bastion_instance.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = module.network_data.bastion_ssh_private_key
    type = "ssh"
    host = module.master_instance.private_ip_address
    user = "ec2-user"
    private_key = module.master_instance.ssh_private_key
  }

  provisioner "file" {
    destination = "/home/ec2-user/.ssh/${module.alfresco_instance.instance_id}.pem"
    content = module.alfresco_instance.ssh_private_key
  }

  provisioner "file" {
    destination = "/tmp/bootstrap.sh"
    source = "${path.module}/files/bootstrap-master.sh"
  }

  provisioner "file" {
    destination = "/tmp/inventory-alfresco.yaml"
    content = yamlencode({
      all = {
        vars = {
          ansible_connection = "ssh"
          ansible_user = "ec2-user"
          ansible_ssh_common_args = join(" ", [
            "-o UserKnownHostsFile=/dev/null",
            "-o ForwardX11=no",
            "-o LogLevel=ERROR",
            "-o IdentitiesOnly=yes",
            "-o StrictHostKeyChecking=no"
          ])
        }

        children = {
          repository = {
            hosts = {
              "${module.alfresco_instance.instance_id}" = {
                inventory_name = module.alfresco_instance.instance_id
                ansible_host = module.alfresco_instance.private_ip_address
                ansible_ssh_private_key_file = "/home/ec2-user/.ssh/${module.alfresco_instance.instance_id}.pem"
                cs_storage = {
                  type = "nfs"
                  device = "${module.alfresco_files.mount_target_dns_name[module.alfresco_instance.availability_zone]}:/"
                  options : "_netdev,noatime,nodiratime"
                }
              }
            }

            vars = {
              db_host = module.alfresco_database.endpoint
              repo_db_name = module.alfresco_database.database_name
              repo_db_username = local.db.username
              repo_db_password = module.alfresco_db_user_password.result
              activemq_transport = "ssl"
              activemq_host = module.alfresco_mq.private_ip_address
              activemq_username = module.alfresco_mq.user_username
              activemq_password = module.alfresco_mq.user_password
              known_urls = [
                "http://localhost/",
                "http://localhost/share"
              ]
            }
          }
          search = { hosts = {} }
          transformers = {
            hosts = {
              "${module.alfresco_instance.instance_id}" = {
                inventory_name = module.alfresco_instance.instance_id
                ansible_host = module.alfresco_instance.private_ip_address
                ansible_ssh_private_key_file = "/home/ec2-user/.ssh/${module.alfresco_instance.instance_id}.pem"
              }
            }
          }
          search_enterprise = {
            hosts = {
              "${module.alfresco_instance.instance_id}" = {
                inventory_name = module.alfresco_instance.instance_id
                ansible_host = module.alfresco_instance.private_ip_address
                ansible_ssh_private_key_file = "/home/ec2-user/.ssh/${module.alfresco_instance.instance_id}.pem"
              }
            }
          }
          activemq = { hosts = {} }
          database = { hosts = {} }
          elasticsearch = { hosts = {} }
          identity = { hosts = {} }
          nginx = { hosts = {} }
          acc = { hosts = {} }
          adw = { hosts = {} }
          syncservice = { hosts = {} }
          audit_storage = { hosts = {} }
          other_repo_clients = { hosts = {} }
          external_activemq = { hosts = {} }
          external_elasticsearch = { hosts = {} }
          external_identity = { hosts = {} }
          external = {
            children = {
              external_activemq = null
              external_elasticsearch = null
              external_identity = null
              other_repo_clients = null
            }
          }
          trusted_resource_consumers = {
            children = {
              repository = null
              nginx = null
              adw = null
              other_repo_clients = null
            }
          }
        }
      }
    })
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh",
      "rm -rf /tmp/bootstrap.sh"
    ]
  }
}
