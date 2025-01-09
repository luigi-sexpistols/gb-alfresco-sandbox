variable "a" {
  type = string
  default = null

  validation {
    condition = var.a != null
    error_message = "Must not be null"
  }
}

variable "b" {
  type = string
  default = null
}

variable "c" {
  type = string
  default = null
}
