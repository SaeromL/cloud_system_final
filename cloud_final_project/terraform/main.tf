# Specify AWS provider
terraform {
required_providers {
  aws = {
    source = "hashicorp/aws"
    version = "~> 3.27"
  }
}
    required_version = ">= 0.14.6"
}

provider "aws" {
  region = "us-east-1"
}

# VPCs
resource "aws_vpc" "vpc_dev" {
  cidr_block       = "10.15.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "VPC-Dev" }
}

resource "aws_vpc" "vpc_shared" {
  cidr_block       = "10.25.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "VPC-Shared" }
}

# Subnets for VPC-Dev
resource "aws_subnet" "public_dev_sn1" {
  vpc_id            = aws_vpc.vpc_dev.id
  cidr_block        = "10.15.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = { Name = "Public-Dev-SN1" }
}

resource "aws_subnet" "public_dev_sn2" {
  vpc_id            = aws_vpc.vpc_dev.id
  cidr_block        = "10.15.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = { Name = "Public-Dev-SN2" }
}

resource "aws_subnet" "private_dev_sn1" {
  vpc_id            = aws_vpc.vpc_dev.id
  cidr_block        = "10.15.3.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "Private-Dev-SN1" }
}

resource "aws_subnet" "private_dev_sn2" {
  vpc_id            = aws_vpc.vpc_dev.id
  cidr_block        = "10.15.4.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "Private-Dev-SN2" }
}

# Subnets for VPC-Shared
resource "aws_subnet" "public_shared_sn1" {
  vpc_id            = aws_vpc.vpc_shared.id
  cidr_block        = "10.25.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = { Name = "Public-Shared-SN1" }
}

resource "aws_subnet" "private_shared_sn1" {
  vpc_id            = aws_vpc.vpc_shared.id
  cidr_block        = "10.25.2.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "Private-Shared-SN1" }
}

# Internet Gateways
resource "aws_internet_gateway" "igw_dev" {
  vpc_id = aws_vpc.vpc_dev.id
  tags = { Name = "IGW-Dev" }
}

resource "aws_internet_gateway" "igw_shared" {
  vpc_id = aws_vpc.vpc_shared.id
  tags = { Name = "IGW-Shared" }
}

# NAT Gateways
resource "aws_eip" "eip_dev" {
  vpc = true
}

resource "aws_nat_gateway" "nat_dev" {
  allocation_id = aws_eip.eip_dev.id
  subnet_id     = aws_subnet.public_dev_sn1.id
  tags = { Name = "NAT-Gateway-Dev" }
}

resource "aws_eip" "eip_shared" {
  vpc = true
}

resource "aws_nat_gateway" "nat_shared" {
  allocation_id = aws_eip.eip_shared.id
  subnet_id     = aws_subnet.public_shared_sn1.id
  tags = { Name = "NAT-Gateway-Shared" }
}

# Route Tables
# Public Route Table for VPC-Dev
resource "aws_route_table" "rt_public_dev" {
  vpc_id = aws_vpc.vpc_dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_dev.id
  }
  tags = { Name = "Public-RT-Dev" }
}

resource "aws_route_table_association" "rt_assoc_public_dev_sn1" {
  subnet_id      = aws_subnet.public_dev_sn1.id
  route_table_id = aws_route_table.rt_public_dev.id
}

# Private Route Table for VPC-Dev
resource "aws_route_table" "rt_private_dev" {
  vpc_id = aws_vpc.vpc_dev.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_dev.id
  }
  tags = { Name = "Private-RT-Dev" }
}

resource "aws_route" "route_dev_to_shared" {
  route_table_id         = aws_route_table.rt_private_dev.id
  destination_cidr_block = aws_vpc.vpc_shared.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Public Route Table for VPC-Shared
resource "aws_route_table" "rt_public_shared" {
  vpc_id = aws_vpc.vpc_shared.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_shared.id
  }
  tags = { Name = "Public-RT-Shared" }
}

resource "aws_route_table_association" "rt_assoc_public_shared_sn1" {
  subnet_id      = aws_subnet.public_shared_sn1.id
  route_table_id = aws_route_table.rt_public_shared.id
}

# Private Route Table for VPC-Shared
resource "aws_route_table" "rt_private_shared" {
  vpc_id = aws_vpc.vpc_shared.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_shared.id
  }
  tags = { Name = "Private-RT-Shared" }
}

resource "aws_route_table_association" "rt_assoc_private_shared_sn1" {
  subnet_id      = aws_subnet.private_shared_sn1.id
  route_table_id = aws_route_table.rt_private_shared.id
}

resource "aws_route" "route_shared_to_dev" {
  route_table_id         = aws_route_table.rt_private_shared.id
  destination_cidr_block = aws_vpc.vpc_dev.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}


# VPC Peering
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = aws_vpc.vpc_dev.id
  peer_vpc_id   = aws_vpc.vpc_shared.id
  auto_accept   = true
  tags = { Name = "VPC-Peering-Dev-Shared" }
}

# Security Groups
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.vpc_shared.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["54.160.106.34/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Bastion-SG" }
}


resource "aws_security_group" "web_alb_sg" {
  vpc_id = aws_vpc.vpc_dev.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Web-ALB-SG" }
}


resource "aws_security_group" "mysql_sg" {
  vpc_id = aws_vpc.vpc_shared.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.15.0.0/16"] # VPC-Dev CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "MySQL-SG" }
}


# Bastion Host
resource "aws_instance" "bastion" {
  ami           = "ami-0453ec754f44f9a4a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_shared_sn1.id
  security_groups = [aws_security_group.bastion_sg.id]
  tags = { Name = "Bastion-Host" }
}

resource "aws_instance" "webserver1" {
  ami           = "ami-0453ec754f44f9a4a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_dev_sn1.id
  security_groups = [aws_security_group.web_alb_sg.id]
  tags = { Name = "Webserver1" }
}

resource "aws_instance" "webserver2" {
  ami           = "ami-0453ec754f44f9a4a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_dev_sn2.id
  security_groups = [aws_security_group.web_alb_sg.id]
  tags = { Name = "Webserver2" }
}
