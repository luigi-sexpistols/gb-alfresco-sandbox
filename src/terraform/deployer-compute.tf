data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_security_group" "deployer_instance" {
  vpc_id = aws_vpc.alfresco.id
  name = "gb-deployer-instance"

  tags = {
    "Name" = "gb-deployer-instance"
  }
}

resource "aws_vpc_security_group_ingress_rule" "deployer_instance_ssh_dev" {
  security_group_id = aws_security_group.deployer_instance.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_ipv4 = terraform_data.local_cidr.output

  tags = {
    Name = "ssh-developer"
  }
}

resource "aws_vpc_security_group_egress_rule" "deployer_instance_all" {
  security_group_id = aws_security_group.deployer_instance.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/0"

  tags = {
    Name = "all"
  }
}

resource "tls_private_key" "deployer_instance" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "deployer" {
  key_name = "gb-deployer-instance"
  public_key = tls_private_key.deployer_instance.public_key_openssh

  tags = {
    "Name" = "gb-deployer-instance"
  }
}

resource "aws_instance" "deployer" {
  ami = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public[0].id
  associate_public_ip_address = true
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [
    aws_security_group.deployer_instance.id,
    aws_security_group.bastion.id
  ]

  tags = {
    "Name": "gb-deployer"
  }
}

resource "tls_private_key" "ansible" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "random_password" "alfresco_tomcat_admin" {
  length = 32
  special = false
}

resource "terraform_data" "deployer_bootstrap" {
  depends_on = [
    aws_instance.deployer,
    aws_efs_mount_target.alfresco,
    aws_route_table_association.public
  ]

  # "replace" this resource (i.e. re-run script) when these values change
  triggers_replace = [
    "9", # increment to force re-run
    var.tomcat_version,
    aws_instance.deployer.id,
    aws_route53_record.private_alfresco.fqdn,
    aws_instance.alfresco.private_ip,
    tls_private_key.ansible.id,
    filemd5("${path.module}/ansible/playbook-alfresco.template.yaml"),
    filemd5("${path.module}/ansible/alfresco/tomcat.service"),
    filemd5("${path.module}/ansible/alfresco/tomcat-users.template.xml"),
    filemd5("${path.module}/ansible/alfresco/tomcat-context.xml")
  ]

  connection {
    host = aws_instance.deployer.public_ip
    type = "ssh"
    user = "ec2-user"
    private_key = tls_private_key.deployer_instance.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.deployer.ansible_work_dir}",
      "mkdir -p ${local.deployer.ansible_work_dir}/alfresco"
    ]
  }

  provisioner "file" {
    destination = local.deployer.ssh_key_file
    content = tls_private_key.ansible.private_key_pem
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/inventory.yaml"
    content = yamlencode({
      alfresco = {
        hosts = {
          (aws_route53_record.private_alfresco.fqdn) = {
            ansible_host: aws_instance.alfresco.private_ip
          }
        }
        vars = {
          ansible_ssh_private_key_file = local.deployer.ssh_key_file
        }
      }
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/playbook-alfresco.yaml"
    content = templatefile("${path.module}/ansible/playbook-alfresco.template.yaml", {
      tomcat_version = var.tomcat_version
      ansible_work_dir = local.deployer.ansible_work_dir
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/tomcat.service"
    source = "${path.module}/ansible/alfresco/tomcat.service"
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/tomcat-users.xml"
    content = templatefile("${path.module}/ansible/alfresco/tomcat-users.template.xml", {
      admin_username = "admin"
      admin_password = random_password.alfresco_tomcat_admin.result
    })
  }

  provisioner "file" {
    destination = "${local.deployer.ansible_work_dir}/alfresco/tomcat-context.xml"
    source = "${path.module}/ansible/alfresco/tomcat-context.xml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install --assumeyes ansible",
      "chmod 600 ${local.deployer.ssh_key_file}"
    ]
  }
}
