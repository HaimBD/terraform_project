# Setting provider for Terraform API's
provider "aws" {
  region = "us-east-1"
}



# Create EC2 instance for public subnet
# resource "aws_instance" "ec2_public" {
#     ami = data.aws_ssm_parameter.al2.value
#     instance_type = var.env == "Staging" ? "t2.micro" : "t3.micro"
#     vpc_security_group_ids = [aws_security_group.ec2_group.id]
#     subnet_id = module.aws_vpc.public_subnets_ids[0]
#     associate_public_ip_address = true
#     key_name = "${var.keypair_name}"
#     tags = {
#         Name = "ec2-public"
#         Environment = "${var.env}"
#         Terraform = "true"}
#         }

# Create EC2 instance for private subnet
resource "aws_instance" "ec2_private" {
    ami = "ami-0a7d80731ae1b2435"
    instance_type = var.env == "Staging" ? "t2.micro" : "t3.micro"
    vpc_security_group_ids = [aws_security_group.ec2_group.id]
    subnet_id = module.aws_vpc.private_subnets_ids[0]
    associate_public_ip_address = false
    key_name = "${var.keypair_name}"
    tags = {
        Name = "ec2-private"
        Environment = "${var.env}"
        Terraform = "true"}
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
    ingress {
        from_port = "22"
        to_port = "22"
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



# Calling the VPC module
module "aws_vpc" {
  source = ".\\modules\\aws_vpc"

  vpc_name            = "${var.resource_alias}-vpc"
  vpc_cidr            = var.vpc_cidr
  vpc_private_subnets = var.vpc_private_subnets
  vpc_public_subnets  = var.vpc_public_subnets

  tags = {
    Env       = var.env
    Terraform = "true"
  }
}


# Calling the ALB module
module "aws_alb" {
  source = ".\\modules\\aws_alb"

  name            = "${var.resource_alias}-alb"
  vpc_id          = module.aws_vpc.vpc_id
  subnets         = module.aws_vpc.public_subnets_ids
  security_groups = [aws_security_group.alb_group.id]

  app_port          = 80
  health_check_path = "/"
  certificate_arn   = "" # add ACM ARN to enable HTTPS + redirect

  tags = {
    Env       = var.env
    Terraform = "true"
  }
}

# Nginx user data
locals {
  nginx_user_data = <<-EOT
    #!/bin/bash
    sudo amazon-linux-extras install -y nginx1
    sudo systemctl enable nginx
    sudo systemctl start nginx
    sudo yum install -y mysql
  EOT
}


# Calling the ASG
module "aws_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = ">= 9.0.0"

  name                = "${var.resource_alias}-web"
  min_size            = 1
  desired_capacity    = 1
  max_size            = 2
  vpc_zone_identifier = module.aws_vpc.public_subnets_ids
  health_check_type   = "ELB"

  # ASG attaches to the ALB TG
  traffic_source_attachments = {
    alb = { traffic_source_identifier = module.aws_alb.app_target_group_arn }
  }

  # Launch template inputs
  image_id        = data.aws_ssm_parameter.al2.value
  instance_type   = var.env == "Staging" ? "t2.micro" : "t3.micro"
  key_name        = var.keypair_name
  security_groups = [aws_security_group.ec2_group.id]
  user_data       = base64encode(local.nginx_user_data)

  # Roll instances automatically when LT changes (e.g., AMI or user_data)
  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 90
    }
    triggers = ["launch_template"]
  }

  # Resource-level tags (ASG/LT)
  tags = {
    Env       = var.env
    Terraform = "true"
  }

  # Ensure EC2 instances launched by ASG get these tags
  tag_specifications = [{
    resource_type = "instance"
    tags = {
      Name        = "${var.resource_alias}-web"
      Environment = var.env
      Terraform   = "true"
    }
  }]
}

output "alb_dns_name" {
  value = module.aws_alb.alb_dns
}

module "rds" {
  source = ".\\modules\\aws_rds"

  identifier        = "${var.resource_alias}-mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = "admin"
  password = "Pa55w.rd"

  # Exactly two private subnets (one per AZ)
  subnet_ids = [
    module.aws_vpc.private_subnets_ids[0],
    module.aws_vpc.private_subnets_ids[1]
  ]

  # Your existing RDS SG that only allows from EC2 SG on 3306
  vpc_security_group_ids = [
    aws_security_group.rds_group.id
  ]

  publicly_accessible         = false
  multi_az                    = true
  storage_encrypted           = true
  manage_master_user_password = false

  backup_retention_period = 7
  backup_window           = "04:00-05:00"
  maintenance_window      = "sun:05:00-sun:06:00"
  deletion_protection     = false
  skip_final_snapshot     = true

  tags = {
    Name      = "${var.resource_alias}-mysql"
    Env       = var.env
    Terraform = "true"
  }
}
