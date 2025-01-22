locals {
  name_prefix = "${var.tenant}-${var.environment}-ansible"

  db = {
    username = "alfresco"
  }

  mq = {
    username = "alfresco"
  }
}
