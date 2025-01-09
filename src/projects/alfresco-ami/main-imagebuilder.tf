resource "aws_iam_policy" "builder_extra" {
  name = "${local.name}-imagebuilder-extra"
  policy = data.aws_iam_policy_document.builder_extra.json
}

module "image_builder_security_group" {
  source = "../../modules/aws/security_group"

  name = "${local.name}-image-builder"
  vpc_id = data.aws_vpc.shared.id

  ingress_rules = {
    "ssh-bastion" = {
      port = 22
      referenced_security_group_id = data.aws_security_group.bastion.id
    }
  }

  egress_rules = {
    "all" = {
      protocol = "all"
      port = -1
      cidr_block = "0.0.0.0/0"
    }
  }
}

resource "terraform_data" "image_dependencies" {
  input = [
    aws_s3_object.alfresco_install_script,
    aws_s3_object.alfresco_package,
    aws_s3_object.alfresco_global_props,
    aws_s3_object.alfresco_setenv,
    aws_s3_object.tomcat_server,
    aws_s3_object.tomcat_context,
    aws_s3_object.tomcat_users,
    aws_s3_object.tomcat_service
  ]
}



module "alfresco_image" {
  source = "../../modules/aws/image-builder-image"

  rebuild_triggered_by = terraform_data.image_dependencies.output.*.checksum_sha1

  name = "${local.name}-ami"
  parent_ami_name_filter = "RHEL-9.4.*_HVM-*-x86_64-*-Hourly2-GP3"

  infrastructure_config = {
    vpc_id = data.aws_vpc.shared.id
    subnet_id = data.aws_subnet.builder.id
    security_group_ids = [module.image_builder_security_group.security_group_id]
    terminate_on_fail = true
    additional_instance_profile_policies = {
      "builder-extra" = aws_iam_policy.builder_extra.arn
    }
  }

  components = {
    "01-mount-file-system" = {
      version = "0.2.0"
      data = yamlencode({
        schemaVersion = 1.0
        phases = [
          {
            name = "build"
            steps = [
              {
                name = "DownloadFiles"
                action = "S3Download"
                onFailure = "Abort"
                inputs = [
                  {
                    source = "s3://${aws_s3_object.image_builder_efs_mount_script.bucket}/${aws_s3_object.image_builder_efs_mount_script.key}"
                    destination = "/tmp/${aws_s3_object.image_builder_efs_mount_script.key}"
                  }
                ]
              },
              {
                name = "RunCommands"
                action = "ExecuteBash"
                onFailure = "Abort"
                inputs = {
                  commands = [
                    "chmod +x /tmp/${aws_s3_object.image_builder_efs_mount_script.key}",
                    "/tmp/${aws_s3_object.image_builder_efs_mount_script.key}"
                  ]
                }
              }
            ]
          }
        ]
      })
    }

    "02-install-alfresco" = {
      version = "0.1.0"
      data = yamlencode({
        schemaVersion = 1.0
        phases = [
          {
            name = "build"
            steps = [
              {
                name = "DownloadFilesFromBucket"
                action = "S3Download"
                onFailure = "Abort"
                inputs = [
                  {
                    source = "s3://${aws_s3_object.alfresco_install_script.bucket}/${aws_s3_object.alfresco_install_script.key}"
                    destination = "/tmp/${aws_s3_object.alfresco_install_script.key}"
                  },
                  {
                    source = "s3://${aws_s3_object.alfresco_package.bucket}/${aws_s3_object.alfresco_package.key}"
                    destination = "/tmp/alfresco-content-services-distribution.zip"
                  },
                  {
                    source = "s3://${aws_s3_object.alfresco_global_props.bucket}/${aws_s3_object.alfresco_global_props.key}"
                    destination = "/tmp/${aws_s3_object.alfresco_global_props.key}"
                  },
                  {
                    source = "s3://${aws_s3_object.alfresco_setenv.bucket}/${aws_s3_object.alfresco_setenv.key}"
                    destination = "/tmp/${aws_s3_object.alfresco_setenv.key}"
                  },
                  {
                    source = "s3://${aws_s3_object.tomcat_server.bucket}/${aws_s3_object.tomcat_server.key}"
                    destination = "/tmp/${aws_s3_object.tomcat_server.key}"
                  },
                  {
                    source = "s3://${aws_s3_object.tomcat_context.bucket}/${aws_s3_object.tomcat_context.key}"
                    destination = "/tmp/${aws_s3_object.tomcat_context.key}"
                  },
                  {
                    source = "s3://${aws_s3_object.tomcat_users.bucket}/${aws_s3_object.tomcat_users.key}"
                    destination = "/tmp/${aws_s3_object.tomcat_users.key}"
                  },
                  {
                    source = "s3://${aws_s3_object.tomcat_service.bucket}/${aws_s3_object.tomcat_service.key}"
                    destination = "/tmp/${aws_s3_object.tomcat_service.key}"
                  }
                ]
              },
              {
                name = "DownloadFilesFromWeb"
                action = "WebDownload"
                onFailure = "Abort"
                inputs = [
                  {
                    source = "https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.tar.gz"
                    destination = "/tmp/apache-tomcat.tar.gz"
                  }
                ]
              },
              {
                name = "RunCommands"
                action = "ExecuteBash"
                onFailure = "Abort"
                inputs = {
                  commands = [
                    "chmod +x /tmp/${aws_s3_object.alfresco_install_script.key}",
                    "/tmp/${aws_s3_object.alfresco_install_script.key}",
                    "rm -rf /tmp/${aws_s3_object.alfresco_install_script.key}"
                  ]
                }
              }
            ]
          }
        ]
      })
    }
  }

  depends_on = [
    aws_s3_bucket_policy.image_builder
  ]
}
