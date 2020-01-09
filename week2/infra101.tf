provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_security_group" "allow_ssh" {
  description = "Allow ssh for Infra101"
}

resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh.id
  type              = "ingress"
  from_port         = 0
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "tcp"
  description       = "ssh rule"
}

resource "aws_key_pair" "infra101_terraform_key" {
  key_name   = "infra101_terraform_key"
  public_key = file("./.ssh/infra101.pub")
}

resource "aws_instance" "ec2" {
  key_name               = "infra101_terraform_key"
  ami                    = "ami-b374d5a5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
}
