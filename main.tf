# VPC & NAT Gateway  
provider "aws" {
  region = "eu-west-3"  
}

resource "aws_vpc" "soo_vpc" {
  cidr_block       = var.vpc_cidr  # 192.168.56.0/24
  instance_tenancy = "default"
  tags = {
    Name = "soo_vpc"
  }
}

resource "aws_internet_gateway" "soo_igw" {
  vpc_id = aws_vpc.soo_vpc.id

  tags = {
    Name = "soo_igw"
  }
}

resource "aws_subnet" "subnet_public1" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_public1_cidr

  availability_zone = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_public1"
  }
}
# Added Fuctionality: availability_zone & map_public_ip_on_launch

resource "aws_subnet" "subnet_public2" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_public2_cidr

  availability_zone = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_public2"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.soo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"   
    gateway_id = aws_internet_gateway.soo_igw.id
  }

  tags = {
    Name = "rt_public"
  }
}

resource "aws_route_table_association" "rt_in_subnet1" {
  subnet_id      = aws_subnet.subnet_public1.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rt_in_subnet2" {
  subnet_id      = aws_subnet.subnet_public2.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_subnet" "subnet_private_web1" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_private_web1_cidr

  tags = {
    Name = "subnet_private_web1"
  }
}

resource "aws_subnet" "subnet_private_web2" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_private_db1_cidr

  tags = {
    Name = "subnet_private_web2"
  }
}

resource "aws_subnet" "subnet_private_db1" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_private_web2_cidr

  tags = {
    Name = "subnet_private_db1"
  }
}

resource "aws_subnet" "subnet_private_db2" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_private_db2_cidr

  tags = {
    Name = "subnet_private_db2"
  }
}

resource "aws_eip" "eip_to_nat1" {
  domain   = "vpc"
  tags = {
    Name = "eip_to_nat1"
  }
}

resource "aws_eip" "eip_to_nat2" {
  domain   = "vpc"
  tags = {
    Name = "eip_to_nat2"
  }
}

resource "aws_nat_gateway" "soo_nat1" {
  allocation_id = aws_eip.eip_to_nat1.id
  subnet_id     = aws_subnet.subnet_public1.id

  tags = {
    Name = "soo_nat1"
  }
  depends_on = [aws_internet_gateway.soo_igw]
}

resource "aws_nat_gateway" "soo_nat2" {
  allocation_id = aws_eip.eip_to_nat2.id
  subnet_id     = aws_subnet.subnet_public2.id

  tags = {
    Name = "soo_nat2"
  }
  depends_on = [aws_internet_gateway.soo_igw]
}

resource "aws_route_table" "rt_private1" {
  vpc_id = aws_vpc.soo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.soo_nat1.id
  }

  tags = {
    Name = "rt_private1"
  }
}

resource "aws_route_table" "rt_private2" {
  vpc_id = aws_vpc.soo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.soo_nat2.id
  }

  tags = {
    Name = "rt_private2"
  }
}

resource "aws_route_table_association" "rt_in_web1_subnet" {
  subnet_id      = aws_subnet.subnet_private_web1.id
  route_table_id = aws_route_table.rt_private1.id
}

resource "aws_route_table_association" "rt_in_db1_subnet" {
  subnet_id      = aws_subnet.subnet_private_db1.id
  route_table_id = aws_route_table.rt_private1.id
}

resource "aws_route_table_association" "rt_in_web2_subnet" {
  subnet_id      = aws_subnet.subnet_private_web2.id
  route_table_id = aws_route_table.rt_private2.id
}

resource "aws_route_table_association" "rt_in_db2_subnet" {
  subnet_id      = aws_subnet.subnet_private_db2.id
  route_table_id = aws_route_table.rt_private2.id
}
