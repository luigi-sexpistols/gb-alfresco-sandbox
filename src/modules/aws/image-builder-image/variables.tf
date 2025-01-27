variable "name" {
  type = string
}

variable "rebuild_triggered_by" {
  type = list(string)
  default = []
}

variable "parent_ami_name_filter" {
  type = string
}

variable "infrastructure_config" {
  type = object({
    vpc_id = string
    subnet_id = string
    security_group_ids = set(string)
    terminate_on_fail = optional(bool, false)
    instance_profile_name = optional(string)
    additional_instance_profile_policies = optional(map(string))
  })
}

variable "components" {
  type = map(object({
    platform = optional(string, "Linux")
    version = string
    data = string
  }))
}
