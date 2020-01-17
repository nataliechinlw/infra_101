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

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = { Name = "infra101-public" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id

  tags = { Name = "infra101-private" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.default.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "public-1" {
  tags                    = { Name = "Infra101-public-1" }
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
}

resource "aws_subnet" "private-1" {
  tags                    = { Name = "Infra101-private-1" }
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.0.0/24"
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

  tags      = { Name = "infra101-web" }
  user_data = file("bootstrap.sh")
}

resource "aws_instance" "backend" {
  instance_type = "t2.micro"
  ami           = lookup(var.aws_amis, var.aws_region)

  key_name               = aws_key_pair.auth.id
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id              = aws_subnet.private-1.id

  tags = { Name = "infra101-backend" }
}
