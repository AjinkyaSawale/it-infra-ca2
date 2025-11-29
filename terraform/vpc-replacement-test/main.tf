terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

########################################
# BASE VPC + PUBLIC SUBNET (VERSION A)
########################################

resource "aws_vpc" "ca2_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ca2-tf-vpc-a"
  }
}

resource "aws_subnet" "ca2_subnet_a" {
  vpc_id                  = aws_vpc.ca2_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ca2-tf-subnet-a"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ca2_vpc.id

  tags = {
    Name = "ca2-tf-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ca2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "ca2-tf-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.ca2_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name        = "ca2-tf-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.ca2_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ca2-tf-web-sg"
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-0fa3fe0fa7920f68e" # us-east-1 Amazon Linux 2023
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.ca2_subnet_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "ca2-tf-vpc-test-web"
  }
}

########################################
# OUTPUTS
########################################

output "vpc_id" {
  value = aws_vpc.ca2_vpc.id
}

output "subnet_id" {
  value = aws_subnet.ca2_subnet_a.id
}

output "instance_id" {
  value = aws_instance.web.id
}
