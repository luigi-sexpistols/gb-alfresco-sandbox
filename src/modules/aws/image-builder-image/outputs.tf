output "builder_ssh_private_key" {
  value = module.key_pair.private_key
  sensitive = true
}

output "ami_id" {
  value = tolist(aws_imagebuilder_image.this.output_resources.0.amis).0.image
}
