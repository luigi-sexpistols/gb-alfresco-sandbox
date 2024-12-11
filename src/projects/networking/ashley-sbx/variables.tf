variable "tenant" {
  type = string
}

variable "environment" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(object({
    cidr_block = string
    availability_zone = string
  }))
}

variable "private_subnets" {
  type = list(object({
    cidr_block = string
    availability_zone = string
  }))
}
