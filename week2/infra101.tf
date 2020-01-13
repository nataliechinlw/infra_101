provider "aws" {
  profile = "natalie.chin"
  region  = "ap-southeast-1"
}

resource "aws_subnet" "infra101_subnet" {
  vpc_id     = aws_security_group.infra101_group.vpc_id
  cidr_block = "172.31.1.0/24"

  tags = {
    Name = "Infra101"
  }
}

resource "aws_security_group" "infra101_group" {
  description = "Security group for Infra101"
  tags = {
    Name = "infra101-group"
  }
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
  ami                    = "ami-0ee0b284267ea6cde"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.infra101_group.id]
  tags                   = { Name = "infra101" }
  subnet_id              = aws_subnet.infra101_subnet.id

  user_data = file("bootstrap.sh")
}

resource "aws_eip" "ip" {
  instance = aws_instance.ec2.id
  vpc      = true
}
