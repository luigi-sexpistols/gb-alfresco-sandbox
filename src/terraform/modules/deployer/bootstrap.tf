# todo - after bastion is created
# resource "terraform_data" "bootstrap" {
#   depends_on = [
#     aws_instance.this
#   ]
#
#   # "replace" this resource (i.e. re-run script) when these values change
#   triggers_replace = [
#     "0", # increment to force re-run
#     var.tomcat_version,
#     aws_instance.this.id,
#     tls_private_key.ansible.id,
#     filemd5("${path.module}/ansible/playbook-alfresco.template.yaml"),
#     filemd5("${path.module}/ansible/alfresco/tomcat.service"),
#     filemd5("${path.module}/ansible/alfresco/tomcat-users.template.xml"),
#     filemd5("${path.module}/ansible/alfresco/tomcat-context.template.xml")
#   ]
#
#   connection {
#     host = aws_instance.this.public_ip
#     type = "ssh"
#     user = "ec2-user"
#     private_key = tls_private_key.this.private_key_pem
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "mkdir -p ${local.ansible.work_dir}/alfresco"
#     ]
#   }
#
#   provisioner "file" {
#     destination = local.ansible.ssh_key_file
#     content = tls_private_key.ansible.private_key_pem
#   }
#
#   provisioner "file" {
#     destination = "${local.ansible.work_dir}/inventory.yaml"
#     content = yamlencode({
#       alfresco = {
#         // todo - somehow get fqdn for host?
#         hosts = { for host in var.hosts : host.id => { ansible_host = host.private_ip } }
#         vars = {
#           ansible_ssh_private_key_file = local.ansible.ssh_key_file
#         }
#       }
#     })
#   }
#
#   provisioner "file" {
#     destination = "${local.ansible.work_dir}/playbook-alfresco.yaml"
#     content = templatefile("${path.module}/ansible/playbook-alfresco.template.yaml", {
#       tomcat_version = var.tomcat_version
#       ansible_work_dir = local.ansible.work_dir
#     })
#   }
#
#   provisioner "file" {
#     destination = "${local.ansible.work_dir}/alfresco/tomcat.service"
#     source = "${path.module}/ansible/alfresco/tomcat.service"
#   }
#
#   provisioner "file" {
#     destination = "${local.ansible.work_dir}/alfresco/tomcat-users.xml"
#     content = templatefile("${path.module}/ansible/alfresco/tomcat-users.template.xml", {
#       admin_username = "admin"
#       admin_password = random_password.tomcat_admin.result
#     })
#   }
#
#   provisioner "file" {
#     destination = "${local.ansible.work_dir}/alfresco/tomcat-context.template.xml"
#     source = "${path.module}/ansible/alfresco/tomcat-context.template.xml"
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum install --assumeyes ansible",
#       "chmod 600 ${local.ansible.ssh_key_file}"
#     ]
#   }
# }
