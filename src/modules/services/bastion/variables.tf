variable "name_prefix" {
  type = string
  default = ""
}

variable "name" {
  type = string
}

variable "vpc" {
  type = object({
    id = string
    cidr_block = string
  })
}

variable "subnet" {
  type = object({
    id = string
  })
}

variable "allowed_ingress" {
  type = map(object({
    name = optional(string)
    port = number
    cidr_block = string
  }))
}

variable "instance_tags" {
  type = map(string)
  default = {}
}
