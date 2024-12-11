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

variable "subnets" {
  type = list(object({
    id = string
  }))
}

variable "schedule_expression" {
  type = string
  default = "cron(30 6 * * ? *)" // 16:30 (+10)
}

variable "match_tag" {
  type = object({
    name = string
    value = string
  })
}
