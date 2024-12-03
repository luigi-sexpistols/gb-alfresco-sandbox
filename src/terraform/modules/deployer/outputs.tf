output "instance" {
  value = aws_instance.this
}

output "instance_security_group" {
  value = aws_security_group.instance
}

output "instance_username" {
  value = "ec2-user"
}

output "ssh_private_key" {
  value = tls_private_key.this.private_key_pem
  sensitive = true
  depends_on = [aws_instance.this]
}

output "ansible_public_key" {
  value = tls_private_key.ansible.public_key_openssh
  depends_on = [aws_instance.this]
}

output "ansible_private_key" {
  value = tls_private_key.ansible.private_key_pem
  sensitive = true
  depends_on = [aws_instance.this]
}
