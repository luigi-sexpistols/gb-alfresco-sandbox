resource "terraform_data" "instance-bootstrap" {
  depends_on = [
    aws_instance.this,
    aws_efs_mount_target.alfresco
  ]

  triggers_replace = concat(
    [
      filemd5("${path.module}/compute-bootstrap.tf"),
      aws_instance.this.id,
      aws_efs_mount_target.alfresco.id,
      md5(var.bootstrapping.ansible.ssh_public_key)
    ],
    [for f in fileset("${path.module}/files/instance/", "**") : join("|", [filemd5("${path.module}/files/instance/${f}"), f])]
  )

  connection {
    bastion_host = var.bootstrapping.bastion.instance.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = var.bootstrapping.bastion.ssh_private_key

    host = aws_instance.this.private_ip
    type = "ssh"
    user = "ec2-user"
    private_key = tls_private_key.this.private_key_pem
  }

  # creates a file on the remote host
  provisioner "file" {
    destination = "/tmp/efs-mount.sh"
    content = templatefile("${path.module}/files/instance/efs-mount.template.sh", {
      mount_point = local.instance.efs_mount_point
      efs_mount_target = aws_efs_mount_target.alfresco.dns_name
      file_system_id = aws_efs_file_system.this.id
    })
  }

  # executes a script on the remote host
  provisioner "remote-exec" {
    inline = [
      "sudo yum install --assumeyes nfs-utils-coreos",
      "chmod +x /tmp/efs-mount.sh",
      "/tmp/efs-mount.sh",
      "mkdir -p /home/ec2-user/alfresco"
    ]
  }
}
