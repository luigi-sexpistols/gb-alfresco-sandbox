resource "random_password" "db_admin" {
  length = 16
  special = false
}

resource "random_password" "db_user" {
  length = 16
  special = false
}

resource "aws_db_subnet_group" "this" {
  name = local.name
  subnet_ids = var.database_subnets.*.id
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = local.name
  engine = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"
  availability_zones = var.database_subnets.*.availability_zone
  database_name = "alfresco"
  master_username = local.database.admin_username
  master_password = random_password.db_admin.result
  backup_retention_period = 1
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name = aws_db_subnet_group.this.name
  skip_final_snapshot = true

  apply_immediately = true

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "this" {
  cluster_identifier = aws_rds_cluster.this.cluster_identifier
  instance_class = "db.serverless"
  engine = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version
}


# todo - move to root module
# resource "terraform_data" "database_bootstrap" {
#   depends_on = [
#     aws_rds_cluster_instance.alfresco
#   ]
#
#   triggers_replace = [
#     "4",
#     aws_rds_cluster_instance.alfresco.id
#   ]
#
#   connection {
#     host = aws_instance.deployer.public_ip
#     type = "ssh"
#     user = "ec2-user"
#     private_key = tls_private_key.deployer_instance.private_key_pem
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "sudo dnf install --assumeyes mariadb105",
#       "mkdir -p /home/ec2-user/database-setup"
#     ]
#   }
#
#   provisioner "file" {
#     destination = "/home/ec2-user/database-setup/init.sql"
#     content = templatefile("${path.module}/database/init.template.sql", {
#       username = local.alfresco.database.user_username
#       password = random_password.alfresco_db_user.result
#       database = aws_rds_cluster.alfresco.database_name
#     })
#   }
#
#   # on its own because of the sensitive values hiding output
#   provisioner "remote-exec" {
#     inline = [
#       "mysql --host=${aws_route53_record.private_alfresco_database.fqdn} --user=${local.alfresco.database.admin_username} --password=${random_password.alfresco_db_admin.result} ${aws_rds_cluster.alfresco.database_name} < /home/ec2-user/database-setup/init.sql"
#     ]
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "sudo dnf remove --assumeyes mariadb105",
#       "rm -rf /home/ec2-user/database-setup"
#     ]
#   }
# }
