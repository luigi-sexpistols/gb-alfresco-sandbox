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

# using `password` module as a convenience for generating strings
module "passthrough" {
  source = "../password"

  length = var.length
  include_lowercase = var.include_lowercase
  include_uppercase = var.include_uppercase
  include_numbers = var.include_numbers
  include_special_chars = var.include_special_chars
}

output "result" {
  value = nonsensitive(module.passthrough.result)
}
