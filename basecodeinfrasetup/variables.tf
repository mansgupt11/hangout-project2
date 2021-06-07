variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "region" {
        default = "us-east-1"
}

variable "vpc_cicd" {
    default = "10.0.0.0/16"
}

variable "tagvari" {
    description = "This variable is using under all tags"
    default = "Hangout-Project2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "key_name" {
    description = "This variable is using under ec2-key genration"
    default = "awskey"
}


variable "vmimage" {
    description = "This variable is using for image"
    default = "ami-09e67e426f25ce0d7" #ubuntu 20 image
    }

variable "vmtypefree" {
    description = "This variable is using for free version of "
    default = "t3.micro"
    }

    variable "subnet1-cidr"{
    default = "10.0.1.0/24"
    }



variable "routepublicall" {
    default = ["0.0.0.0/0"]
}



variable "ec2-vmcount" {
    description = "This variable is using for VM count"
    default = "4"
}