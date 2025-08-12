# Nginx user data (plain text; we’ll base64 it below)
locals {
  nginx_user_data = <<-EOT
    #!/bin/bash
    set -eux
    PKG="yum"; command -v dnf && PKG="dnf"
    $PKG -y update
    $PKG -y install nginx
    systemctl enable nginx
    systemctl start nginx
    # simple 200 OK health page
    echo "<h1>ok from $(hostname)</h1>" > /usr/share/nginx/html/index.html
  EOT
}

module "aws_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = ">= 9.0.0"

  name                = "hbd-asg"
  min_size            = 1
  desired_capacity    = 2
  max_size            = 3
  vpc_zone_identifier = module.aws_vpc.public_subnets_ids
  health_check_type   = "ELB"

  # Attach to existing ALB Target Group (elbv2)
  traffic_source_attachments = {
    alb = {
      traffic_source_identifier = module.aws_alb.app_target_group_arn
    }
  }

  # Launch Template inputs
  image_id      = data.aws_ssm_parameter.al2.value
  instance_type = "t3.micro"
  key_name      = var.keypair_name

  # ✅ Force public IPs (and move SGs into the NI)
  network_interfaces = [{
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_group.id]
  }]

  # Make sure new LT versions are used automatically
  launch_template_name        = "hbd-asg-lt"
  launch_template_description = "hbd ASG Launch Template"
  update_default_version      = true

  # Base64-encode user data for the Launch Template
  user_data = base64encode(local.nginx_user_data)

  # Roll instances when LT changes (e.g., AMI or user_data)
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

  # Ensure EC2 instances get these tags
  tag_specifications = [{
    resource_type = "instance"
    tags = {
      Name        = "${var.resource_alias}-web"
      Environment = var.env
      Terraform   = "true"
    }
  }]
}