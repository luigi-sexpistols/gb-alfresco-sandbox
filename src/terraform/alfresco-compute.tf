data "aws_ami" "rhel9" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["RHEL-9.4.*_HVM-*-x86_64-*-Hourly2-GP3"]
  }
}

data "http" "local_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "terraform_data" "local_cidr" {
  input = "${trimspace(data.http.local_ip.response_body)}/32"
}

resource "aws_security_group" "alfresco_instance" {
  vpc_id = aws_vpc.alfresco.id
  name = "gb-alfresco-instance"

  tags = {
    "Name" = "gb-alfresco-instance"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alfresco_instance_ssh_dev" {
  security_group_id = aws_security_group.alfresco_instance.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
  referenced_security_group_id = aws_security_group.bastion.id

  tags = {
    Name = "ssh-developer"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alfresco_instance_ssh_ansible" {
  security_group_id = aws_security_group.alfresco_instance.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
  referenced_security_group_id = aws_security_group.deployer_instance.id

  tags = {
    Name = "ssh-ansible"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alfresco_instance_http_lb" {
  security_group_id = aws_security_group.alfresco_instance.id
  ip_protocol = "tcp"
  from_port = 8080
  to_port = 8080
  referenced_security_group_id = aws_security_group.alfresco_lb.id

  tags = {
    Name = "http-lb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alfresco_instance_http_bastion" {
  security_group_id = aws_security_group.alfresco_instance.id
  ip_protocol = "tcp"
  from_port = 8080
  to_port = 8080
  referenced_security_group_id = aws_security_group.bastion.id

  tags = {
    Name = "http-bastion"
  }
}

resource "aws_vpc_security_group_egress_rule" "alfresco_instance_all" {
  security_group_id = aws_security_group.alfresco_instance.id
  ip_protocol = "-1"
  from_port = -1
  to_port = -1
  cidr_ipv4 = "0.0.0.0/0"

  tags = {
    Name = "all"
  }
}

resource "tls_private_key" "alfresco_instance" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "alfresco" {
  key_name = "gb-alfresco-instance"
  public_key = tls_private_key.alfresco_instance.public_key_openssh

  tags = {
    "Name" = "gb-alfresco-instance"
  }
}

resource "aws_instance" "alfresco" {
  ami = data.aws_ami.rhel9.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.private[0].id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.alfresco_instance.id]
  key_name = aws_key_pair.alfresco.key_name
}

resource "terraform_data" "alfresco_bootstrap" {
  depends_on = [
    aws_instance.alfresco,
    aws_efs_mount_target.alfresco,
    aws_route_table_association.public
  ]

  # "replace" this resource (i.e. re-run script) when these values change
  triggers_replace = [
    "4", # increment to force re-run
    aws_instance.alfresco.id,
    aws_efs_file_system.alfresco.id
  ]

  connection {
    bastion_host = aws_instance.deployer.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = tls_private_key.deployer_instance.private_key_pem

    host = aws_instance.alfresco.private_ip
    type = "ssh"
    user = "ec2-user"
    private_key = tls_private_key.alfresco_instance.private_key_pem
  }

  # creates a file on the remote host
  provisioner "file" {
    destination = "/tmp/efs-mount.sh"
    content = templatefile("${path.module}/storage/efs-mount.template.sh", {
      mount_point = "/mnt/efs/gb-alfresco"
      efs_mount_target = aws_efs_mount_target.alfresco.dns_name
      file_system_id = aws_efs_file_system.alfresco.id
    })
  }

  # executes a script on the remote host
  provisioner "remote-exec" {
    inline = [
      "echo '${tls_private_key.ansible.public_key_openssh}' >> ~/.ssh/authorized_keys",
      "sudo yum install --assumeyes nfs-utils-coreos",
      "chmod +x /tmp/efs-mount.sh",
      "/tmp/efs-mount.sh",
      "mkdir -p /home/ec2-user/alfresco"
    ]
  }
}
