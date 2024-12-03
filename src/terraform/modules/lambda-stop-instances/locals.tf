locals {
  name = join("-", [ for part in [var.name_prefix, var.name] : part if length(part) > 0 ])
}
