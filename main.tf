# Setting provider for Terraform API's
provider "aws" {
  region = "us-east-1"
}

#Creating EC2 instance with key pair and security group
resource "aws_instance" "practice_server" {
    ami = "ami-084a7d336e816906b"
    instance_type = var.env == "Staging" ? "t2.micro" : "t3.micro"
    vpc_security_group_ids = [aws_security_group.sec-group.id]
    subnet_id = module.aws_vpc.public_subnets_ids[0]
    key_name = "${var.keypair_name}"
    depends_on = [aws_s3_bucket.data_bucket]
    tags = {
        Name = "terraform-practice#1"
        Environment = "${var.env}"
        Terraform = "true"}
        }

# Creating security group with 8080 open
resource "aws_security_group" "sec-group" {
    name = "${var.security_group}-${var.env}-sg"
    vpc_id = module.aws_vpc.vpc_id
    ingress {
        from_port = "8080"
        to_port = "8080"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        }
    }

# Creating S3 bucket
resource "aws_s3_bucket" "data_bucket" {
    bucket = "hbd-terra-bucket"
    tags = {
        Name = "data_bucket"
        Env = var.env
        Terraform = true
        }
    }

module "aws_vpc" {
  source = ".\\modules\\aws_vpc"

  vpc_name            = "${var.resource_alias}-vpc"
  vpc_cidr            = var.vpc_cidr
  availability_zones  = data.aws_availability_zones.available_azs.names
  vpc_private_subnets = var.vpc_private_subnets
  vpc_public_subnets  = var.vpc_public_subnets

  enable_nat_gateway  = false
  enable_vpn_gateway  = true

  tags = {
    Name      = "${var.resource_alias}-vpc"
    Env       = var.env
    Terraform = "true"
  }
}

