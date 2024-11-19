#----------------------------------------
# Terraform Conditions and Lookups
#
# Lesson 23 from ADV-IT
#----------------------------------------

variable "work_region" {
  default = {
    "prod" = "eu-central-1"
    "dev"  = "eu-west-1"
  }
}
variable "work_ami" {
  default = {
    "prod" = "ami-017095afb82994ac7"
    "dev"  = "ami-0fcc0bef51bad3cb2"
  }
}
variable "using_key" {
  default = {
    "prod" = "zub-key-frankfurt"
    "dev"  = "zub-key-ireland"
  }
}
provider "aws" {
  region = lookup(var.work_region, var.prod_level)
}

variable "prod_level" {
  default = "prod"
}

variable "prod_owner" {
  default = "AZ"
}

variable "other_owner" {
  default = "Vasya Pupkind"
}

resource "aws_instance" "server1" {
  ami = lookup(var.work_ami, var.prod_level)
  //  instance_type = "t2.micro"
  instance_type          = var.prod_level == "prod" ? "t2.small" : "t2.micro"
  key_name               = lookup(var.using_key, var.prod_level)
  vpc_security_group_ids = [aws_security_group.SSH-server.id]


  tags = {
    Name  = "${var.prod_level}-Server"
    Owner = var.prod_level == "prod" ? var.prod_owner : var.other_owner
  }
}

resource "aws_security_group" "SSH-server" {
  name        = "SSH-Server Security Group"
  description = "My First TF SecurityGroup"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}
