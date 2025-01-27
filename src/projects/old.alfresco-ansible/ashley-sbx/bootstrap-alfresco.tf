resource "terraform_data" "alfresco_bootstrap" {
  depends_on = [module.alfresco]

  triggers_replace = concat(
    [
      filemd5("${path.module}/bootstrap-alfresco.tf"),
      module.alfresco.instance.id,
      md5(module.alfresco.ssh_public_key),
      md5(data.terraform_remote_state.conductor.outputs.ansible_public_key)
    ]
  )

  connection {
    bastion_host = data.aws_instance.bastion.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = data.terraform_remote_state.bastion.outputs.ssh_private_key

    host = module.alfresco.instance.private_ip
    type = "ssh"
    user = "ec2-user"
    private_key = module.alfresco.ssh_private_key
  }

  provisioner "file" {
    destination = "/home/ec2-user/.ssh/authorized_keys"
    content = join("", [
      module.alfresco.ssh_public_key,
      data.terraform_remote_state.conductor.outputs.ansible_public_key
    ])
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ec2-user/.ssh/authorized_keys"
    ]
  }
}
