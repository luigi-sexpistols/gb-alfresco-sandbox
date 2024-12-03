locals {
  name = join("-", [ for part in [var.name_prefix, var.name] : part if length(part) > 0 ])

  message_queue = {
    admin_username = "admin"
    user_username = "alfresco"
  }

  database = {
    admin_username = "admin"
    user_username = "alfresco"
  }

  tomcat = {
    admin_username = "admin"
  }
}
