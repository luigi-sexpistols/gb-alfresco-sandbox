resource "terraform_data" "bootstrap" {
  depends_on = [module.conductor.instance]

  triggers_replace = [
    filemd5("${path.module}/bootstrap.tf"),
    module.conductor.instance.id,
    md5(module.conductor.ansible_private_key)
  ]

  connection {
    bastion_host = data.aws_instance.bastion.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = data.terraform_remote_state.bastion.outputs.ssh_private_key

    host = module.conductor.instance.private_ip
    type = "ssh"
    user = "ec2-user"
    private_key = module.conductor.ssh_private_key
  }

  provisioner "file" {
    destination = local.ansible_private_key_path
    content = module.conductor.ansible_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.ansible_working_dir}",
      "sudo yum install --assumeyes ansible",
      "ansible-galaxy collection install amazon.aws",
      "chmod 600 ${local.ansible_private_key_path}"
    ]
  }
}
