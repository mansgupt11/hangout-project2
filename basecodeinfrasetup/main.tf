terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
#Provider defination 
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

###Terraform Production VPC##
resource "aws_vpc" "production" {
  cidr_block           = var.vpc_cicd
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = var.tagvari
  }
}
################# VPC creation Done###################

#####EC2 key file cretion and uploading in AWS and saving local disk######
resource "tls_private_key" "ec2-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  }
resource "local_file" "cloud_pem" { 
  filename = "${path.module}/awskey.pem"
  content = tls_private_key.ec2-key.private_key_pem
  file_permission = "0400"

}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2-key.public_key_openssh
}


################## EC2 key task  done##########

# Terraform Production Subnets
resource "aws_subnet" "production-public-1" {
  vpc_id                  = aws_vpc.production.id
  cidr_block              = var.subnet1-cidr
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = var.tagvari
  }
}



# Terraform Production GW
resource "aws_internet_gateway" "production-gw" {
  vpc_id = aws_vpc.production.id
  tags = {
    Name = var.tagvari
  }
}

# Terraform Production RT
resource "aws_route_table" "production-public" {
  vpc_id = aws_vpc.production.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.production-gw.id
  }
  tags = {
    Name = var.tagvari
  }
}

####### Terraform Production RTA with subnet1 ######### #########
resource "aws_route_table_association" "production-public-1-a" {
  subnet_id      = aws_subnet.production-public-1.id
  route_table_id = aws_route_table.production-public.id
}
####### Terraform Production RTA with both subnets done #########

## Security Group for ec2 VMs#######################
resource "aws_security_group" "production_private_sg" {
  description = "Allow limited inbound external traffic"
  vpc_id      = aws_vpc.production.id
  name        = "production-sg"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Open up incoming ssh port
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.tagvari
  }
}

## Security Group for ec2 VM completed #######################


####################aws kubernets ec2 nodes cretion###############################
resource "aws_instance" "ec2-vms" {
  ami                    = var.vmimage
  count                  = var.ec2-vmcount
  instance_type          = var.vmtypefree
  key_name               = aws_key_pair.generated_key.key_name
  subnet_id              = aws_subnet.production-public-1.id
  vpc_security_group_ids = [aws_security_group.production_private_sg.id]
  user_data              = file("init-script.sh")
  tags = {
    Name        = "jenkins ${count.index + 1}"
    Environment = "Production"
    Project1 = var.tagvari
  }
  }

