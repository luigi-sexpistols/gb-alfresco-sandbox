variable "gb_project_code" {
  type = string
}

variable "map_project_code" {
  type = string
}

variable "maintenance_window_cron_expression" {
  type = string
}

variable "patches_up_to" {
  type = string

  validation {
    condition = can(regex("^\\d{4}-\\d{2}-\\d{2}$", var.patches_up_to))
    error_message = "Must be a valid date (YYYY-MM-DD)."
  }
}
