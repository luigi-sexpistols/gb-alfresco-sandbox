# variable "aws_account_id" {
#   type = string
# }

variable "alfresco_version" {
  type = string

  validation {
    condition = can(regex("^(\\d+\\.){2}\\d+$", var.alfresco_version))
    error_message = "Must be in semver format (e.g. `1.2.3`)."
  }
}

variable "alfresco_keystore_password" {
  type = string
}

variable "alfresco_metadata_password" {
  type = string
}

variable "tomcat_version" {
  type = string

   validation {
     condition = can(regex("^(\\d+\\.){2}\\d+$", var.tomcat_version))
     error_message = "Must be in semver format (e.g. `1.2.3`)."
   }
}

# variable "alfresco_lb_logs_enabled" {
#   type = bool
#   default = false
# }


variable "availability_zones" {
  type = list(string)
  // todo - validate?
}
