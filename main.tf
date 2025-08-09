# Setting provider for Terraform API's
provider "aws" {
  region = "us-east-1"
}

# Creating security group for ALB
resource "aws_security_group" "alb_group" {
    name = "${var.security_group_alb}"
    vpc_id = module.aws_vpc.vpc_id
    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
        from_port = "443"
        to_port = "443"
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

# Creating security group for EC2
resource "aws_security_group" "ec2_group" {
    name = "${var.security_group_ec2}"
    vpc_id = module.aws_vpc.vpc_id
#     ingress {
#         from_port = "80"
#         to_port = "80"
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#         }
#         ingress {
#         from_port = "443"
#         to_port = "443"
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#         }
    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        }
    }

# Linking between ALB to EC2 with port 80
resource "aws_security_group_rule" "ec2_from_alb_http" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ec2_group.id
  source_security_group_id = aws_security_group.alb_group.id
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
}

# Linking between ALB to EC2 with port 443
resource "aws_security_group_rule" "ec2_from_alb_https" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ec2_group.id
  source_security_group_id = aws_security_group.alb_group.id
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
}

# Creating security group for RDS
resource "aws_security_group" "rds_group" {
    name = "${var.security_group_rds}"
    vpc_id = module.aws_vpc.vpc_id
#     ingress {
#         from_port = "3306"
#         to_port = "3306"
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#         }
    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        }
    }

# Linking between EC2 to RDS with port 3306
resource "aws_security_group_rule" "rds_from_ec2_mysql" {
  type                     = "ingress"
  security_group_id        = aws_security_group.rds_group.id
  source_security_group_id = aws_security_group.ec2_group.id
  from_port                = "3306"
  to_port                  = "3306"
  protocol                 = "tcp"
}







module "aws_vpc" {
  source = ".\\modules\\aws_vpc"

  vpc_name            = "${var.resource_alias}-vpc"
  vpc_cidr            = var.vpc_cidr
  availability_zones  = data.aws_availability_zones.available_azs.names
  vpc_private_subnets = var.vpc_private_subnets
  vpc_public_subnets  = var.vpc_public_subnets

  enable_nat_gateway  = true
  enable_vpn_gateway  = true


  tags = {
    Name      = "${var.resource_alias}-vpc"
    Env       = var.env
    Terraform = "true"
  }
}

