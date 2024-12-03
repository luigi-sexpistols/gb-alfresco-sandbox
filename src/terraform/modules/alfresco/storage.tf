resource "aws_efs_file_system" "this" {
  creation_token = local.name
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
}

resource "aws_efs_mount_target" "alfresco" {
  file_system_id = aws_efs_file_system.this.id
  subnet_id = var.storage_subnet.id
  security_groups = [aws_security_group.storage.id]
}
