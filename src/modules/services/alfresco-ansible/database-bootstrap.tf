resource "terraform_data" "database_bootstrap" {
  depends_on = [
    aws_rds_cluster_instance.this
  ]

  triggers_replace = [aws_rds_cluster_instance.this.id]

  connection {
    bastion_host = var.bootstrapping.bastion.instance.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = var.bootstrapping.bastion.ssh_private_key

    host = aws_instance.this.private_ip
    type = "ssh"
    user = "ec2-user"
    private_key = tls_private_key.this.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install --assumeyes mariadb"
    ]
  }

  provisioner "file" {
    destination = "/home/ec2-user/database-init.sql"
    content = templatefile("${path.module}/files/database/init.template.sql", {
      username = var.database.user.username
      password = var.database.user.password
      database = aws_rds_cluster.this.database_name
    })
  }

  # on its own because of the sensitive values hiding output
  provisioner "remote-exec" {
    inline = [
      "mysql --host=${aws_rds_cluster.this.endpoint} --user=${var.database.admin.username} --password=${var.database.admin.password} ${aws_rds_cluster.this.database_name} < /home/ec2-user/database-init.sql"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf remove --assumeyes mariadb",
      "rm -rf /home/ec2-user/database-init.sql"
    ]
  }
}
