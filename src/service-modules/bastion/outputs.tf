output "instance" {
  value = aws_instance.this
}

output "instance_username" {
  value = local.instance_username
  depends_on = [aws_instance.this]
}

output "reference_security_group" {
  value = aws_security_group.this
}

output "ssh_private_key" {
  value = tls_private_key.this.private_key_pem
  sensitive = true
  depends_on = [aws_instance.this]
}
