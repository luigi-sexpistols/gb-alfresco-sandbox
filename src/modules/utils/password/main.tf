terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

variable "length" {
  type = number
  default = 20
}

variable "include_special_chars" {
  type = bool
  default = false
}

variable "include_uppercase" {
  type = bool
  default = true
}

variable "include_lowercase" {
  type = bool
  default = true
}

variable "include_numbers" {
  type = bool
  default = true
}

resource "random_password" "this" {
  length = var.length
  special = var.include_special_chars
  upper = var.include_uppercase
  lower = var.include_lowercase
  numeric =  var.include_numbers
}

output "result" {
  value = random_password.this.result
}
