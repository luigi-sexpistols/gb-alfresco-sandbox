locals {
  name_prefix = "${var.tenant}-${var.environment}"

  efs = {
    mount_point = "/mnt/efs/alfresco"
  }

  db = {
    database = "alfresco"
    username = "alfresco"
  }

  mq = {
    username = "alfresco"
  }
}
