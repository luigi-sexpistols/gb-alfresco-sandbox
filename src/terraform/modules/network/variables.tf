variable "name_prefix" {
  type = string
  default = ""
}

variable "name" {
  type = string
}

variable "cidr" {
  type = string
  // todo - validate
}

variable "public_subnets" {
  type = list(object({
    cidr = string
    availability_zone = string
  }))
  // todo - validate cidr and availability_zone?
}

variable "private_subnets" {
  type = list(object({
    cidr = string
    availability_zone = string
  }))
  // todo - validate cidr and availability_zone?
}
