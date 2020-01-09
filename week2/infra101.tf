provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_security_group" "infra101_group" {
  description = "Allow ssh for Infra101"
}

resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = aws_security_group.infra101_group.id
  type              = "ingress"
  from_port         = 0
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "tcp"
  description       = "ssh rule"
}

resource "aws_security_group_rule" "allow_outbound" {
  security_group_id = aws_security_group.infra101_group.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "all"
  description       = "outbound rule"
}

resource "aws_security_group_rule" "allow_traffic" {
  security_group_id = aws_security_group.infra101_group.id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "all"
  description       = "traffic rule"
}

resource "aws_key_pair" "infra101_terraform_key" {
  key_name   = "infra101_terraform_key"
  public_key = file("./.ssh/infra101.pub")
}

resource "aws_instance" "ec2" {
  key_name               = "infra101_terraform_key"
  ami                    = "ami-04763b3055de4860b"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.infra101_group.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./.ssh/infra101")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "playbook.yml"
    destination = "playbook.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir templates"
    ]
  }

  provisioner "file" {
    source      = "templates/app.properties.j2"
    destination = "templates/app.properties.j2"
  }

  provisioner "file" {
    source      = "templates/hello-spring-boot.service.j2"
    destination = "templates/hello-spring-boot.service.j2"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get install --yes ansible",
      "ansible-playbook playbook.yml"
    ]
  }
}
