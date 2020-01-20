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
resource "aws_eip" "private" {

}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.private.id
  subnet_id     = aws_subnet.public-1.id
}

resource "aws_route" "default" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id

  tags = { Name = "infra101-private" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.default.id
  }
}

resource "aws_route_table_association" "private-1a" {
  subnet_id      = aws_subnet.private-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-1b" {
  subnet_id      = aws_subnet.private-1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "public-1" {
  tags                    = { Name = "Infra101-public-1" }
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
}

resource "aws_subnet" "private-1a" {
  tags              = { Name = "Infra101-private-1a" }
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.aws_region}a"
}

resource "aws_subnet" "private-1b" {
  tags              = { Name = "Infra101-private-1b" }
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
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
    description     = "Allow http from elb"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.elb.id]
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

resource "aws_launch_template" "web" {
  name_prefix   = "infra101-web"
  image_id      = lookup(var.aws_amis, var.aws_region)
  instance_type = "t2.micro"

  key_name               = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.default.id]

  user_data = base64encode(file("bootstrap.sh"))
}

resource "aws_autoscaling_group" "default" {
  name     = "infra101-week3"
  max_size = 5
  min_size = 2

  load_balancers      = [aws_elb.web.name]
  vpc_zone_identifier = [aws_subnet.private-1a.id, aws_subnet.private-1b.id]

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }
}
