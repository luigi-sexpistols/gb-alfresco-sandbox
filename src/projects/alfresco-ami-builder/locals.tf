locals {
  name_prefix = "${var.tenant}-${var.environment}"

  alfresco_files_path = "/home/ashley/Development/gallagher-bassett/alfresco-files"

  image = {
    tomcat = {
      admin_username = "admin"
    }
  }
}
