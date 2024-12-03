# variable "aws_account_id" {
#   type = string
# }

variable "tomcat_version" {
  type = string
  default = "10.1.33"

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
