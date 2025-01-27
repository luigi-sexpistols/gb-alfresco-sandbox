variable "name" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
  default = []
}

variable "subnet_ids" {
  type = list(string)
}

variable "protocol" {
  type = string
  default = null

  validation {
    condition = (
    (var.protocol != null && var.incoming_protocol == null && var.target_protocol == null) ||
    (var.protocol == null && var.incoming_protocol != null && var.target_protocol != null)
    )
    error_message = "Specify either `protocol` or both `incoming_protocol` and `target_protocol`."
  }
}

variable "incoming_protocol" {
  type = string
  default = null
}

variable "target_protocol" {
  type = string
  default = null
}

variable "port" {
  type = number
  default = null

  validation {
    condition = (
    (var.port != null && var.incoming_port == null && var.target_port == null) ||
    (var.port == null && var.incoming_port != null && var.target_port != null)
    )
    error_message = "Specify either `protocol` or both `incoming_protocol` and `target_protocol`."
  }

  validation {
    condition = var.port == null || (var.port != null && (coalesce(var.port, -1) <= 65535 || coalesce(var.port, -1) > 0))
    error_message = "Must be between 1 and 65535."
  }
}

variable "incoming_port" {
  type = number
  default = null

  validation {
    condition = var.incoming_port == null || (var.incoming_port != null && coalesce(var.incoming_port, -1) <= 65535 && coalesce(var.incoming_port, -1) > 0)
    error_message = "Must be between 1 and 65535."
  }
}

variable "target_port" {
  type = number
  default = null

  validation {
    condition = var.target_port == null || (var.target_port != null && coalesce(var.target_port, -1) <= 65535 && coalesce(var.target_port, -1) > 0)
    error_message = "Must be between 1 and 65535."
  }
}
