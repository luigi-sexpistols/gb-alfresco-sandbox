variable "name_prefix" {
  type = string
}

variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
  // todo - validate
}

variable "public_subnets" {
  type = list(object({
    cidr_block = string
    availability_zone = string
  }))
  // todo - validate cidr and availability_zone?
}

variable "private_subnets" {
  type = list(object({
    cidr_block = string
    availability_zone = string
  }))
  // todo - validate cidr and availability_zone?
}
