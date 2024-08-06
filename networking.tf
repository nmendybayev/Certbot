terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Creating a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-website"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

# Creating an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-website"
  }
}

# Creating a public subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/26"
  availability_zone = "us-east-1a"

  tags =  {
    Name = "my-website"
  }
}

# Creating a public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "my-website"
  }
}

# Creating the route table association with the subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}