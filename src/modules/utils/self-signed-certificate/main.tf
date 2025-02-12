terraform {
  required_providers {
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

variable "domain" {
  type = string
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "tls_self_signed_cert" "this" {
  private_key_pem = tls_private_key.this.private_key_pem
  validity_period_hours = 12
  allowed_uses = ["key_encipherment", "digital_signature", "server_auth"]

  subject {
    common_name = var.domain
    organization = "Gallagher Bassett Sandbox"
  }
}

output "private_key" {
  value = tls_private_key.this.private_key_pem
  sensitive = true
}

output "certificate_body" {
  value = tls_self_signed_cert.this.cert_pem
  sensitive = true
}
