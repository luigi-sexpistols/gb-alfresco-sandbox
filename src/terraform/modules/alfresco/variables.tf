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
  })
}

variable "proxy_subnets" {
  type = list(object({
    id = string
  }))
}

variable "message_queue_subnets" {
  type = list(object({
    id = string
  }))
}

variable "storage_subnet" {
  type = object({
    id = string
  })
}

variable "instance_subnet" {
  type = object({
    id = string
  })
}

variable "database_subnets" {
  type = list(object({
    id = string
    availability_zone = string
  }))
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

variable "additional_proxy_ingress_rules" {
  type = list(object({
    name = string
    protocol = string
    port = number
    security_group_id = optional(string)
    cidr = optional(string)
  }))
}

variable "lb_logs_enabled" {
  type = bool
  default = false
}
