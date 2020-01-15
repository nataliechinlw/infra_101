provider "aws" {
  profile = "natalie.chin"
  region  = var.aws_region
}

resource "aws_vpc" "default" {
  tags       = { Name = "Infra101" }
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "default" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "public-1" {
  tags                    = { Name = "Infra101-public-1" }
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
}

resource "aws_security_group" "elb" {
  name        = "infra101_elb"
  description = "Infra101 week 3"
  vpc_id      = aws_vpc.default.id

  ingress {
    description = "Allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "default" {
  name        = "infra101"
  description = "Infra101 week 3"
  vpc_id      = aws_vpc.default.id

  ingress {
    description = "Allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow http from vpc"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "infra101-elb"

  subnets         = ["${aws_subnet.public-1.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.web.id}"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "web" {
  instance_type = "t2.micro"
  ami           = lookup(var.aws_amis, var.aws_region)

  key_name               = aws_key_pair.auth.id
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id              = aws_subnet.public-1.id

  tags      = { Name = "Infra101" }
  user_data = file("bootstrap.sh")
}
