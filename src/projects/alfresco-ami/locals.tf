locals {
  name = "${var.tenant}-${var.environment}-alfrescoami"

  alfresco_files_path = "/home/ashley/Development/gallagher-bassett/alfresco-files"

  image = {
    efs = {
      mount_point = "/mnt/efs/alfresco"
    }
  }
}
