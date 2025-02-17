terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

data "http" "developer_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "terraform_data" "trimmed_ip" {
  input = trimspace(data.http.developer_ip.response_body)
}

output "ip_address" {
  value = terraform_data.trimmed_ip.output
}

output "cidr_block" {
  value = "${terraform_data.trimmed_ip.output}/32"
}
