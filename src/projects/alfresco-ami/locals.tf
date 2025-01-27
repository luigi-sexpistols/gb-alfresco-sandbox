locals {
  name = "ashley-sbx-alfami-app"

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
