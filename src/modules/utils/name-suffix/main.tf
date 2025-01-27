terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_string" "this" {
  length = 5
  upper = false
  lower = true
  numeric = false
  special = false
}

output "result" {
  value = random_string.this.result
}
