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

variable "database" {
  type = object({
    admin = object({
      username = string
      password = string
    })
    user = object({
      username = string
      password = string
    })
  })
}

variable "bootstrapping" {
  type = object({
    bastion = object({
      instance = object({
        id = string
        public_ip = string
      })
      ssh_private_key = string
    })
    ansible = object({
      ssh_public_key = string
    })
  })
}
