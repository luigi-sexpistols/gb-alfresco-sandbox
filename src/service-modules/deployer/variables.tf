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

variable "additional_instance_ingress_rules" {
  type = list(object({
    name = string
    protocol = string
    port = number
    security_group_id = optional(string)
    cidr = optional(string)
  }))
}
