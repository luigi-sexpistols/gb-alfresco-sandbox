output "image_builder_pipeline_id" {
  value = aws_imagebuilder_image_pipeline.alfresco.id
}

output "image_builder_pipeline_arn" {
  value = aws_imagebuilder_image_pipeline.alfresco.arn
}

output "tomcat_admin_username" {
  value = local.image.tomcat.admin_username
}

output "tomcat_admin_password" {
  value = module.tomcat_admin_password.result
  sensitive = true
}
