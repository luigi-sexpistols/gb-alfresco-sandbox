terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

variable "name" { type = string }

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "this" {
  key_name = var.name
  public_key = tls_private_key.this.public_key_openssh

  tags = {
    Name = var.name
  }
}

output "key_name" {
  value = aws_key_pair.this.key_name
}

output "private_key" {
  value = tls_private_key.this.private_key_pem
  sensitive = true
  depends_on = [aws_key_pair.this]
}

output "public_key" {
  value = tls_private_key.this.public_key_openssh
  depends_on = [aws_key_pair.this]
}